// ignore_for_file: prefer_const_constructors, file_names, avoid_print, avoid_function_literals_in_foreach_calls, no_leading_underscores_for_local_identifiers, unnecessary_this

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class HomePage extends StatefulWidget {
  final BluetoothDevice device;

  const HomePage({Key? key, required this.device}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool onLight = false;
  BluetoothConnection? connection;

  bool isConnecting = true;
  bool get isConnected => (connection?.isConnected ?? false);

  bool isDisconnecting = false;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.device.address).then((_connection) {
      print('Connected to the device');
      connection = _connection;
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      connection!.input!.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
        if (this.mounted) {
          setState(() {});
        }
      });

      connection!.output.add(utf8.encode('0'));
    }).catchError((error) {
      print('Cannot connect, exception occured');
      print(error);
    });
  }

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.device.name!)),
      body: Center(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: onLight ? Colors.amber[300] : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                onLight ? Icons.lightbulb : Icons.lightbulb_outline_rounded,
                size: 250,
                color: onLight ? Colors.white : null,
              ),
              SizedBox(height: 15),
              SizedBox(
                width: 95,
                child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll<Color>(Colors.blueAccent),
                      padding: MaterialStatePropertyAll(
                        EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                      ),
                    ),
                    onPressed: () async {
                      setState(() {
                        onLight = !onLight;
                        try {
                          if (onLight) {
                            connection!.output.add(utf8.encode('1'));
                            connection!.output.allSent;
                          } else {
                            connection!.output.add(utf8.encode('0'));
                            connection!.output.allSent;
                          }
                        } catch (e) {
                          print(e.toString());
                        }
                      });
                    },
                    child: Text(
                      onLight ? 'Off' : 'On',
                      style: TextStyle(color: Colors.white, fontSize: 30),
                    )),
              ),
              SizedBox(height: 20),
              Text(widget.device.name!),
              Text(widget.device.address),
            ],
          ),
        ),
      ),
    );
  }

  void _onDataReceived(Uint8List data) {
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }
  }
}
