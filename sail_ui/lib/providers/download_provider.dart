import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/env.dart';
import 'package:sail_ui/gen/orchestrator/v1/orchestrator.pb.dart' as orch_pb;
import 'package:sail_ui/sail_ui.dart';

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
    if (mbTotal <= 0) return 0;
    final f = mbDownloaded / mbTotal;
    if (f.isNaN || f.isInfinite) return 0;
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

/// Polls the orchestrator's [getDownloadStatus] RPC and surfaces a per-binary
/// snapshot. Cadence is fast (100 ms) while at least one entry is in flight,
/// then drops to 2 s once the response is empty — the call is cheap because
/// the orchestrator just reads its in-memory DownloadManager map. Daemon
/// cards consult this provider before falling back to [SyncProvider]'s sync
/// state, so a live download always shows instantly.
class DownloadProvider extends ChangeNotifier {
  static const Duration AGGRESSIVE_INTERVAL = Duration(milliseconds: 100);
  static const Duration PASSIVE_INTERVAL = Duration(seconds: 2);

  Logger get _log => GetIt.I.get<Logger>();
  OrchestratorRPC get _orchestrator => GetIt.I.get<OrchestratorRPC>();

  Map<BinaryType, DownloadProgress> _downloads = const {};
  String? _lastError;
  Timer? _timer;
  bool _isFetching = false;
  Duration _currentInterval = AGGRESSIVE_INTERVAL;

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
      _scheduleNextTick();
      fetch();
    }
  }

  void _scheduleNextTick() {
    _timer?.cancel();
    _timer = Timer.periodic(_currentInterval, (_) => _tick());
  }

  Future<void> _tick() async {
    if (_isFetching) return;
    _isFetching = true;
    try {
      await fetch();
      final nextInterval = hasActiveDownloads ? AGGRESSIVE_INTERVAL : PASSIVE_INTERVAL;
      if (nextInterval != _currentInterval) {
        _currentInterval = nextInterval;
        _scheduleNextTick();
      }
    } catch (_) {
      // fetch() already records the error
    } finally {
      _isFetching = false;
    }
  }

  /// One-shot fetch. Public so callers (e.g. test harnesses, manual refresh
  /// buttons) can trigger an update without waiting for the timer.
  Future<void> fetch() async {
    try {
      final resp = await _orchestrator.getDownloadStatus();
      final next = <BinaryType, DownloadProgress>{};
      for (final s in resp.downloads) {
        if (s.binary == BinaryType.BINARY_TYPE_UNSPECIFIED) continue;
        next[s.binary] = DownloadProgress(
          binary: s.binary,
          mbDownloaded: s.mbDownloaded.toInt(),
          mbTotal: s.mbTotal.toInt(),
          message: s.message,
        );
      }
      _downloads = next;
      _lastError = null;
      notifyListeners();
    } catch (e) {
      _log.e('DownloadProvider: getDownloadStatus failed: $e');
      _lastError = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Keep the orch_pb alias used so the analyzer doesn't strip the import; the
// proto type surfaces only via the typed RPC return value.
// ignore: unused_element
typedef _OrchAlias = orch_pb.GetDownloadStatusResponse;
