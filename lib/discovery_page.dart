// ignore_for_file: avoid_print, unnecessary_new, prefer_const_constructors, curly_braces_in_flow_control_structures, use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously, unnecessary_string_interpolations, sort_child_properties_last

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app_for_esp32_03/bluetooth_device_list_entry.dart';
import 'package:flutter_app_for_esp32_03/home_page.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class DiscoveryPage extends StatefulWidget {
  final bool start;

  const DiscoveryPage({this.start = true});

  @override
  _DiscoveryPage createState() => new _DiscoveryPage();
}

class _DiscoveryPage extends State<DiscoveryPage> {
  StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
  static List<BluetoothDiscoveryResult> results =
      List<BluetoothDiscoveryResult>.empty(growable: true);
  bool isDiscovering = false;

  _DiscoveryPage();

  @override
  void initState() {
    super.initState();

    isDiscovering = widget.start;
    if (isDiscovering) {
      _startDiscovery();
    }
  }

  void _restartDiscovery() {
    setState(() {
      results.clear();
      isDiscovering = true;
    });

    _startDiscovery();
  }

  void _startDiscovery() {
    _streamSubscription =
        FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
      setState(() {
        final existingIndex = results.indexWhere(
            (element) => element.device.address == r.device.address);
        if (existingIndex >= 0)
          results[existingIndex] = r;
        else
          results.add(r);
      });
    });

    _streamSubscription!.onDone(() {
      setState(() {
        isDiscovering = false;
      });
    });
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            results = results
                .where((element) => element.device.name == 'ESP32_CLASSIC_BT')
                .toList();
          });
        },
        child: Icon(Icons.filter_list, color: Colors.white),
        backgroundColor: Colors.blueAccent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: isDiscovering
            ? Text(
                'Discovering devices',
                style: TextStyle(color: Colors.white),
              )
            : Text(
                'Discovered devices',
                style: TextStyle(color: Colors.white),
              ),
        actions: <Widget>[
          isDiscovering
              ? FittedBox(
                  child: Container(
                    margin: new EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(Icons.replay, color: Colors.white),
                  onPressed: _restartDiscovery,
                )
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildBuilderDelegate((BuildContext context, index) {
              BluetoothDiscoveryResult result = results[index];
              final device = result.device;
              final address = device.address;
              return BluetoothDeviceListEntry(
                device: device,
                rssi: result.rssi,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return HomePage(
                          device: result.device,
                        );
                      },
                    ),
                  );
                },
                onLongPress: () async {
                  try {
                    bool bonded = false;
                    if (device.isBonded) {
                      print('Unbonding from ${device.address}...');
                      await FlutterBluetoothSerial.instance
                          .removeDeviceBondWithAddress(address);
                      print('Unbonding from ${device.address} has succed');
                    } else {
                      print('Bonding with ${device.address}...');
                      bonded = (await FlutterBluetoothSerial.instance
                          .bondDeviceAtAddress(address))!;
                      print(
                          'Bonding with ${device.address} has ${bonded ? 'succed' : 'failed'}.');
                    }
                    setState(() {
                      results[results.indexOf(result)] =
                          BluetoothDiscoveryResult(
                              device: BluetoothDevice(
                                name: device.name ?? '',
                                address: address,
                                type: device.type,
                                bondState: bonded
                                    ? BluetoothBondState.bonded
                                    : BluetoothBondState.none,
                              ),
                              rssi: result.rssi);
                    });
                  } catch (ex) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error occured while bonding'),
                          content: Text("${ex.toString()}"),
                          actions: <Widget>[
                            new TextButton(
                              child: new Text("Close"),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              );
            }, childCount: results.length),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(10)),
                child: Center(
                  child: Text(
                    '+',
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
