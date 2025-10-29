import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:flutter_ble/presentation/utils/ble_logger.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothService;
import '../../data/models/device_filter.dart';
import '../../data/services/bluetooth_service.dart'; // Add this import
import '../../device_detail_screen.dart';
import '../widgets/scan_controls.dart';
import '../widgets/search_filter.dart';
import '../widgets/device_list.dart';
import '../widgets/bluetooth_state_views.dart';
import '../widgets/filter_status.dart';
import '../utils/device_detector.dart';
import '../utils/permission_handler.dart';

class BleScannerScreen extends StatefulWidget {
  const BleScannerScreen({super.key});

  @override
  State<BleScannerScreen> createState() => _BleScannerScreenState();
}

class _BleScannerScreenState extends State<BleScannerScreen> {
  final BluetoothService _bluetoothService = BluetoothService(); // Fixed: removed .fromProto()
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = true;
  bool _isScanning = false;
  String _statusMessage = 'Initializing...';
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  final List<ScanResult> _scanResults = [];
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  
  DeviceFilter _currentFilter = DeviceFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
    _setupBluetoothListener();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeBluetooth() async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Checking Bluetooth support...';
      });

      if (!await _bluetoothService.isSupported) {
        setState(() => _statusMessage = 'Bluetooth LE not supported on this device');
        return;
      }

      final hasPermissions = await BlePermissionHandler.checkAndRequestPermissions();
      if (!hasPermissions) {
        setState(() => _statusMessage = 'Permissions required for Bluetooth scanning');
        return;
      }

      final initialState = await _bluetoothService.getCurrentAdapterState();
      setState(() {
        _adapterState = initialState;
        _updateStatusMessage();
      });

    } catch (e) {
      setState(() => _statusMessage = 'Initialization failed: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _setupBluetoothListener() {
    _bluetoothService.adapterState.listen((state) {
      setState(() {
        _adapterState = state;
        _updateStatusMessage();
      });
    });
  }

  void _updateStatusMessage() {
    switch (_adapterState) {
      case BluetoothAdapterState.on:
        _statusMessage = 'Ready to scan';
        _isLoading = false;
        break;
      case BluetoothAdapterState.off:
        _statusMessage = 'Bluetooth is disabled';
        _isLoading = false;
        break;
      case BluetoothAdapterState.unknown:
        _statusMessage = 'Checking Bluetooth...';
        _isLoading = true;
        break;
      case BluetoothAdapterState.turningOn:
        _statusMessage = 'Bluetooth turning on...';
        _isLoading = true;
        break;
      case BluetoothAdapterState.turningOff:
        _statusMessage = 'Bluetooth turning off...';
        _isLoading = true;
        break;
      default:
        _statusMessage = 'Unknown Bluetooth state';
        _isLoading = false;
    }
  }

  void _updateScanResults(List<ScanResult> newResults) {
    setState(() {
      for (final result in newResults) {
        final existingIndex = _scanResults.indexWhere(
          (r) => r.device.remoteId == result.device.remoteId
        );
        
        if (existingIndex >= 0) {
          _scanResults[existingIndex] = result;
        } else {
          _scanResults.add(result);
        }
      }
      _scanResults.sort((a, b) => (b.rssi).compareTo(a.rssi));
    });
  }

  // Filtering methods
  List<ScanResult> get _filteredDevices {
    var results = _applyDeviceTypeFilter(_scanResults);
    if (_searchQuery.isNotEmpty) {
      results = _applySearchFilter(results, _searchQuery);
    }
    return results;
  }

  List<ScanResult> _applyDeviceTypeFilter(List<ScanResult> devices) {
    switch (_currentFilter) {
      case DeviceFilter.audio:
        return devices.where((r) => DeviceDetector.isAudioDevice(r.advertisementData)).toList();
      case DeviceFilter.smartwatch:
        return devices.where((r) => DeviceDetector.isSmartwatch(r.device, r.advertisementData)).toList();
      default:
        return devices;
    }
  }

  List<ScanResult> _applySearchFilter(List<ScanResult> devices, String query) {
    final searchQuery = query.toLowerCase();
    return devices.where((result) {
      final name = _getDeviceName(result).toLowerCase();
      final deviceId = result.device.remoteId.toString().toLowerCase();
      final deviceType = DeviceDetector.getDeviceType(result.device, result.advertisementData).toLowerCase();
      
      return name.contains(searchQuery) ||
             deviceId.contains(searchQuery) ||
             deviceType.contains(searchQuery) ||
             _matchesSmartKeywords(result, searchQuery);
    }).toList();
  }

  bool _matchesSmartKeywords(ScanResult result, String query) {
    final keywordMap = {
      'audio': DeviceDetector.isAudioDevice(result.advertisementData),
      'watch': DeviceDetector.isSmartwatch(result.device, result.advertisementData),
      'smartwatch': DeviceDetector.isSmartwatch(result.device, result.advertisementData),
    };
    return keywordMap.entries.any((entry) => query.contains(entry.key) && entry.value);
  }

  int _getAudioDeviceCount() => _scanResults.where((r) => DeviceDetector.isAudioDevice(r.advertisementData)).length;
  int _getSmartwatchCount() => _scanResults.where((r) => DeviceDetector.isSmartwatch(r.device, r.advertisementData)).length;

  String _getDeviceName(ScanResult scanResult) {
    if (scanResult.device.advName.isNotEmpty) return scanResult.device.advName;
    if (scanResult.device.platformName.isNotEmpty) return scanResult.device.platformName;
    return 'Unknown Device';
  }

  void _navigateToDeviceDetail(ScanResult scanResult) {
  developer.log('log me 1', name: 'my.other.category');


    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DeviceDetailScreen(scanResult: scanResult),
      ),
    );
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _currentFilter = DeviceFilter.all;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
    setState(() => _statusMessage = message);
  }

  void _showBluetoothHelpDialog() { // Fixed: added underscore
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enable Bluetooth'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To enable Bluetooth:'),
            SizedBox(height: 12),
            Text('1. Open Settings app'),
            Text('2. Tap "Connections" or "Bluetooth"'),
            Text('3. Toggle Bluetooth ON'),
            SizedBox(height: 12),
            Text('Then return to this app.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _requestEnableBluetooth();
            },
            child: const Text('TRY AGAIN'),
          ),
        ],
      ),
    );
  }

  Future<void> _startScanning() async {
    try {
      setState(() {
        _isScanning = true;
        _scanResults.clear();
        _statusMessage = 'Scanning for devices...';
      });

      print('=== STARTING BLE SCAN ===');
      
      // Setup scan results listener
      _scanSubscription = _bluetoothService.scanResults.listen(
        (results) {
          print('Scan results received: ${results.length} devices');
          for (final result in results) {
            print('Device: ${result.device.remoteId}, RSSI: ${result.rssi}, Name: ${result.device.advName}');
          }
          if (results.isNotEmpty) {
            _updateScanResults(results);
          }
        },
        onError: (error) {
          print('Scan error: $error');
          _showError('Scan error: $error');
        },
      );

      // Start scanning
      await _bluetoothService.startScan(
        timeout: const Duration(seconds: 15),
      );

      print('=== SCAN STARTED SUCCESSFULLY ===');

    } catch (e) {
      print('Scan failed: $e');
      setState(() {
        _isScanning = false;
        _statusMessage = 'Scan failed: $e';
      });
    }
  }

  Future<void> _stopScanning() async {
    try {
      await _bluetoothService.stopScan();
      await _scanSubscription?.cancel();
      _scanSubscription = null;
      
      setState(() {
        _isScanning = false;
        _statusMessage = 'Scan stopped. Found ${_scanResults.length} devices';
      });
    } catch (e) {
      _showError('Stop scan failed: $e');
    }
  }

  Future<void> _requestEnableBluetooth() async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = 'Requesting Bluetooth enable...';
      });

      // This will show the native Bluetooth enable dialog
      await _bluetoothService.turnOn();

      // Wait for Bluetooth to actually turn on
      await _bluetoothService.adapterState
          .where((state) => state == BluetoothAdapterState.on)
          .first;

      setState(() {
        _statusMessage = 'Bluetooth enabled! Ready to scan.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to enable Bluetooth: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE Scanner'),
        actions: [
          if (_adapterState != BluetoothAdapterState.on)
            IconButton(
              icon: const Icon(Icons.bluetooth),
              onPressed: _requestEnableBluetooth,
              tooltip: 'Enable Bluetooth',
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    switch (_adapterState) {
      case BluetoothAdapterState.off:
        return BluetoothStateViews.buildOffView(context, _requestEnableBluetooth);
      case BluetoothAdapterState.on:
        return _buildReadyView();
      case BluetoothAdapterState.turningOn:
        return BluetoothStateViews.buildTurningOnView();
      case BluetoothAdapterState.turningOff:
        return BluetoothStateViews.buildTurningOffView(_requestEnableBluetooth);
      default:
        return BluetoothStateViews.buildUnknownView(context, _initializeBluetooth);
    }
  }

  Widget _buildReadyView() {
    return Column(
      children: [
        ScanControls(
          isScanning: _isScanning,
          deviceCount: _scanResults.length,
          onStartScan: _startScanning,
          onStopScan: _stopScanning,
        ),
        SearchFilter(
          searchController: _searchController,
          searchQuery: _searchQuery,
          currentFilter: _currentFilter,
          totalDevices: _scanResults.length,
          audioDeviceCount: _getAudioDeviceCount(),
          smartwatchCount: _getSmartwatchCount(),
          onSearchChanged: (value) => setState(() => _searchQuery = value),
          onFilterChanged: (filter) => setState(() => _currentFilter = filter ?? DeviceFilter.all),
        ),
        FilterStatus(
          searchQuery: _searchQuery,
          currentFilter: _currentFilter,
          onClearFilters: _clearFilters,
        ),
        Expanded(
          child: DeviceList(
            scanResults: _filteredDevices,
            isLoading: _isScanning,
            onDeviceTap: _navigateToDeviceDetail,
            onStartScan: _startScanning,
          ),
        ),
      ],
    );
  }
}