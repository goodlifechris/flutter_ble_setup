# Flutter BLE Explorer 🔍

A powerful and intuitive Bluetooth Low Energy (BLE) scanner and explorer built with Flutter. Discover, connect, and interact with BLE devices through a beautiful and user-friendly interface.

![Flutter](https://img.shields.io/badge/Flutter-3.19-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.3-blue?logo=dart)
![BLE](https://img.shields.io/badge/BLE-Bluetooth%20Low%20Energy-blue?logo=bluetooth)

## ✨ Features

### 🔍 Smart Device Discovery
- **Advanced Scanning**: Scan for nearby BLE devices with real-time RSSI indicators
- **Device Classification**: Automatic detection of device types (Audio, Smartwatches, Health devices, etc.)
- **Smart Filtering**: Filter devices by category with visual counters
- **Signal Strength**: Visual RSSI indicators and distance estimation

### 📱 Beautiful User Interface
- **Modern Design**: Clean, material-design inspired interface
- **Device Cards**: Informative cards showing device name, type, signal strength, and connectability
- **Real-time Updates**: Live updating scan results with smooth animations
- **Dark/Light Theme**: Full theme support

### 🔧 Advanced BLE Operations
- **Service Discovery**: Automatically discover all GATT services and characteristics
- **Characteristic Interaction**: Read, write, and subscribe to characteristic values
- **Live Notifications**: Real-time updates from notify/indicate characteristics
- **Hex/ASCII Views**: Multiple data representation formats

### 📊 Comprehensive Logging
- **Operation Logging**: Detailed log of all BLE operations
- **Error Tracking**: Comprehensive error reporting and debugging
- **Data Visualization**: Beautiful display of characteristic values in hex and ASCII
- **Export Capabilities**: Log export for debugging and analysis

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.19 or higher)
- Dart (3.3 or higher)
- Android Studio / VS Code
- Physical device with Bluetooth 4.0+ (BLE support)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/flutter-ble-explorer.git
   cd flutter-ble-explorer

   flutter pub get 

   flutter run

