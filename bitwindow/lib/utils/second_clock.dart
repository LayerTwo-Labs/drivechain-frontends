import 'dart:async';

import 'package:flutter/foundation.dart';

/// Notifies its listeners once per second while it has listeners.
class SecondClock extends ChangeNotifier {
  /// The clock that all once-a-second texts use, so that they change in the same frame.
  static final SecondClock shared = SecondClock();

  Timer? _timer;

  @override
  void addListener(VoidCallback listener) {
    super.addListener(listener);
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) => notifyListeners());
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
