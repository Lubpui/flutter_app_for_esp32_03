// ignore_for_file: avoid_print, prefer_const_constructors, await_only_futures, unnecessary_brace_in_string_interps, unnecessary_string_interpolations

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';

class BleController extends GetxController {
  bool _isConnected = false;

  Future<void> startScanning() async {
    if (await FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
      print('Scanning stopped.');
    }

    try {
      // Start scanning with timeout
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
      print('Scanning started for 10 seconds.'); // Informative message
    } catch (e) {
      // Handle Bluetooth exceptions gracefully
      Get.snackbar(
        'Error',
        'Error while scanning: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    FlutterBluePlus.scanResults.listen((scanresult) {
      print('${scanresult.toString()}');
    });
  }
}
