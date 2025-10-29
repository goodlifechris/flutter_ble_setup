// utils/ble_logger.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLELogger {
  static final List<BLELogEntry> _logEntries = [];
  static final StreamController<BLELogEntry> _logStreamController = 
      StreamController<BLELogEntry>.broadcast();

  static Stream<BLELogEntry> get logStream => _logStreamController.stream;

  static void logOperation({
    required String operation,
    required String deviceId,
    required String characteristicUuid,
    List<int>? data,
    String? additionalInfo,
    bool isError = false,
  }) {
    final entry = BLELogEntry(
      timestamp: DateTime.now(),
      operation: operation,
      deviceId: deviceId,
      characteristicUuid: characteristicUuid,
      data: data,
      additionalInfo: additionalInfo,
      isError: isError,
    );

    _logEntries.add(entry);
    _logStreamController.add(entry);

    // Also print to console for debugging
    if (kDebugMode) {
      print('🔵 BLE LOG: ${entry.toString()}');
    }
  }

  static List<BLELogEntry> getLogs() => List.unmodifiable(_logEntries);
  
  static void clearLogs() {
    _logEntries.clear();
  }

  static void dispose() {
    _logStreamController.close();
  }

  // Add these static helper methods to the BLELogger class
  static String bytesToHex(List<int> bytes) {
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
  }

  static String bytesToAscii(List<int> bytes) {
    try {
      return String.fromCharCodes(bytes.where((byte) => byte >= 32 && byte <= 126));
    } catch (e) {
      return 'Invalid ASCII data';
    }
  }
}

class BLELogEntry {
  final DateTime timestamp;
  final String operation;
  final String deviceId;
  final String characteristicUuid;
  final List<int>? data;
  final String? additionalInfo;
  final bool isError;

  BLELogEntry({
    required this.timestamp,
    required this.operation,
    required this.deviceId,
    required this.characteristicUuid,
    this.data,
    this.additionalInfo,
    this.isError = false,
  });

  // Instance methods that use the static helper methods
  String get dataHex => data != null ? BLELogger.bytesToHex(data!) : 'No data';
  String get dataAscii => data != null ? BLELogger.bytesToAscii(data!) : 'No data';

@override
String toString() {
  // Safe substring that won't crash if strings are too short
  String safeSubstring(String text, int length) {
    return text.length > length ? text.substring(0, length) : text;
  }

  return '[${timestamp.toIso8601String()}] '
      '${isError ? '❌' : '✅'} $operation | '
      'Device: ${safeSubstring(deviceId, 8)}... | '
      'Char: ${safeSubstring(characteristicUuid, 8)}... | '
      'Data: $dataHex | '
      '${additionalInfo ?? ''}';
}
}