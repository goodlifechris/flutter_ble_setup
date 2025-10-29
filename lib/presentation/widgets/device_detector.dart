import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceDetector {
  static bool isAudioDevice(AdvertisementData advert) {
    final audioServices = {
      '0000110b', // Audio Sink (speakers, headphones) - PRIMARY
      '0000110a', // Audio Source (microphones)
      '0000110d', // A/V Remote Control
      '0000110e', // A/V Remote Control Target
      '00001108', // Headset Profile
      '0000111e', // Hands-Free Profile
      '0000112d', // SIM Access
      '0000112f', // Phonebook Access
    };
    
    return advert.serviceUuids.any((uuid) {
      final uuidStr = uuid.toString().toLowerCase();
      return audioServices.any((audioUuid) => uuidStr.contains(audioUuid));
    });
  }

  static bool isSmartwatch(BluetoothDevice device, AdvertisementData advert) {
    final name = device.advName.toLowerCase();
    
    // Name-based filtering
    final watchNamePatterns = [
      'watch', 'fitbit', 'galaxy watch', 'gear', 'miband', 
      'amazfit', 'garmin', 'withings', 'polar', 'suunto',
      'fossil', 'huawei watch', 'ticwatch', 'coros', 'whoop',
      'sense', 'versa', 'charge', 'inspire', 'vivoactive',
    ];
    
    final hasWatchName = watchNamePatterns.any((pattern) => name.contains(pattern));

    // Service UUID filtering
    final smartwatchServiceUuids = {
      '180d', // Heart Rate Service
      '180f', // Battery Service
      '1810', // Blood Pressure
      '1811', // Cycling Speed and Cadence
      '1816', // Cycling Power
      '1818', // Indoor Positioning
      '181a', // Environmental Sensing
    };
    
    final hasWatchService = advert.serviceUuids.any((uuid) {
      final uuidStr = uuid.toString().toLowerCase();
      return smartwatchServiceUuids.any((serviceUuid) => uuidStr.contains(serviceUuid));
    });

    // Manufacturer-based detection
    final watchManufacturers = {
      0x004C, // Apple (Apple Watch)
      0x0064, // Garmin
      0x0075, // Samsung (Galaxy Watch)
      0x038F, // Fitbit
    };
    
    final hasWatchManufacturer = advert.manufacturerData.keys
        .any((key) => watchManufacturers.contains(key));

    return hasWatchName || hasWatchService || hasWatchManufacturer;
  }

  static String getDeviceType(BluetoothDevice device, AdvertisementData advert) {
    if (isAudioDevice(advert)) return 'Audio Device';
    if (isSmartwatch(device, advert)) return 'Smartwatch';
    
    final name = device.advName.toLowerCase();
    if (name.contains('phone') || name.contains('iphone')) return 'Phone';
    if (name.contains('tv') || name.contains('television')) return 'TV';
    if (name.contains('mac') || name.contains('laptop')) return 'Computer';
    
    return 'Unknown Device';
  }
}