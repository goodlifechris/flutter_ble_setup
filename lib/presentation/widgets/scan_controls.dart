import 'package:flutter/material.dart';

class ScanControls extends StatelessWidget {
  final bool isScanning;
  final int deviceCount;
  final VoidCallback onStartScan;
  final VoidCallback onStopScan;

  const ScanControls({
    super.key,
    required this.isScanning,
    required this.deviceCount,
    required this.onStartScan,
    required this.onStopScan,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: Icon(isScanning ? Icons.stop : Icons.search),
                    label: Text(isScanning ? 'STOP SCAN' : 'START SCAN'),
                    onPressed: isScanning ? onStopScan : onStartScan,
                  ),
                ),
              ],
            ),
            if (isScanning) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                'Scanning... Found $deviceCount devices',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}