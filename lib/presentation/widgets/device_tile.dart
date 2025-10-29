import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../utils/device_detector.dart';
import 'signal_icon.dart';

class DeviceTile extends StatelessWidget {
  final ScanResult scanResult;
  final VoidCallback onTap;
  final VoidCallback onDetailsPressed;

  const DeviceTile({
    super.key,
    required this.scanResult,
    required this.onTap,
    required this.onDetailsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final device = scanResult.device;
    final deviceType = DeviceDetector.getDeviceType(device, scanResult.advertisementData);
    final isAudio = DeviceDetector.isAudioDevice(scanResult.advertisementData);
    final isSmartwatch = DeviceDetector.isSmartwatch(device, scanResult.advertisementData);
    print( "scanResult");
    print( scanResult);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SignalIcon(rssi: scanResult.rssi),
            const SizedBox(height: 2),
            _buildDeviceTypeIcon(deviceType),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                _getDeviceName(scanResult),
                style: const TextStyle(fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isAudio || isSmartwatch) ...[
              const SizedBox(width: 8),
              _buildDeviceTypeBadge(deviceType),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              device.remoteId.toString(),
              style: const TextStyle(fontSize: 12, fontFamily: 'Monospace'),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  '${scanResult.rssi} dBm',
                  style: TextStyle(
                    fontSize: 11,
                    color: _getRssiColor(scanResult.rssi),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  deviceType,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: FilledButton.tonal(
          onPressed: onDetailsPressed,
          style: FilledButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text(
            'DETAILS',
            style: TextStyle(fontSize: 12),
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDeviceTypeIcon(String deviceType) {
    IconData icon;
    Color color;
    
    switch (deviceType) {
      case 'Audio Device':
        icon = Icons.headphones;
        color = Colors.blue;
        break;
      case 'Smartwatch':
        icon = Icons.watch;
        color = Colors.green;
        break;
      case 'Phone':
        icon = Icons.phone_iphone;
        color = Colors.purple;
        break;
      case 'TV':
        icon = Icons.tv;
        color = Colors.orange;
        break;
      case 'Computer':
        icon = Icons.computer;
        color = Colors.red;
        break;
      default:
        icon = Icons.devices_other;
        color = Colors.grey;
    }
    
    return Icon(icon, size: 16, color: color);
  }

  Widget _buildDeviceTypeBadge(String deviceType) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getBadgeColor(deviceType),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getShortDeviceType(deviceType),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getBadgeColor(String deviceType) {
    switch (deviceType) {
      case 'Audio Device':
        return Colors.blue.shade600;
      case 'Smartwatch':
        return Colors.green.shade600;
      case 'Phone':
        return Colors.purple.shade600;
      case 'TV':
        return Colors.orange.shade600;
      case 'Computer':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  Color _getRssiColor(int rssi) {
    if (rssi > -60) return Colors.green.shade700;
    if (rssi > -70) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  String _getShortDeviceType(String deviceType) {
    switch (deviceType) {
      case 'Audio Device':
        return 'AUDIO';
      case 'Smartwatch':
        return 'WATCH';
      case 'Phone':
        return 'PHONE';
      case 'TV':
        return 'TV';
      case 'Computer':
        return 'PC';
      default:
        return deviceType.split(' ').first.toUpperCase();
    }
  }

  String _getDeviceName(ScanResult scanResult) {
    if (scanResult.device.advName.isNotEmpty) return scanResult.device.advName;
    if (scanResult.device.platformName.isNotEmpty) return scanResult.device.platformName;
    return 'Unknown Device';
  }
}