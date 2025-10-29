import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ble/core/utils/snackbar_util.dart';
import 'package:flutter_ble/presentation/utils/ble_logger.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_ble/core/utils/snackbar_util.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceDetailScreen extends StatefulWidget {
  final ScanResult scanResult;
  
  const DeviceDetailScreen({super.key, required this.scanResult});

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  // Connection state management
  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  
  // Service discovery
  List<BluetoothService> _services = [];
  bool _isDiscoveringServices = false;
  
  // UI state
  bool _isConnecting = false;
  String _errorMessage = '';
  Timer? _connectionTimeoutTimer;

  @override
  void initState() {
    super.initState();
    _setupConnectionListener();
    _checkInitialConnection();
  }
  
  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _connectionTimeoutTimer?.cancel();
    super.dispose();
  }

  void _checkInitialConnection() async {
    // Check if device is already connected when screen opens
    try {
      final state = await widget.scanResult.device.connectionState.first;
      if (state == BluetoothConnectionState.connected) {
        _discoverServices();
      }
    } catch (e) {
      print('Error checking initial connection: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getDeviceName(widget.scanResult)),
        actions: [
          if (_connectionState == BluetoothConnectionState.connected)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshServices,
              tooltip: 'Refresh Services',
            ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Error Banner
            if (_errorMessage.isNotEmpty) _buildErrorBanner(),
            
            // Device Information Section
            _buildDeviceInfo(),
            const SizedBox(height: 24),
            
            // Connection Control Section
            _buildConnectionControl(),
            const SizedBox(height: 24),
            
            // Services Section
            _buildServicesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage,
              style: TextStyle(color: Colors.red.shade800),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 16, color: Colors.red.shade600),
            onPressed: () => setState(() => _errorMessage = ''),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Services',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (_services.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: Text('${_services.length} found'),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            
            if (_isDiscoveringServices) ...[
              _buildDiscoveringServices(),
            ] else if (_services.isEmpty && _connectionState == BluetoothConnectionState.connected) ...[
              _buildNoServicesFound(),
            ] else if (_services.isEmpty) ...[
              _buildConnectToDiscover(),
            ] else ...[
              _buildServicesList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildServicesList() {
    print("_services");
        print(_services);

    return Column(
      children: _services.map((service) => _buildServiceTile(service)).toList(),
    );
  }

  Widget _buildDiscoveringServices() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Discovering Services...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we discover available services',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoServicesFound() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Icon(Icons.warning_amber, size: 48, color: Colors.orange.shade600),
          const SizedBox(height: 16),
          Text(
            'No Services Found',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.orange.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This device doesn\'t have any discoverable services',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.tonal(
            onPressed: _refreshServices,
            child: const Text('TRY AGAIN'),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectToDiscover() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Icon(Icons.bluetooth_disabled, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Not Connected',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Connect to discover services and characteristics',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _connectToDevice,
            child: const Text('CONNECT TO DISCOVER'),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTile(BluetoothService service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          _formatUuid(service.uuid.toString()),
          style: const TextStyle(fontSize: 14, fontFamily: 'Monospace'),
        ),
        subtitle: Text('${service.characteristics.length} characteristic(s)'),
        children: service.characteristics
            .map((characteristic) => _buildCharacteristicTile(characteristic))
            .toList(),
      ),
    );
  }

Widget _buildCharacteristicTile(BluetoothCharacteristic characteristic) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(8),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        _getCharacteristicName(characteristic.uuid.toString()), // NEW: Human readable names
        style: const TextStyle(fontSize: 12, fontFamily: 'Monospace'),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatUuid(characteristic.uuid.toString()),
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          _buildCharacteristicProperties(characteristic),
          const SizedBox(height: 4),
          _buildCharacteristicValue(characteristic), // NEW: Show the value!
        ],
      ),
      trailing: _buildCharacteristicActions(characteristic),
    ),
  );
}
Widget _buildCharacteristicValue(BluetoothCharacteristic characteristic) {
  // If we've read a value, display it
  if (characteristic.lastValue.isNotEmpty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Value: ${BLELogger.bytesToHex(characteristic.lastValue)}',
          style: TextStyle(fontSize: 10, color: Colors.green.shade700),
        ),
        Text(
          'ASCII: "${BLELogger.bytesToAscii(characteristic.lastValue)}"',
          style: TextStyle(fontSize: 10, color: Colors.blue.shade700),
        ),
      ],
    );
  }
  
  // Show what the characteristic can do
  final props = characteristic.properties;
  final capabilities = <String>[];
  if (props.read) capabilities.add('Tap Read to get value');
  if (props.write) capabilities.add('Can write data');
  if (props.notify) capabilities.add('Can enable notifications');
  
  return Text(
    capabilities.join(' • '),
    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
  );
}
String _getCharacteristicName(String uuid) {
  // Common BLE characteristic UUIDs and their names
  switch (uuid.toLowerCase()) {
    case '2a00': return 'Device Name';
    case '2a01': return 'Appearance';
    case '2a02': return 'Peripheral Privacy Flag';
    case '2a03': return 'Reconnection Address';
    case '2a04': return 'Peripheral Preferred Connection Parameters';
    case '2a05': return 'Service Changed';
    case '2a19': return 'Battery Level';
    case '2a24': return 'Model Number';
    case '2a25': return 'Serial Number';
    case '2a26': return 'Firmware Revision';
    case '2a27': return 'Hardware Revision';
    case '2a28': return 'Software Revision';
    case '2a29': return 'Manufacturer Name';
    case '2a2a': return 'IEEE 11073-20601 Regulatory Certification';
    case '2a50': return 'PnP ID';
    default: return _formatUuid(uuid);
  }
}
Widget _buildCharacteristicProperties(BluetoothCharacteristic characteristic) {
    final properties = <String>[];
    final props = characteristic.properties;
    
    if (props.read) properties.add('Read');
    if (props.write) properties.add('Write');
    if (props.writeWithoutResponse) properties.add('Write No Response');
    if (props.notify) properties.add('Notify');
    if (props.indicate) properties.add('Indicate');
    
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: properties
          .map((prop) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Text(
                  prop,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget? _buildCharacteristicActions(BluetoothCharacteristic characteristic) {
    final props = characteristic.properties;
    final hasActions = props.read || props.notify || props.indicate;
    
    if (!hasActions) return null;
    
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      itemBuilder: (context) => [
        if (props.read)
          const PopupMenuItem(value: 'read', child: Text('Read Value')),
        if (props.notify)
          const PopupMenuItem(value: 'notify', child: Text('Toggle Notify')),
        if (props.indicate)
          const PopupMenuItem(value: 'indicate', child: Text('Toggle Indicate')),
      ],
      onSelected: (value) => _handleCharacteristicAction(characteristic, value),
    );
  }

void _handleCharacteristicAction(BluetoothCharacteristic characteristic, String action) async {
  final deviceId = widget.scanResult.device.remoteId.toString();
  final charUuid = characteristic.uuid.toString();
  
  try {
    switch (action) {
      case 'read':
        BLELogger.logOperation(
          operation: 'READ_ATTEMPT',
          deviceId: deviceId,
          characteristicUuid: charUuid,
          additionalInfo: 'Reading characteristic value',
        );

        final value = await characteristic.read();
        
        BLELogger.logOperation(
          operation: 'READ_SUCCESS',
          deviceId: deviceId,
          characteristicUuid: charUuid,
          data: value,
          additionalInfo: 'Read ${value.length} bytes',
        );

        // Force UI refresh to show the new value
        setState(() {});
        
        _showSuccess('Read ${value.length} bytes: ${BLELogger.bytesToHex(value)}');
        break;

      case 'notify':
        final newState = !characteristic.isNotifying;
        BLELogger.logOperation(
          operation: 'NOTIFY_${newState ? 'ENABLE_ATTEMPT' : 'DISABLE_ATTEMPT'}',
          deviceId: deviceId,
          characteristicUuid: charUuid,
          additionalInfo: 'Toggling notifications',
        );

        // Set up listener before enabling
        if (newState) {
          characteristic.onValueReceived.listen((value) {
            BLELogger.logOperation(
              operation: 'NOTIFICATION_RECEIVED',
              deviceId: deviceId,
              characteristicUuid: charUuid,
              data: value,
              additionalInfo: 'Notification received',
            );
            // Refresh UI when notification comes in
            setState(() {});
          });
        }

        await characteristic.setNotifyValue(newState);
        
        BLELogger.logOperation(
          operation: 'NOTIFY_${newState ? 'ENABLED' : 'DISABLED'}',
          deviceId: deviceId,
          characteristicUuid: charUuid,
          additionalInfo: 'Notifications ${newState ? 'enabled' : 'disabled'}',
        );

        setState(() {}); // Refresh UI to show notification state
        _showSuccess('Notifications ${newState ? 'enabled' : 'disabled'}');
        break;

      case 'indicate':
        // Similar to notify but with indications
        final newState = !characteristic.isNotifying;
        await characteristic.setNotifyValue(newState);
        setState(() {});
        _showSuccess('Indications ${newState ? 'enabled' : 'disabled'}');
        break;
    }
  } catch (e) {
    BLELogger.logOperation(
      operation: '${action.toUpperCase()}_FAILED',
      deviceId: deviceId,
      characteristicUuid: charUuid,
      additionalInfo: 'Error: $e',
      isError: true,
    );
    _showError('${action} failed: $e');
  }
}
Future<void> _readCharacteristic(BluetoothCharacteristic characteristic) async {
  final deviceId = widget.scanResult.device.remoteId.toString();
  final charUuid = characteristic.uuid.toString();
  
  try {
    // Log read attempt
    BLELogger.logOperation(
      operation: 'READ_ATTEMPT',
      deviceId: deviceId,
      characteristicUuid: charUuid,
      additionalInfo: 'Initiating read operation',
    );

    _showSuccess('Reading characteristic...');
    
    final value = await characteristic.read();
    
    // Log successful read
    // Log successful read - FIXED ASCII CALL
    BLELogger.logOperation(
      operation: 'READ_SUCCESS',
      deviceId: deviceId,
      characteristicUuid: charUuid,
      data: value,
      additionalInfo: 'Read ${value.length} bytes | ASCII: "${BLELogger.bytesToAscii(value)}"',
    );

    _showSuccess('Read ${value.length} bytes');
    
  } catch (e) {
    // Log read failure
    BLELogger.logOperation(
      operation: 'READ_FAILED',
      deviceId: deviceId,
      characteristicUuid: charUuid,
      additionalInfo: 'Error: $e',
      isError: true,
    );

    _showError('Read failed: $e');
  }
}
  
  Future<void> _toggleNotification(BluetoothCharacteristic characteristic) async {
    try {
      await characteristic.setNotifyValue(!characteristic.isNotifying);
      _showSuccess('Notifications ${characteristic.isNotifying ? 'enabled' : 'disabled'}');
    } catch (e) {
      _showError('Notification toggle failed: $e');
    }
  }

  Future<void> _toggleIndication(BluetoothCharacteristic characteristic) async {
    // Similar to notification toggle
  }

  Widget _buildDeviceInfo() {
    final device = widget.scanResult.device;
    final advData = widget.scanResult.advertisementData;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Name', _getDeviceName(widget.scanResult)),
            _buildInfoRow('Address', device.remoteId.toString()),
            _buildInfoRow('RSSI', '${widget.scanResult.rssi} dBm'),
            _buildInfoRow('Connectable', advData.connectable ? 'Yes' : 'No'),
            if (advData.txPowerLevel != null)
              _buildInfoRow('TX Power', '${advData.txPowerLevel} dBm'),
            if (advData.serviceUuids.isNotEmpty)
              _buildInfoRow('Service UUIDs', '${advData.serviceUuids.length} advertised'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildConnectionControl() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Connection',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            
            // Connection Status
            _buildConnectionStatus(),
            const SizedBox(height: 16),
            
            // Connect/Disconnect Button
            _buildConnectionButton(),
          ],
        ),
      ),
    );
  }

String _getDeviceName(ScanResult scanResult) {
  print("🔍 Analyzing scan result for device name...");
  print("ScanResult: $scanResult");
  
  // Try different name sources in order of preference
  if (scanResult.device.advName.isNotEmpty) {
    print("✅ Using advName: ${scanResult.device.advName}");
    return scanResult.device.advName;
  }
  
  if (scanResult.device.platformName.isNotEmpty) {
    print("✅ Using platformName: ${scanResult.device.platformName}");
    return scanResult.device.platformName;
  }
  
  // Analyze service data for clues about device type
  final serviceData = scanResult.advertisementData.serviceData;
  if (serviceData.isNotEmpty) {
    print("🔧 No direct name found, analyzing service data...");
    final deviceType = _analyzeServiceData(serviceData);
    final shortAddress = _getShortAddress(scanResult.device.remoteId.toString());
    print("🎯 Identified as: $deviceType");
    return '$deviceType ($shortAddress)';
  }
  
  // Check manufacturer data
  final manufacturerData = scanResult.advertisementData.manufacturerData;
  if (manufacturerData.isNotEmpty) {
    print("🏭 Manufacturer data available: $manufacturerData");
    final shortAddress = _getShortAddress(scanResult.device.remoteId.toString());
    return 'Manufacturer Device ($shortAddress)';
  }
  
  // Last resort - use address with generic name
  final shortAddress = _getShortAddress(scanResult.device.remoteId.toString());
  final rssi = scanResult.rssi;
  print("❌ No identifying data found, using generic name");
  return 'BLE Device ($shortAddress) [${rssi}dBm]';
}

String _getShortAddress(String fullAddress) {
  // Extract last 6 characters of MAC address (e.g., "34:C2" from "18:BB:64:09:34:C2")
  try {
    final parts = fullAddress.split(':');
    if (parts.length >= 2) {
      return '${parts[parts.length - 2]}:${parts[parts.length - 1]}';
    }
    return fullAddress.length > 8 ? fullAddress.substring(9) : fullAddress;
  } catch (e) {
    return fullAddress;
  }
}

// FIXED: Use Guid instead of String for the map key
String _analyzeServiceData(Map<Guid, List<int>> serviceData) {
  print("🔬 Analyzing service data: $serviceData");
  
  for (var entry in serviceData.entries) {
    final uuid = entry.key;
    final data = entry.value;
    
    // Convert Guid to String for analysis
    final uuidString = uuid.toString().toLowerCase();
    
    print("📊 Service UUID: $uuidString, Data: ${data.length} bytes");
    print("🔢 Hex: ${_bytesToHex(data)}");
    
    // Try to extract ASCII characters
    final asciiString = _extractAscii(data);
    if (asciiString.isNotEmpty) {
      print("🔤 ASCII found: $asciiString");
    }
    
    // Analyze based on UUID and data patterns
    return _decodeDeviceType(uuidString, data);
  }
  
  return 'Unknown BLE Device';
}

String _decodeDeviceType(String uuid, List<int> data) {
  // Remove dashes for comparison (Guid might include them)
  final cleanUuid = uuid.replaceAll('-', '');
  
  // Common BLE service UUIDs and their typical devices
  switch (cleanUuid) {
    case 'fcf1':
      if (data.length == 21) {
        return 'Measurement Sensor';
      }
      return 'Custom Sensor';
      
    case '180a': // Device Information
      return 'Info Device';
      
    case '180f': // Battery Service
      return 'Battery Monitor';
      
    case '181a': // Environmental Sensing
      if (data.isNotEmpty && data[0] == 0x04) return 'Thermometer';
      return 'Environmental Sensor';
      
    case '1816': // Cycling Speed and Cadence
      return 'Fitness Sensor';
      
    case '1818': // Cycling Power
      return 'Power Meter';
      
    case '1810': // Blood Pressure
      return 'Health Monitor';
      
    default:
      // Guess based on data length and patterns
      if (data.isEmpty) return 'Beacon Device';
      if (data.length <= 8) return 'Simple Sensor';
      if (data.length <= 16) return 'Data Logger';
      if (data.length <= 24) return 'Telemetry Device';
      return 'Complex BLE Device';
  }
}

String _bytesToHex(List<int> bytes) {
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(' ');
}

String _extractAscii(List<int> data) {
  try {
    final asciiChars = data.where((byte) => byte >= 32 && byte <= 126);
    return String.fromCharCodes(asciiChars);
  } catch (e) {
    return '';
  }
}


  String _formatUuid(String uuid) {
    // Format UUID for better readability
    if (uuid.length == 32) {
      return '${uuid.substring(0, 8)}-${uuid.substring(8, 12)}-${uuid.substring(12, 16)}-${uuid.substring(16, 20)}-${uuid.substring(20)}';
    }
    return uuid;
  }

  Widget _buildConnectionStatus() {
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (_connectionState) {
      case BluetoothConnectionState.connected:
        statusColor = Colors.green;
        statusText = 'Connected';
        statusIcon = Icons.check_circle;
        break;
      case BluetoothConnectionState.connecting:
        statusColor = Colors.orange;
        statusText = 'Connecting...';
        statusIcon = Icons.pending;
        break;
      case BluetoothConnectionState.disconnecting:
        statusColor = Colors.orange;
        statusText = 'Disconnecting...';
        statusIcon = Icons.pending;
        break;
      case BluetoothConnectionState.disconnected:
      default:
        statusColor = Colors.grey;
        statusText = 'Disconnected';
        statusIcon = Icons.cancel;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Status: $statusText', style: TextStyle(fontWeight: FontWeight.w500)),
                if (_connectionState == BluetoothConnectionState.connected)
                  Text(
                    'Tap refresh to rediscover services',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionButton() {
    final isConnected = _connectionState == BluetoothConnectionState.connected;
    final isConnecting = _connectionState == BluetoothConnectionState.connecting || _isConnecting;
    
    if (isConnecting) {
      return FilledButton(
        onPressed: _cancelConnection,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.grey,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            const Text('Connecting...'),
          ],
        ),
      );
    }
    
    return FilledButton(
      onPressed: isConnected ? _disconnectFromDevice : _connectToDevice,
      style: FilledButton.styleFrom(
        backgroundColor: isConnected ? Colors.red : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isConnected ? Icons.bluetooth_disabled : Icons.bluetooth),
          const SizedBox(width: 8),
          Text(isConnected ? 'DISCONNECT' : 'CONNECT'),
        ],
      ),
    );
  }

  void _setupConnectionListener() {
    _connectionSubscription = widget.scanResult.device.connectionState.listen((state) {
      setState(() => _connectionState = state);
      
      // Handle automatic service discovery on connection
      if (state == BluetoothConnectionState.connected) {
        _connectionTimeoutTimer?.cancel();
        _discoverServices();
      }
      
      // Handle unexpected disconnections
      if (state == BluetoothConnectionState.disconnected && _isConnecting) {
        _showError('Connection failed or was lost');
      }
      
      setState(() => _isConnecting = false);
    });
  }

  Future<void> _connectToDevice() async {
    try {
      setState(() {
        _isConnecting = true;
        _errorMessage = '';
      });
      
      // Set connection timeout
      _connectionTimeoutTimer = Timer(const Duration(seconds: 10), () {
        if (_isConnecting) {
          _showError('Connection timeout');
          setState(() => _isConnecting = false);
        }
      });
      
      await widget.scanResult.device.connect();
      
    } catch (e) {
      _showError('Connection failed: ${e.toString()}');
    }
  }

  void _cancelConnection() async {
    try {
      await widget.scanResult.device.disconnect();
    } catch (e) {
      print('Cancel connection error: $e');
    } finally {
      setState(() => _isConnecting = false);
      _connectionTimeoutTimer?.cancel();
    }
  }

  Future<void> _disconnectFromDevice() async {
    try {
      await widget.scanResult.device.disconnect();
      setState(() => _services.clear());
    } catch (e) {
      _showError('Disconnect failed: ${e.toString()}');
    }
  }

  Future<void> _discoverServices() async {
    try {
      setState(() => _isDiscoveringServices = true);
      _services = await widget.scanResult.device.discoverServices();
      _showSuccess('Found ${_services.length} services');
    } catch (e) {
      _showError('Service discovery failed: ${e.toString()}');
    } finally {
      setState(() => _isDiscoveringServices = false);
    }
  }

  Future<void> _refreshServices() async {
    if (_connectionState == BluetoothConnectionState.connected) {
      await _discoverServices();
    }
  }

  void _showError(String message) {
    SnackBarUtils.showError(context: context, message: message);
    setState(() => _errorMessage = message);
  }

  void _showSuccess(String message) {
    SnackBarUtils.showSuccess(context: context, message: message);
  }
}