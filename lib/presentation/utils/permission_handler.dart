import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class BlePermissionHandler {
  static Future<bool> checkAndRequestPermissions() async {
    if (Platform.isAndroid) {
      final permissions = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetooth,
        Permission.locationWhenInUse,
      ].request();

      return permissions.values.every((status) => status.isGranted);
    } else if (Platform.isIOS) {
      final status = await Permission.bluetooth.request();
      return status.isGranted;
    }
    return true;
  }

  static Future<void> checkPermissionStatus() async {
    if (Platform.isAndroid) {
      final locationStatus = await Permission.locationWhenInUse.status;
      final bluetoothScanStatus = await Permission.bluetoothScan.status;
      final bluetoothConnectStatus = await Permission.bluetoothConnect.status;
      
      print('Location Permission: $locationStatus');
      print('BluetoothScan Permission: $bluetoothScanStatus');
      print('BluetoothConnect Permission: $bluetoothConnectStatus');
    }
  }
}