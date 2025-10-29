import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../core/constants/app_constants.dart';

class DeviceDetector {
  static bool isAudioDevice(AdvertisementData advert) {
    return advert.serviceUuids.any((uuid) {
      final uuidStr = uuid.toString().toLowerCase();
      return AppConstants.audioServiceUuids.any((audioUuid) => uuidStr.contains(audioUuid));
    });
  }

  static bool isSmartwatch(BluetoothDevice device, AdvertisementData advert) {
    final name = device.advName.toLowerCase();
    
    final hasWatchName = _watchNamePatterns.any((pattern) => name.contains(pattern));
    final hasWatchService = _hasSmartwatchServices(advert);
    final hasWatchManufacturer = _hasSmartwatchManufacturer(advert);
    final hasHeartRateService = advert.serviceUuids.any((uuid) => 
        uuid.toString().toLowerCase().contains('180d'));

    return hasWatchName || hasWatchService || hasWatchManufacturer || hasHeartRateService;
  }

  static bool isHealthDevice(AdvertisementData advert) {
    return advert.serviceUuids.any((uuid) {
      final uuidStr = uuid.toString().toLowerCase();
      return _healthServiceUuids.any((healthUuid) => uuidStr.contains(healthUuid));
    });
  }

  static bool isFitnessDevice(AdvertisementData advert) {
    return advert.serviceUuids.any((uuid) {
      final uuidStr = uuid.toString().toLowerCase();
      return _fitnessServiceUuids.any((fitnessUuid) => uuidStr.contains(fitnessUuid));
    });
  }

  static String getDeviceType(BluetoothDevice device, AdvertisementData advert) {
    if (isAudioDevice(advert)) return 'Audio Device';
    if (isSmartwatch(device, advert)) return 'Smartwatch';
    if (isHealthDevice(advert)) return 'Health Device';
    if (isFitnessDevice(advert)) return 'Fitness Device';
    
    final name = device.advName.toLowerCase();
    if (name.contains('phone') || name.contains('iphone')) return 'Phone';
    if (name.contains('tv') || name.contains('television')) return 'TV';
    if (name.contains('keyboard') || name.contains('mouse')) return 'Input Device';
    
    return 'Unknown Device';
  }

  // Enhanced patterns and UUIDs
  static final _watchNamePatterns = [
    'watch', 'fitbit', 'galaxy watch', 'gear', 'miband', 
    'amazfit', 'garmin', 'withings', 'polar', 'suunto',
    'apple watch', 'wear', 'time', 'active',
  ];

  static final _healthServiceUuids = [
    '180d', // Heart Rate
    '1810', // Blood Pressure
    '181b', // Body Composition
    '181e', // Weight Scale
    '1820', // Internet Protocol Support (some health devices)
  ];

  static final _fitnessServiceUuids = [
    '1816', // Cycling Speed and Cadence
    '1818', // Cycling Power
    '1826', // Fitness Machine
    '1830', // Running Speed and Cadence
  ];

  static bool _hasSmartwatchServices(AdvertisementData advert) {
    return advert.serviceUuids.any((uuid) {
      final uuidStr = uuid.toString().toLowerCase();
      return AppConstants.smartwatchServiceUuids.any((serviceUuid) => uuidStr.contains(serviceUuid));
    });
  }

  static bool _hasSmartwatchManufacturer(AdvertisementData advert) {
    final watchManufacturers = {0x004C, 0x0064, 0x0075, 0x038F};
    return advert.manufacturerData.keys.any((key) => watchManufacturers.contains(key));
  }
}