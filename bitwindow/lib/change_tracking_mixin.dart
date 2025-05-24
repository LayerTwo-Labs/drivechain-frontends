import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

mixin ChangeTrackingMixin on ChangeNotifier {
  Logger get log => GetIt.I.get<Logger>();

  final Map<String, dynamic> _previousValues = {};
  bool _hasChanges = false;

  void initChangeTracker() {
    _previousValues.clear();
    _hasChanges = false;
  }

  bool track(String key, dynamic value) {
    final previousValue = _previousValues[key];
    final hasChanged = !_deepEquals(previousValue, value);

    if (hasChanged) {
      log.i('Value changed for key "$key":\nOld: $previousValue\nNew: $value');
      _previousValues[key] = value;
      _hasChanges = true;
    }

    return hasChanged;
  }

  void notifyIfChanged() {
    if (_hasChanges) {
      log.i('Notifying listeners of changes');
      _hasChanges = false;
      notifyListeners();
    }
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

    if (a is Object && b is Object) {
      final aProps = a.toString();
      final bProps = b.toString();
      return aProps == bProps;
    }

    return false;
  }
}
