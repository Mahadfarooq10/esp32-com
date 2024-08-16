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
  double Vmpp = 0;
  double Impp = 0;
  double Pmpp = 0;
  double irradiation = 0;

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
  }

  Future<void> _onFileSelected(String fileName) async {
    Directory? directory = await getExternalStorageDirectory();
    String path = directory!.path.split("Android")[0] + "Download";
    setState(() {
      latestFileName = '$path/$fileName';
    });
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
        title: Text('SEPIV'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textController,
                      maxLines: null,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black), // Default border color
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black), // Border color when focused
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors.black), // Border color when enabled
                        ),
                        hintText: 'Enter module ID',
                        hintStyle:
                            TextStyle(color: Colors.black), // Hint text color
                      ),
                      onChanged: (value) {
                        setState(() {
                          moduleId = value; // Update the moduleId with the new value
                        });
                      },
                    ),
                  ),
                  // Add some space between the text field and the button
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    flex: 4, // Takes up half of the row's width
                    child: Container(
                      child: Column(
                        children: [
                          ElevatedButton(
                            onPressed: _connectToESP32,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors
                                  .blue, // Set the button's background color to blue
                            ),
                            child: _response == 'processing...'
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(),
                                  )
                                : Text(
                                    'Measure',
                                    style: TextStyle(
                                        color: Colors
                                            .white), // Set the text color to white
                                  ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Select File'),
                                  content: FileExplorer(
                                      onFileSelected: _onFileSelected),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'Close',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors
                                  .blue, // Set the button's background color to blue
                            ),
                            child: Text(
                              'File Explorer',
                              style: TextStyle(
                                  color: Colors
                                      .white), // Set the text color to white
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _readFile,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors
                                  .blue, // Set the button's background color to blue
                            ),
                            child: Text(
                              'Plot Graphs',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6, // Takes up half of the row's width
                    child: Container(
                        margin: const EdgeInsets.all(10.0),
                        padding: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          border: Border.all(width: 3.0),
                          borderRadius: BorderRadius.all(Radius.circular(
                                  5.0) //                 <--- border radius here
                              ),
                        ),
                        child: Column(
                          children: [
                            Text('Module ID: $moduleId',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold)),
                            if (_temp != '')
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('$_temp °C',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Irradiation: ',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                Text('$irradiation',
                                    style: TextStyle(fontSize: 14)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Vmpp: ',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                Text('$Vmpp', style: TextStyle(fontSize: 14)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Impp: ',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                Text('$Impp', style: TextStyle(fontSize: 14)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Pmpp: ',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                Text('$Pmpp', style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ],
                        )),
                  ),
                ],
              ),
            ),
            Text(_response),
            Container(
              // Remove the fixed height here
              child: _data.isEmpty
                  ? Center(
                      child: Text('No data to display',
                          style: TextStyle(fontSize: 16)),
                    )
                  : ListView(
                      shrinkWrap: true,
                      // Add this property
                      physics: NeverScrollableScrollPhysics(),
                      // Prevent ListView from scrolling independently
                      children: [
                        plotGraph("Irradiation vs MP", 0, 4, Colors.orange,
                            'Irr(W/m²)', 'Measure Point(MP)', _data),
                        plotGraph("Current vs Voltage", 2, 3, Colors.green,
                            'Current(A)', 'Voltage(V)', _data),
                        plotPowerGraph("Power vs Voltage", Colors.purple,
                            'Power(W)', 'Voltage(V)', _data),
                        plotGraph("Voltage vs MP", 0, 2, Colors.red,
                            'Voltage(V)', 'Measure Point(MP)', _data),
                        plotGraph("Current vs MP", 0, 3, Colors.blue,
                            'Current(A)', 'Measure Point(MP)', _data),
                      ],
                    ),
            )
          ],
        ),
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
      Impp = findMaxInColumn(_data, 3);
      Vmpp = findMaxInColumn(_data, 2);
      irradiation = findMeanInColumn(_data, 4);
      Pmpp = findMaxPower(_data, 2, 3);
    });
  }

  double findMaxInColumn(List<List<double>> data, int columnIndex) {
    return data.map((row) => row[columnIndex]).reduce((a, b) => a > b ? a : b);
  }

  double findMeanInColumn(List<List<double>> data, int columnIndex) {
    List<double> columnValues = data.map((row) => row[columnIndex]).toList();
    double sum = columnValues.reduce((a, b) => a + b);
    double mean = sum / columnValues.length;
    double roundedMean = double.parse(mean.toStringAsPrecision(3));
    return roundedMean;
  }

  double findMaxPower(
      List<List<double>> data, int voltageIndex, int currentIndex) {
    double maxPower = 0.0;

    for (var row in data) {
      double power = row[voltageIndex] * row[currentIndex];
      if (power > maxPower) {
        maxPower = power;
      }
    }
    double roundedPower = double.parse(maxPower.toStringAsPrecision(3));
    return roundedPower;
  }

  void _clearResponseAfterDelay() {
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _response = '';
      });
    });
  }
}
