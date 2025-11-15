import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'lifecycle_manager.dart';

enum ConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

enum ConnectionType {
  websocket,
  polling,
}

class ConnectionManager {
  // Singleton pattern
  static ConnectionManager? _instance;
  factory ConnectionManager() => _instance ??= ConnectionManager._internal();
  ConnectionManager._internal() {
    _lifecycleManager = LifecycleManager();
    _setupLifecycleListeners();
  }

  // Connection state
  ConnectionStatus _status = ConnectionStatus.disconnected;
  ConnectionType _connectionType = ConnectionType.polling;
  
  // Session management
  String? _sessionId;
  DateTime? _lastSuccessfulUpdate;
  
  // Configuration
  String? _apiBaseUrl;
  String? _esp32Ip;
  String _sensorType = '';
  Duration _updateInterval = const Duration(seconds: 58);
  
  // Lifecycle management
  late LifecycleManager _lifecycleManager;
  bool _respectLifecycle = true;
  
  // Timers and retry logic
  Timer? _pollingTimer;
  Timer? _reconnectTimer;
  int _retryAttempts = 0;
  final int _maxRetryAttempts = 5;
  final Duration _baseRetryDelay = const Duration(seconds: 2);
  
  // Data streams
  final StreamController<Map<String, dynamic>> _dataStreamController = StreamController.broadcast();
  final StreamController<ConnectionStatus> _statusStreamController = StreamController.broadcast();
  
  // Getters
  ConnectionStatus get status => _status;
  ConnectionType get connectionType => _connectionType;
  String? get sessionId => _sessionId;
  DateTime? get lastSuccessfulUpdate => _lastSuccessfulUpdate;
  bool get isConnected => _status == ConnectionStatus.connected;
  
  // Streams
  Stream<Map<String, dynamic>> get dataStream => _dataStreamController.stream;
  Stream<ConnectionStatus> get statusStream => _statusStreamController.stream;

  // Initialize connection
  Future<void> initialize({
    required String? apiBaseUrl,
    required String? esp32Ip,
    required String sensorType,
    Duration? updateInterval,
    bool respectLifecycle = true,
  }) async {
    _apiBaseUrl = apiBaseUrl;
    _esp32Ip = esp32Ip;
    _sensorType = sensorType;
    _updateInterval = updateInterval ?? const Duration(seconds: 58);
    _respectLifecycle = respectLifecycle;
    
    debugPrint('=== INICIALIZANDO CONNECTION MANAGER ===');
    debugPrint('API URL: $_apiBaseUrl');
    debugPrint('ESP32 IP: $_esp32Ip');
    debugPrint('Sensor Type: $_sensorType');
    debugPrint('Update Interval: ${_updateInterval.inSeconds}s');
    debugPrint('Respect Lifecycle: $_respectLifecycle');
    
    // Configure lifecycle manager
    if (_respectLifecycle) {
      _lifecycleManager.configureUpdateIntervals(
        foregroundInterval: const Duration(seconds: 58),
        backgroundInterval: const Duration(minutes: 5),
      );
    }
    
    await _determineConnectionType();
    await _startConnection();
  }

  // Determine connection type based on available endpoints
  Future<void> _determineConnectionType() async {
    if (_apiBaseUrl != null && _apiBaseUrl!.isNotEmpty) {
      // For now, always use HTTP polling - WebSocket support can be added later
      _connectionType = ConnectionType.polling;
      debugPrint('Connection type: HTTP Polling');
    } else if (_esp32Ip != null && _esp32Ip!.isNotEmpty) {
      _connectionType = ConnectionType.polling;
      debugPrint('Connection type: ESP32 Polling');
    } else {
      throw Exception('No connection configuration available');
    }
  }

  // Setup lifecycle listeners
  void _setupLifecycleListeners() {
    _lifecycleManager.foregroundStream.listen((isForeground) {
      if (_status == ConnectionStatus.connected && _connectionType == ConnectionType.polling) {
        debugPrint('Lifecycle changed - adjusting polling interval');
        _adjustPollingForLifecycle();
      }
    });
  }

  // Adjust polling based on lifecycle state
  void _adjustPollingForLifecycle() {
    if (_pollingTimer != null) {
      _pollingTimer?.cancel();
      
      final newInterval = _lifecycleManager.getRecommendedUpdateInterval();
      debugPrint('Adjusting polling to ${newInterval.inSeconds}s interval');
      
      _pollingTimer = Timer.periodic(newInterval, (_) async {
        if (_status == ConnectionStatus.connected) {
          await _performPollingRequest();
        }
      });
    }
  }

  // Start connection based on type
  Future<void> _startConnection() async {
    _updateStatus(ConnectionStatus.connecting);
    
    try {
      switch (_connectionType) {
        case ConnectionType.polling:
          await _startPolling();
          break;
        case ConnectionType.websocket:
          // WebSocket not implemented yet - fall back to polling
          debugPrint('WebSocket not implemented, using polling instead');
          await _startPolling();
          break;
      }
    } catch (e) {
      debugPrint('Connection start failed: $e');
      _handleConnectionError(e);
    }
  }

  // HTTP Polling implementation
  Future<void> _startPolling() async {
    final effectiveInterval = _respectLifecycle 
        ? _lifecycleManager.getRecommendedUpdateInterval()
        : _updateInterval;
        
    debugPrint('Starting HTTP polling with interval: ${effectiveInterval.inSeconds}s');

    // Initial data fetch
    await _performPollingRequest();

    // Set up periodic polling with lifecycle-aware intervals
    _pollingTimer = Timer.periodic(effectiveInterval, (_) async {
      if (_status == ConnectionStatus.connected) {
        // Check if update is needed based on lifecycle
        if (!_respectLifecycle || _lifecycleManager.shouldUpdateData(lastUpdate: _lastSuccessfulUpdate)) {
          await _performPollingRequest();
        } else {
          debugPrint('Skipping update - data still fresh for current lifecycle state');
        }
      }
    });

    _updateStatus(ConnectionStatus.connected);
    _retryAttempts = 0;
  }

  // Perform polling request
  Future<void> _performPollingRequest() async {
    try {
      Map<String, dynamic>? data;
      
      if (_apiBaseUrl != null && _apiBaseUrl!.isNotEmpty) {
        // API polling
        data = await _fetchApiData();
      } else if (_esp32Ip != null && _esp32Ip!.isNotEmpty) {
        // ESP32 polling
        data = await _fetchEsp32Data();
      }
      
      if (data != null) {
        _lastSuccessfulUpdate = DateTime.now();
        _dataStreamController.add(data);
      }
    } catch (e) {
      debugPrint('Polling request failed: $e');
      _handleConnectionError(e);
    }
  }

  // Fetch data from API
  Future<Map<String, dynamic>?> _fetchApiData() async {
    try {
      final uri = Uri.parse('$_apiBaseUrl?endpoint=last1min');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('API returned status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('API fetch failed: $e');
    }
  }

  // Fetch data from ESP32
  Future<Map<String, dynamic>?> _fetchEsp32Data() async {
    try {
      final url = "$_esp32Ip/$_sensorType";
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        return {
          'sensor': _sensorType,
          'value': json.decode(response.body)[_sensorType],
          'timestamp': DateTime.now().toIso8601String(),
          'source': 'esp32',
        };
      } else {
        throw Exception('ESP32 returned status ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('ESP32 fetch failed: $e');
    }
  }

  // Handle connection errors with exponential backoff
  void _handleConnectionError(dynamic error) {
    debugPrint('Connection error: $error');
    _updateStatus(ConnectionStatus.error);
    
    if (_retryAttempts < _maxRetryAttempts) {
      _retryAttempts++;
      final retryDelay = Duration(
        milliseconds: _baseRetryDelay.inMilliseconds * math.pow(2, _retryAttempts - 1).toInt()
      );
      
      debugPrint('Scheduling retry $_retryAttempts in ${retryDelay.inSeconds}s');
      
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(retryDelay, () {
        _updateStatus(ConnectionStatus.reconnecting);
        _startConnection();
      });
    } else {
      debugPrint('Max retry attempts reached');
      _updateStatus(ConnectionStatus.disconnected);
    }
  }

  // Update connection status
  void _updateStatus(ConnectionStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusStreamController.add(newStatus);
      debugPrint('Connection status changed: $newStatus');
    }
  }



  // Manual refresh
  Future<void> refresh() async {
    if (_status == ConnectionStatus.connected) {
      if (_connectionType == ConnectionType.polling) {
        await _performPollingRequest();
      }
    }
  }

  // Disconnect and cleanup
  Future<void> disconnect() async {
    debugPrint('Disconnecting connection manager');
    
    _pollingTimer?.cancel();
    _reconnectTimer?.cancel();
    
    _updateStatus(ConnectionStatus.disconnected);
    _sessionId = null;
  }

  // Dispose resources
  void dispose() {
    disconnect();
    _dataStreamController.close();
    _statusStreamController.close();
  }
}