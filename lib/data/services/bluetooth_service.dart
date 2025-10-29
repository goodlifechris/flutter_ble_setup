import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothService {
  // Direct stream access (same as your working code)
  Stream<BluetoothAdapterState> get adapterState => FlutterBluePlus.adapterState;
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.onScanResults;

  // Basic checks
  Future<bool> get isSupported => FlutterBluePlus.isSupported;

  // Simple methods that match your working code
  Future<void> turnOn() => FlutterBluePlus.turnOn();

  Future<void> startScan({Duration timeout = const Duration(seconds: 15)}) {
    return FlutterBluePlus.startScan(timeout: timeout);
  }

  Future<void> stopScan() => FlutterBluePlus.stopScan();

  Future<BluetoothAdapterState> getCurrentAdapterState() {
    return FlutterBluePlus.adapterState.first;
  }

  // Helper to wait for Bluetooth to be enabled (for your _requestEnableBluetooth method)
  Future<bool> waitForBluetoothEnabled({Duration timeout = const Duration(seconds: 10)}) async {
    try {
      await FlutterBluePlus.adapterState
          .firstWhere((state) => state == BluetoothAdapterState.on)
          .timeout(timeout);
      return true;
    } on TimeoutException {
      return false;
    } catch (e) {
      return false;
    }
  }
}