import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/env.dart';
import 'package:sidechain_core/gen/orchestrator/v1/orchestrator.pb.dart' as orch_pb;
import 'package:sidechain_core/rpcs/stream_or_poll.dart';
import 'package:sidechain_core/sidechain_core.dart';

/// Snapshot of one binary's download progress, in the units the orchestrator
/// stores it in (megabytes). [mbTotal] is `-1` while the server hasn't
/// reported a Content-Length yet — UIs should render that as "size unknown".
class DownloadProgress {
  final BinaryType binary;
  final int mbDownloaded;
  final int mbTotal;
  final String message;

  const DownloadProgress({
    required this.binary,
    required this.mbDownloaded,
    required this.mbTotal,
    this.message = '',
  });

  /// Fraction in [0, 1]; falls back to 0 when total is unknown so the UI
  /// can still show an indeterminate state instead of a NaN bar.
  double get progressFraction {
    if (mbTotal <= 0) {
      return 0;
    }
    final f = mbDownloaded / mbTotal;
    if (f.isNaN || f.isInfinite) {
      return 0;
    }
    return f.clamp(0.0, 1.0);
  }

  @override
  bool operator ==(Object other) =>
      other is DownloadProgress &&
      other.binary == binary &&
      other.mbDownloaded == mbDownloaded &&
      other.mbTotal == mbTotal &&
      other.message == message;

  @override
  int get hashCode => Object.hash(binary, mbDownloaded, mbTotal, message);
}

/// Reads the orchestrator's `WatchDownloadStatus` stream for a per-binary
/// snapshot. While the stream is down it polls [getDownloadStatus] fast
/// (100 ms) while at least one entry is in flight, else each 2 s. Daemon
/// cards consult this provider before falling back to [SyncProvider]'s sync
/// state, so a live download always shows instantly.
class DownloadProvider extends ChangeNotifier {
  static const Duration AGGRESSIVE_INTERVAL = Duration(milliseconds: 100);
  static const Duration PASSIVE_INTERVAL = Duration(seconds: 2);

  Logger get _log => GetIt.I.get<Logger>();
  OrchestratorRPC get _orchestrator => GetIt.I.get<OrchestratorRPC>();

  Map<BinaryType, DownloadProgress> _downloads = const {};
  String? _lastError;
  StreamOrPoll<orch_pb.WatchDownloadStatusResponse, orch_pb.GetDownloadStatusResponse>? _watch;

  Map<BinaryType, DownloadProgress> get downloads => _downloads;
  String? get lastError => _lastError;

  /// True when at least one binary is being fetched. Drives the daemon card
  /// priority: download UI wins over sync UI whenever this returns true for
  /// the binary in question (see [statusFor]).
  bool get hasActiveDownloads => _downloads.isNotEmpty;

  /// Looks up the live download for [binary], or null if nothing's in
  /// flight for that binary.
  DownloadProgress? statusFor(BinaryType binary) => _downloads[binary];

  DownloadProvider({bool startTimer = true}) {
    if (startTimer && !Environment.isInTest) {
      _watch = StreamOrPoll<orch_pb.WatchDownloadStatusResponse, orch_pb.GetDownloadStatusResponse>(
        subscribe: _orchestrator.watchDownloadStatus,
        onFrame: applyWatchFrame,
        isHeartbeat: (frame) => frame.heartbeat,
        fetch: _orchestrator.getDownloadStatus,
        onPoll: (resp) => _apply(resp.downloads),
        onPollError: _applyError,
        pollInterval: PASSIVE_INTERVAL,
        nextPollInterval: () => hasActiveDownloads ? AGGRESSIVE_INTERVAL : PASSIVE_INTERVAL,
        onTransportDeath: _orchestrator.recreateConnection,
        logger: _log,
        tag: 'DownloadProvider',
      )..start();
    }
  }

  /// Applies one WatchDownloadStatus frame.
  @visibleForTesting
  void applyWatchFrame(orch_pb.WatchDownloadStatusResponse frame) {
    if (frame.heartbeat) {
      return;
    }
    _apply(frame.downloads);
  }

  /// One-shot fetch. Public so callers (e.g. test harnesses, manual refresh
  /// buttons) can trigger an update without waiting for the timer.
  Future<void> fetch() async {
    // The stream holds the newest list, and an older reply would win.
    if (_watch?.streaming ?? false) {
      return;
    }
    try {
      final resp = await _orchestrator.getDownloadStatus();
      _apply(resp.downloads);
    } catch (e) {
      _applyError(e);
    }
  }

  void _apply(List<orch_pb.DownloadStatus> downloads) {
    final next = <BinaryType, DownloadProgress>{};
    for (final s in downloads) {
      if (s.binary == BinaryType.BINARY_TYPE_UNSPECIFIED) {
        continue;
      }
      next[s.binary] = DownloadProgress(
        binary: s.binary,
        mbDownloaded: s.mbDownloaded.toInt(),
        mbTotal: s.mbTotal.toInt(),
        message: s.message,
      );
    }
    if (mapEquals(next, _downloads) && _lastError == null) {
      return;
    }
    _downloads = next;
    _lastError = null;
    notifyListeners();
  }

  void _applyError(Object e) {
    final error = e.toString();
    if (error == _lastError) {
      return;
    }
    _log.e('DownloadProvider: getDownloadStatus failed: $e');
    _lastError = error;
    notifyListeners();
  }

  @override
  void dispose() {
    unawaited(_watch?.dispose());
    super.dispose();
  }
}
