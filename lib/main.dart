import 'package:flutter/material.dart';
import 'esp32_service.dart';
import 'plot_graphs.dart';
import 'file_explorer.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Communication',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _response = '';
  List<List<double>> _data = [];
  String _temp = '';
  final textController = TextEditingController();
  String moduleId = "";
  String latestFileName = "";

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
  }

  Future<void> _onFileSelected(String fileName) async {
    Directory? directory = await getExternalStorageDirectory();
    String path = directory!.path.split("Android")[0] + "Download";
    print('TESTING THIS FUNC: $path');
    setState(() {
      latestFileName = '$path/$fileName';
    });
    print('Selected file: $latestFileName');
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    textController.dispose();
    super.dispose();
  }

  String sanitizeFileName(String input) {
    // Define a regular expression to match invalid characters
    final RegExp regExp = RegExp(r'[\/\\:*?"<>|]');
    // Replace invalid characters with an underscore or any other character you prefer
    return input.replaceAll(regExp, '_');
  }

  void _setModuleId() {
    final sanitizedModuleId = sanitizeFileName(textController.text);
    setState(() {
      moduleId = sanitizedModuleId;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('IPV'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextField(
              controller: textController,
              maxLines: null,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter module ID',
              ),
            ),
          ),
          ElevatedButton(onPressed: _setModuleId, child: Text('Update ID')),
          Text('Module ID: $moduleId'),
          ElevatedButton(
            onPressed: _connectToESP32,
            child: _response == 'processing...'
                ? SizedBox(
                    width:
                        24, // Adjust the width to match the size of the CircularProgressIndicator
                    height:
                        24, // Adjust the height to match the size of the CircularProgressIndicator
                    child: CircularProgressIndicator(),
                  )
                : Text('Get data from ESP32'),
          ),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Select File'),
                  content: FileExplorer(onFileSelected: _onFileSelected),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Close'),
                    ),
                  ],
                ),
              );
            },
            child: Text('Open File Explorer'),
          ),
          ElevatedButton(
            onPressed: _readFile,
            child: Text('Read and Plot Data'),
          ),
          SizedBox(height: 20),
          Text(_response),
          if (latestFileName != '')
            Text(
              'Selected File: $latestFileName',
              style: TextStyle(fontSize: 12),
            ),
          if (_temp != '')
            Text(
              '$_temp °C',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          Expanded(
            child: _data.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      plotGraph("Voltage vs MP", 0, 2, Colors.red, 'Voltage(V)',
                          'Measure Point(MP)', _data),
                      plotGraph("Current vs MP", 0, 3, Colors.blue,
                          'Current(A)', 'Measure Point(MP)', _data),
                      plotGraph("Irradiation vs MP", 0, 4, Colors.orange,
                          'Irr(W/m²)', 'Measure Point(MP)', _data),
                      plotGraph("Current vs Voltage", 2, 3, Colors.green,
                          'Current(A)', 'Voltage(V)', _data),
                      plotPowerGraph("Power vs Voltage", Colors.purple,
                          'Power(W)', 'Voltage(V)', _data),
                    ],
                  ),
          ),

        ],
      ),
    );
  }

  Future<void> _connectToESP32() async {
    setState(() {
      _response = 'processing...';
    });
    var response = await connectToESP32(moduleId);
    if (response['status'] == 1) {
      setState(() {
        latestFileName = response['fileName'];
      });
      print('Returned filename: ${response['fileName']}');
    }
    setState(() {
      _response = response['msg'];
    });
    if (_response == 'Successfully saved data!') {
      _clearResponseAfterDelay();
    }
  }

  Future<void> _readFile() async {
    Map<String, dynamic> fileData = await readFile(latestFileName);
    setState(() {
      _data = List<List<double>>.from(fileData['parsedData']);
      _temp = fileData['temp'];
    });
  }

  void _clearResponseAfterDelay() {
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _response = '';
      });
    });
  }
}
