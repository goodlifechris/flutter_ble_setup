enum DeviceFilter {
  all,
  audio,
  smartwatch,
}

extension DeviceFilterExtension on DeviceFilter {
  String get name {
    switch (this) {
      case DeviceFilter.all:
        return 'All Devices';
      case DeviceFilter.audio:
        return 'Audio Devices';
      case DeviceFilter.smartwatch:
        return 'Smartwatches';
    }
  }
}