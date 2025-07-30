import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

mixin ChangeTrackingMixin on ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();

  final Map<String, dynamic> _previousValues = {};
  bool _hasChanges = false;
  Timer? _notificationTimer;

  // Backoff configuration. If changes come in rapid succcession, we don't want to notify too often.
  // This makes sure to only notify once every 16ms.
  static const Duration _initialDelay = Duration(milliseconds: 32); // ~30fps
  static const Duration _maxDelay = Duration(milliseconds: 100);
  Duration _currentDelay = _initialDelay;

  void initChangeTracker() {
    _previousValues.clear();
    _hasChanges = false;
    _notificationTimer?.cancel();
    _notificationTimer = null;
    _currentDelay = _initialDelay;
  }

  bool track(String key, dynamic value) {
    final previousValue = _previousValues[key];
    final hasChanged = !_deepEquals(previousValue, value);

    if (hasChanged) {
      _previousValues[key] = value;
      _hasChanges = true;
      _scheduleNotification();
    }

    return hasChanged;
  }

  void notifyIfChanged() {
    if (_hasChanges) {
      _hasChanges = false;
      _notificationTimer?.cancel();
      _notificationTimer = null;
      _currentDelay = _initialDelay; // Reset delay after successful notification
      notifyListeners();
    }
  }

  void _scheduleNotification() {
    // Cancel any existing timer
    _notificationTimer?.cancel();

    // Schedule new notification with current delay
    _notificationTimer = Timer(_currentDelay, () {
      notifyIfChanged();
    });

    // Increase delay for next time (exponential backoff with max cap)
    final newDelayMs = (_currentDelay.inMilliseconds * 1.5).round();
    _currentDelay = Duration(
      milliseconds: newDelayMs > _maxDelay.inMilliseconds ? _maxDelay.inMilliseconds : newDelayMs,
    );
  }

  @override
  void dispose() {
    _notificationTimer?.cancel();
    super.dispose();
  }

  bool _deepEquals(dynamic a, dynamic b) {
    if (a == b) return true;
    if (a == null || b == null) return false;

    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (!_deepEquals(a[i], b[i])) return false;
      }
      return true;
    }

    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final key in a.keys) {
        if (!b.containsKey(key) || !_deepEquals(a[key], b[key])) return false;
      }
      return true;
    }

    // Use the object's equality operator if it exists
    if (a is Object && b is Object) {
      return a == b;
    }

    return false;
  }
}
