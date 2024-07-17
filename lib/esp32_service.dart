import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

Future<Map<String, dynamic>> connectToESP32(String moduleId) async {
  const String host = '192.168.8.1';
  const int port = 8088;
  const int maxRetries = 3;
  int retryCount = 0;
  var response = {'status': 0, 'msg': 'No data received!'};
  StringBuffer dataBuffer = StringBuffer();

  while (retryCount < maxRetries) {
    try {
      final socket = await Socket.connect(host, port, timeout: Duration(seconds: 60));
      socket.write('GO');

      await socket.listen((data) {
        dataBuffer.write(utf8.decode(data));
      }).asFuture();

      socket.destroy();
      String dataString = dataBuffer.toString();
      if (dataString.isNotEmpty) {
        final fileName = await writeToFile(dataString, moduleId);
        response = {'status': 1, 'msg': 'Successfully saved readings to downloads!', 'fileName': fileName};
      } else {
        response = {'status': 0, 'msg': 'No data received from ESP32'};
      }
      break;
    } on SocketException catch (e) {
      response = {'status': 0, 'msg': 'SocketException: $e'};
    } catch (e) {
      response = {'status': 0, 'msg': 'Error: $e'};
    }

    retryCount++;
    await Future.delayed(Duration(seconds: 2));
  }

  if (retryCount == maxRetries) {
    response = {'status': 0, 'msg': 'Failed to connect after $maxRetries attempts'};
  }

  return response;
}

Future<String> writeToFile(String data, String moduleId) async {
  Directory? directory = await getExternalStorageDirectory();
  if (directory == null) {
    return 'Unable to get external storage directory';
  }
  final fName = getFileName(moduleId);
  String downloadsPath = directory.path.split("Android")[0] + "Download";
  final file = File('$downloadsPath/$fName');
  await file.writeAsString(data);
  print('File written to: $downloadsPath/$fName');
  return '$downloadsPath/$fName';
}

Future<void> requestStoragePermission() async {
  final deviceInfo = await DeviceInfoPlugin().androidInfo;
  bool permissionStatus = deviceInfo.version.sdkInt > 32
      ? await Permission.photos.request().isGranted
      : await Permission.storage.request().isGranted;
  if (!permissionStatus) {
    throw Exception('Storage permission not granted!');
  }
}

Future<Map<String, dynamic>> readFile() async {
  Directory? directory = await getExternalStorageDirectory();
  String path = directory!.path.split("Android")[0] + "Download";
  File file = File('$path/test.txt');
  List<String> lines = await file.readAsLines();
  return parseData(lines);
}

String getFileName(String modId) {
  DateTime now = DateTime.now();
  String formattedDate = "${now.day.toString().padLeft(2, '0')}.${now.month.toString().padLeft(2, '0')}.${now.year.toString().substring(2)}";
  String formattedTime = "${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}.${now.second.toString().padLeft(2, '0')}";
  String fileName = "${modId}_${formattedDate}_${formattedTime}.txt";
  return fileName;
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