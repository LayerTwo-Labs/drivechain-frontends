import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stacked/stacked.dart';

/// A utility class to track changes in values and only notify when necessary
class ChangeTracker {
  final Map<String, dynamic> _previousValues = {};
  Timer? _debounceTimer;
  final VoidCallback onNotify;
  final Duration debounceDuration;

  ChangeTracker({
    required this.onNotify,
    this.debounceDuration = const Duration(milliseconds: 100),
  });

  /// Track a value and notify if it changed
  bool track<T>(String key, T value) {
    final previous = _previousValues[key];
    final hasChanged = !_equals(previous, value);

    if (hasChanged) {
      _previousValues[key] = value;
    }

    return hasChanged;
  }

  /// Debounced notification that only triggers if any tracked values changed
  void notify() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      if (_shouldNotify()) {
        onNotify();
      }
    });
  }

  bool _shouldNotify() {
    return _previousValues.values.any((value) => value is bool && value == true);
  }

  bool _equals(dynamic a, dynamic b) {
    if (a == b) return true;
    if (a is List && b is List) return listEquals(a, b);
    if (a is Map && b is Map) return mapEquals(a, b);
    return false;
  }

  void dispose() {
    _debounceTimer?.cancel();
    _previousValues.clear();
  }
}

mixin ChangeTrackingMixin on BaseViewModel {
  late final ChangeTracker _changeTracker;

  void initChangeTracker() {
    _changeTracker = ChangeTracker(
      onNotify: notifyListeners,
    );
  }

  @override
  void dispose() {
    _changeTracker.dispose();
    super.dispose();
  }

  /// Track a value and notify if it changed
  bool track<T>(String key, T value) {
    return _changeTracker.track(key, value);
  }

  /// Debounced notification that only triggers if any tracked values changed
  void notifyIfChanged() {
    _changeTracker.notify();
  }
}
