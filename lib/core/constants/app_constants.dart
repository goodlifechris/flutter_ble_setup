class AppConstants {
  static const String appName = 'BLE Scanner';
  static const Duration scanTimeout = Duration(seconds: 15);
  
  // Service UUIDs for device detection
  static const audioServiceUuids = {
    '0000110b', // Audio Sink
    '0000110a', // Audio Source
    '0000110d', // A/V Remote Control
    // ... add more
  };
  
  static const smartwatchServiceUuids = {
    '180d', // Heart Rate
    '180f', // Battery
    '1811', // Cycling Speed
    // ... add more
  };
}