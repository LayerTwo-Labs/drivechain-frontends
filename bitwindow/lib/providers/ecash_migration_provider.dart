import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// The bottom nav label a saved migration asks for, empty when no swap runs.
String migrationNavLabel(ECashMigrationStatus? status) {
  if (status == null || status.jobId.isEmpty || status.complete || status.toId.isEmpty) {
    return '';
  }
  final id = status.toId;
  return 'Swapping to ${id[0].toUpperCase()}${id.substring(1)}';
}

/// Polls the saved ECX migration so the bottom nav can reopen its dialog.
class ECashMigrationProvider extends ChangeNotifier {
  ECashMigrationProvider({this.interval = const Duration(seconds: 3)});

  final Duration interval;
  OrchestratorRPC get _rpc => GetIt.I.get<OrchestratorRPC>();

  Timer? _timer;
  ECashMigrationStatus? _status;
  String? modelError;

  ECashMigrationStatus? get status => _status;
  String get navLabel => migrationNavLabel(_status);
  bool get swapping => navLabel.isNotEmpty;

  void start() {
    if (_timer != null) {
      return;
    }
    _timer = Timer.periodic(interval, (_) => unawaited(refresh()));
    unawaited(refresh());
  }

  Future<void> refresh() async {
    try {
      final next = (await _rpc.getECashMigrationStatus()).status;
      modelError = null;
      if (migrationNavLabel(next) == navLabel && next.phase == _status?.phase) {
        _status = next;
        return;
      }
      _status = next;
      notifyListeners();
    } catch (error) {
      modelError = error.toString();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}
