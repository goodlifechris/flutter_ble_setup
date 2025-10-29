import 'package:flutter/material.dart';

class BluetoothStateViews {
  static Widget buildOffView(BuildContext context, VoidCallback onEnableBluetooth) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bluetooth_disabled, size: 80, color: Colors.grey),
            const SizedBox(height: 24),
            Text(
              'Bluetooth Required',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text(
              'This app needs Bluetooth to scan for nearby devices.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              icon: const Icon(Icons.bluetooth),
              label: const Text('ENABLE BLUETOOTH'),
              onPressed: onEnableBluetooth,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _showBluetoothHelpDialog(context, onEnableBluetooth),
              child: const Text('Need help?'),
            ),
          ],
        ),
      ),
    );
  }

  static void _showBluetoothHelpDialog(BuildContext context, VoidCallback onEnableBluetooth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Bluetooth'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To enable Bluetooth:'),
            SizedBox(height: 12),
            Text('1. Open Settings app'),
            Text('2. Tap "Connections" or "Bluetooth"'),
            Text('3. Toggle Bluetooth ON'),
            SizedBox(height: 12),
            Text('Then return to this app.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              onEnableBluetooth();
            },
            child: const Text('TRY AGAIN'),
          ),
        ],
      ),
    );
  }

  static Widget buildUnknownView(BuildContext context, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bluetooth_searching, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            Text(
              'Checking Bluetooth...',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            const Text(
              'Please wait while we check your Bluetooth status.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onRetry, // Correct usage
              child: const Text('RETRY'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildTurningOnView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          const Text(
            'Turning on Bluetooth...',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          const Text('Please wait while Bluetooth is enabled.'),
        ],
      ),
    );
  }

  static Widget buildTurningOffView(VoidCallback onEnableBluetooth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          const Text(
            'Bluetooth Turning Off',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          const Text('Bluetooth is currently turning off.'),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onEnableBluetooth, // Correct usage
            child: const Text('TURN BLUETOOTH ON'),
          ),
        ],
      ),
    );
  }

}