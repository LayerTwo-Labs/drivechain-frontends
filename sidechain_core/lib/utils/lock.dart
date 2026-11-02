import 'dart:async';

/// Runs actions one at a time, in call order. Not reentrant: an action that
/// calls [synchronized] on its own lock never completes.
class Lock {
  Future<void>? _last;

  /// Runs [action] after every earlier action ends, and returns its result.
  Future<T> synchronized<T>(FutureOr<T> Function() action) async {
    final prev = _last;
    final done = Completer<void>.sync();
    final current = done.future;
    _last = current;
    try {
      if (prev != null) {
        await prev;
      }
      return await action();
    } finally {
      done.complete();
      if (identical(_last, current)) {
        _last = null;
      }
    }
  }
}
