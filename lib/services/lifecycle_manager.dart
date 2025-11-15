import 'dart:async';
import 'package:flutter/foundation.dart';

/// Manages app lifecycle state for optimizing battery and data usage
class LifecycleManager {
  static final LifecycleManager _instance = LifecycleManager._internal();
  factory LifecycleManager() => _instance;
  LifecycleManager._internal();

  bool _isInForeground = true;
  final StreamController<bool> _foregroundStreamController = StreamController.broadcast();
  Timer? _backgroundTimer;
  DateTime? _backgroundEntryTime;
  
  // Configuration
  Duration _backgroundUpdateInterval = const Duration(minutes: 5);
  Duration _foregroundUpdateInterval = const Duration(seconds: 58);
  
  // Streams
  Stream<bool> get foregroundStream => _foregroundStreamController.stream;
  bool get isInForeground => _isInForeground;
  Duration get currentUpdateInterval => _isInForeground ? _foregroundUpdateInterval : _backgroundUpdateInterval;
  
  // Track time spent in background
  Duration get timeInBackground {
    if (_backgroundEntryTime == null) return Duration.zero;
    return DateTime.now().difference(_backgroundEntryTime!);
  }

  /// Call this when app is resumed (foreground)
  void onAppResumed() {
    if (!_isInForeground) {
      _isInForeground = true;
      _backgroundTimer?.cancel();
      _backgroundEntryTime = null;
      _foregroundStreamController.add(true);
      debugPrint('Lifecycle: App resumed - switching to foreground mode');
    }
  }

  /// Call this when app is paused (background)
  void onAppPaused() {
    if (_isInForeground) {
      _isInForeground = false;
      _backgroundEntryTime = DateTime.now();
      _foregroundStreamController.add(false);
      debugPrint('Lifecycle: App paused - switching to background mode');
      
      // Set timer to check if we should do a background update
      _scheduleBackgroundUpdate();
    }
  }

  /// Configure update intervals
  void configureUpdateIntervals({
    Duration? foregroundInterval,
    Duration? backgroundInterval,
  }) {
    if (foregroundInterval != null) {
      _foregroundUpdateInterval = foregroundInterval;
    }
    if (backgroundInterval != null) {
      _backgroundUpdateInterval = backgroundInterval;
    }
    debugPrint('Lifecycle: Update intervals configured - Foreground: ${_foregroundUpdateInterval.inSeconds}s, Background: ${_backgroundUpdateInterval.inMinutes}m');
  }

  /// Schedule a background update check
  void _scheduleBackgroundUpdate() {
    _backgroundTimer?.cancel();
    
    // Only schedule if we have a reasonable background interval
    if (_backgroundUpdateInterval > Duration.zero) {
      _backgroundTimer = Timer(_backgroundUpdateInterval, () {
        debugPrint('Lifecycle: Background update interval reached');
        // The actual update decision should be made by the connection manager
        // based on data freshness requirements
      });
    }
  }

  /// Check if an update is needed based on lifecycle state and data freshness
  bool shouldUpdateData({
    required DateTime? lastUpdate,
    Duration? maxStaleDuration,
  }) {
    if (lastUpdate == null) return true;
    
    final timeSinceUpdate = DateTime.now().difference(lastUpdate);
    final staleDuration = maxStaleDuration ?? (_isInForeground ? _foregroundUpdateInterval : _backgroundUpdateInterval);
    
    final shouldUpdate = timeSinceUpdate >= staleDuration;
    
    debugPrint('Lifecycle: Update check - InForeground: $_isInForeground, Time since update: ${timeSinceUpdate.inSeconds}s, Should update: $shouldUpdate');
    
    return shouldUpdate;
  }

  /// Get recommended update interval based on current state
  Duration getRecommendedUpdateInterval() {
    return _isInForeground ? _foregroundUpdateInterval : _backgroundUpdateInterval;
  }

  /// Dispose resources
  void dispose() {
    _backgroundTimer?.cancel();
    _foregroundStreamController.close();
  }
}