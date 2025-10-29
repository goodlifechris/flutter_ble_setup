import 'package:flutter/material.dart';

class SignalIcon extends StatelessWidget {
  final int rssi;
  final double size;

  const SignalIcon({
    super.key,
    required this.rssi,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      _getSignalIcon(rssi),
      size: size,
      color: _getSignalColor(rssi),
    );
  }

  IconData _getSignalIcon(int rssi) {
    if (rssi > -60) {
      return Icons.wifi; // Strong signal
    } else if (rssi > -70) {
      return Icons.network_wifi_3_bar; // Good signal
    } else if (rssi > -80) {
      return Icons.network_wifi_2_bar; // Fair signal
    } else {
      return Icons.network_wifi_1_bar; // Weak signal
    }
  }

  Color _getSignalColor(int rssi) {
    if (rssi > -60) {
      return Colors.green.shade600; // Strong - Green
    } else if (rssi > -70) {
      return Colors.orange.shade600; // Good - Orange
    } else if (rssi > -80) {
      return Colors.orange.shade600; // Fair - Orange
    } else {
      return Colors.red.shade600; // Weak - Red
    }
  }
}