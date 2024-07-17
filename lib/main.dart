import 'package:flutter/material.dart';
import 'esp32_service.dart';
import 'plot_graphs.dart';

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
  double? _temperature;
  List<List<double>> _data = [];

  @override
  void initState() {
    super.initState();
    requestStoragePermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ESP32 Communication'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
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
            onPressed: _readFile,
            child: Text('Read and Plot Data'),
          ),
          SizedBox(height: 20),
          Text(_response),
          if (_temperature != null)
            Text('Temperature: ${_temperature!.toStringAsFixed(2)}°C'),
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
    String response = await connectToESP32();
    setState(() {
      _response = response;
    });
    _clearResponseAfterDelay();
  }

  Future<void> _readFile() async {
    Map<String, dynamic> fileData = await readFile();
    setState(() {
      _data = List<List<double>>.from(fileData['parsedData']);
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
