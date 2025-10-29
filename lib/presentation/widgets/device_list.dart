import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'device_tile.dart';

class DeviceList extends StatelessWidget {
  final List<ScanResult> scanResults;
  final bool isLoading;
  final VoidCallback onStartScan;
  final Function(ScanResult) onDeviceTap;

  const DeviceList({
    super.key,
    required this.scanResults,
    required this.isLoading,
    required this.onDeviceTap,
    required this.onStartScan,
  });

  @override
  Widget build(BuildContext context) {
    if (scanResults.isEmpty && !isLoading) {
      return _buildEmptyState();
    }

    return ListView.builder(
      itemCount: scanResults.length,
      itemBuilder: (context, index) {
        final scanResult = scanResults[index];
        return DeviceTile(
          scanResult: scanResult,
          onTap: () => onDeviceTap(scanResult),
          onDetailsPressed: () => onDeviceTap(scanResult),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bluetooth_searching, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No Devices Found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start scanning to discover nearby BLE devices',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onStartScan,
            child: const Text('START SCANNING'),
          ),
        ],
      ),
    );
  }
}