import 'dart:async';

import 'package:flutter/foundation.dart';

/// A step of the backend swap, in the order BitWindow does them.
enum BackendSwapStep {
  claim('Chain handover', 'BitWindow takes the chain from the old backend. The chain stays up through the swap.'),
  stop('Old backend stops', 'The old backend stops its daemons. BitWindow waits for it to exit.'),
  start('New backend starts', 'The new backend takes over. It runs the code of this version.');

  const BackendSwapStep(this.label, this.detail);

  final String label;
  final String detail;
}

/// Reports the backend swap to the splash screen and to the bottom nav.
///
/// A quick quit and a restart find the backend of the last run still alive.
/// BitWindow replaces that one, and without this report the user only waits.
class BackendSwapProvider extends ChangeNotifier {
  BackendSwapProvider({this.tick = const Duration(seconds: 1), this.clock = DateTime.now});

  /// How often the seconds on the current step refresh.
  final Duration tick;

  /// The clock the steps read. A test gives its own.
  final DateTime Function() clock;

  final List<BackendSwapStep> _steps = [];
  BackendSwapStep? _step;
  BackendSwapStep? _failedStep;
  String? _error;
  DateTime? _stepStart;
  Timer? _timer;

  /// The step BitWindow does, or null when no swap runs.
  BackendSwapStep? get step => _step;

  /// The steps of this swap, in the order BitWindow did them.
  List<BackendSwapStep> get steps => List.unmodifiable(_steps);

  bool get swapping => _step != null;

  /// The step that stopped the swap, or null when no step failed.
  BackendSwapStep? get failedStep => _failedStep;

  /// Why the swap stopped, or null when it ran to the end.
  String? get error => _error;

  /// The seconds on the current step, or 0 when no swap runs.
  int get seconds {
    final start = _stepStart;
    if (start == null) {
      return 0;
    }
    return clock().difference(start).inSeconds;
  }

  /// The one line the bottom nav and the splash screen show. Empty when no
  /// swap runs.
  String get navLabel {
    final step = _step;
    if (step == null) {
      return '';
    }
    return '${step.label} (${seconds}s)';
  }

  /// Names the step BitWindow starts. Repeat calls for the same step keep the
  /// seconds of that step.
  void report(BackendSwapStep step) {
    if (_step == step) {
      return;
    }
    if (_failedStep != null) {
      // The steps of the swap that stopped belong to that try, not to this one.
      _steps.clear();
    }
    _step = step;
    _failedStep = null;
    _error = null;
    _stepStart = clock();
    if (!_steps.contains(step)) {
      _steps.add(step);
    }
    _timer ??= Timer.periodic(tick, (_) => notifyListeners());
    notifyListeners();
  }

  /// Ends the swap and clears the report.
  void finish() {
    if (_step == null) {
      return;
    }
    _step = null;
    _stepStart = null;
    _steps.clear();
    _stop();
  }

  /// Ends the swap on a failure. The steps stay, so the detail names the step
  /// that stopped and why.
  void fail(Object error) {
    if (_step == null) {
      return;
    }
    _failedStep = _step;
    _error = '$error';
    _step = null;
    _stepStart = null;
    _stop();
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
