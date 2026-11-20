import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/rpcs/stream_or_poll.dart';

/// The bottom nav label a saved migration asks for, empty when no swap runs.
String migrationNavLabel(ECashMigrationStatus? status) {
  if (status == null || status.jobId.isEmpty || status.complete || status.toId.isEmpty) {
    return '';
  }
  final id = status.toId;
  return 'Swapping to ${id[0].toUpperCase()}${id.substring(1)}';
}

/// Watches the saved ECX migration so the bottom nav can reopen its dialog.
/// It polls each [interval] while the stream is down.
class ECashMigrationProvider extends ChangeNotifier {
  ECashMigrationProvider({this.interval = const Duration(seconds: 3)});

  final Duration interval;
  OrchestratorRPC get _rpc => GetIt.I.get<OrchestratorRPC>();

  StreamOrPoll<WatchECashMigrationStatusResponse, GetECashMigrationStatusResponse>? _watch;
  ECashMigrationStatus? _status;
  String? modelError;

  ECashMigrationStatus? get status => _status;
  String get navLabel => migrationNavLabel(_status);
  bool get swapping => navLabel.isNotEmpty;

  void start() {
    if (_watch != null) {
      return;
    }
    final rpc = _rpc;
    _watch = StreamOrPoll<WatchECashMigrationStatusResponse, GetECashMigrationStatusResponse>(
      subscribe: rpc.watchECashMigrationStatus,
      onFrame: applyWatchFrame,
      isHeartbeat: (frame) => frame.heartbeat,
      fetch: rpc.getECashMigrationStatus,
      onPoll: (resp) => _apply(resp.status),
      onPollError: (error) => modelError = error.toString(),
      pollInterval: interval,
      onTransportDeath: rpc.recreateConnection,
      logger: GetIt.I.get<Logger>(),
      tag: 'ECashMigrationProvider',
    )..start();
  }

  /// Applies one WatchECashMigrationStatus frame.
  @visibleForTesting
  void applyWatchFrame(WatchECashMigrationStatusResponse frame) {
    if (frame.heartbeat) {
      return;
    }
    _apply(frame.status);
  }

  Future<void> refresh() async {
    // The stream holds the newest status, and an older reply would win.
    if (_watch?.streaming ?? false) {
      return;
    }
    try {
      _apply((await _rpc.getECashMigrationStatus()).status);
    } catch (error) {
      modelError = error.toString();
    }
  }

  void _apply(ECashMigrationStatus next) {
    modelError = null;
    if (migrationNavLabel(next) == navLabel && next.phase == _status?.phase) {
      _status = next;
      return;
    }
    _status = next;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_watch?.dispose());
    _watch = null;
    super.dispose();
  }
}
