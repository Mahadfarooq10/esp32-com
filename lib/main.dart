import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

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

  Future<void> connectToESP32() async {
    const String host = '192.168.8.1';
    const int port = 8088;
    const int maxRetries = 3;
    int retryCount = 0;

    while (retryCount < maxRetries) {
      try {
        final socket = await Socket.connect(host, port, timeout: Duration(seconds: 10));
        socket.write('GO');

        // Listen for the response
        socket.listen((data) {
          setState(() {
            _response = utf8.decode(data);
          });
          _clearResponseAfterDelay();
        }, onDone: () {
          print('Connection closed');
          socket.destroy();
        }, onError: (error) {
          setState(() {
            _response = 'Connection Error: $error';
          });
          _clearResponseAfterDelay();
          socket.destroy();
        });

        return; // Exit the loop on successful connection
      } on SocketException catch (e) {
        setState(() {
          _response = 'SocketException: $e';
        });
        _clearResponseAfterDelay();
      } catch (e) {
        setState(() {
          _response = 'Error: $e';
        });
        _clearResponseAfterDelay();
      }

      retryCount++;
      await Future.delayed(Duration(seconds: 2)); // Wait before retrying
    }

    if (retryCount == maxRetries) {
      setState(() {
        _response = 'Failed to connect after $maxRetries attempts';
      });
      _clearResponseAfterDelay();
    }
  }

  void _clearResponseAfterDelay() {
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _response = '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ESP32 Communication'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: connectToESP32,
              child: Text('Connect to ESP32'),
            ),
            SizedBox(height: 20),
            Text(_response),
          ],
        ),
      ),
    );
  }
}
