import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

Future<String> connectToESP32() async {
  const String host = '192.168.8.1';
  const int port = 8088;
  const int maxRetries = 3;
  int retryCount = 0;
  String response = '';
  StringBuffer dataBuffer = StringBuffer();

  while (retryCount < maxRetries) {
    try {
      final socket = await Socket.connect(host, port, timeout: Duration(seconds: 60));
      socket.write('GO');

      await socket.listen((data) {
        dataBuffer.write(utf8.decode(data));
      }).asFuture();

      socket.destroy();
      response = dataBuffer.toString();
      await writeToFile(response);
      response = 'Successfully saved data!';
      break;
    } on SocketException catch (e) {
      response = 'SocketException: $e';
    } catch (e) {
      response = 'Error: $e';
    }

    retryCount++;
    await Future.delayed(Duration(seconds: 2));
  }

  if (retryCount == maxRetries) {
    response = 'Failed to connect after $maxRetries attempts';
  }

  return response;
}

Future<void> writeToFile(String data) async {
  Directory? directory = await getExternalStorageDirectory();
  if (directory == null) {
    print('Unable to get external storage directory');
    return;
  }

  String downloadsPath = directory.path.split("Android")[0] + "Download";
  final file = File('$downloadsPath/test.txt');
  await file.writeAsString(data);
  print('File written to: $downloadsPath/test.txt');
}



// Future<String> connectToESP32() async {
//   const String host = '192.168.8.1';
//   const int port = 8088;
//   const int maxRetries = 3;
//   int retryCount = 0;
//   String response = '';
//
//   while (retryCount < maxRetries) {
//     try {
//       final socket = await Socket.connect(host, port, timeout: Duration(seconds: 60));
//       socket.write('GO');
//
//       await for (var data in socket) {
//         response = utf8.decode(data);
//         await writeToFile(response);
//         response = 'Successfully saved data!';
//         break;
//       }
//
//       socket.destroy();
//       break;
//     } on SocketException catch (e) {
//       response = 'SocketException: $e';
//     } catch (e) {
//       response = 'Error: $e';
//     }
//
//     retryCount++;
//     await Future.delayed(Duration(seconds: 2));
//   }
//
//   if (retryCount == maxRetries) {
//     response = 'Failed to connect after $maxRetries attempts';
//   }
//
//   return response;
// }

Future<void> requestStoragePermission() async {
  final deviceInfo = await DeviceInfoPlugin().androidInfo;
  bool permissionStatus = deviceInfo.version.sdkInt > 32
      ? await Permission.photos.request().isGranted
      : await Permission.storage.request().isGranted;
  if (!permissionStatus) {
    throw Exception('Storage permission not granted!');
  }
}

// Future<void> writeToFile(String data) async {
//   await requestStoragePermission();
//   Directory? directory = await getExternalStorageDirectory();
//   if (directory == null) throw Exception('Unable to get external storage directory');
//
//   String downloadsPath = directory.path.split("Android")[0] + "Download";
//   final file = File('$downloadsPath/test.txt');
//   await file.writeAsString(data);
// }

Future<Map<String, dynamic>> readFile() async {
  Directory? directory = await getExternalStorageDirectory();
  String path = directory!.path.split("Android")[0] + "Download";
  File file = File('$path/test.txt');
  List<String> lines = await file.readAsLines();
  return parseData(lines);
}

Map<String, dynamic> parseData(List<String> lines) {
  Map<String, dynamic> data = {};
  List<List<double>> parsedData = [];

  for (int i = 0; i < lines.length; i++) {
    if (lines[i].isNotEmpty) {
      List<String> values = lines[i].split(';');
      if (values.length >= 5) {
        parsedData.add(values.map((v) => double.tryParse(v.replaceAll('%', '')) ?? 0).toList());
      }
    }
  }

  // Check if the first line contains temperature data and remove it
  if (lines.isNotEmpty && lines[0].contains('Temperature')) {
    String temp = lines[0];
    lines.removeAt(0);
  }
  data['parsedData'] = parsedData;
  return data;
}