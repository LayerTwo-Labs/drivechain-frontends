import 'dart:async';

import 'package:logger/logger.dart';
import 'package:sidechain_core/rpcs/stream_supervisor.dart';

/// Reads a server stream, and polls the matching unary RPC while the stream
/// is down. A daemon without the stream keeps the poll for good.
class StreamOrPoll<F, P> {
  StreamOrPoll({
    required Stream<F> Function() subscribe,
    required void Function(F frame) onFrame,
    required bool Function(F frame) isHeartbeat,
    required this._fetch,
    required this._onPoll,
    required this._onPollError,
    required Duration pollInterval,
    Duration Function()? nextPollInterval,
    required void Function() onTransportDeath,
    required Logger logger,
    required String tag,
  }) : _pollInterval = nextPollInterval ?? (() => pollInterval) {
    _supervisor = StreamSupervisor<F>(
      subscribe: subscribe,
      onEvent: (frame) {
        if (!isHeartbeat(frame)) {
          _frames++;
        }
        onFrame(frame);
      },
      onTransportDeath: onTransportDeath,
      logger: logger,
      tag: tag,
    );
  }

  late final StreamSupervisor<F> _supervisor;
  final Future<P> Function() _fetch;
  final void Function(P) _onPoll;
  final void Function(Object error) _onPollError;
  final Duration Function() _pollInterval;

  StreamSubscription<bool>? _health;
  bool _pollOn = false;
  Timer? _pollTimer;
  bool _polling = false;
  int _frames = 0;

  /// True while the stream delivers frames.
  bool get streaming => _supervisor.isHealthy;

  /// True while the fallback poll runs.
  bool get polling => _pollOn;

  void start() {
    _health = _supervisor.healthStream.listen((healthy) => healthy ? _stopPoll() : _startPoll());
    _startPoll();
    _supervisor.start();
  }

  void _startPoll() {
    if (_pollOn) {
      return;
    }
    _pollOn = true;
    unawaited(_poll());
  }

  void _stopPoll() {
    _pollOn = false;
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> _poll() async {
    if (_polling) {
      return;
    }
    _polling = true;
    final started = DateTime.now();
    try {
      final P result;
      try {
        result = await _fetch();
      } catch (e) {
        if (!streaming) {
          _onPollError(e);
        }
        return;
      }
      // A poll sent before the stream came up can answer with a snapshot
      // older than the last frame, and the stream sends only changes.
      if (!streaming) {
        _onPoll(result);
      }
    } finally {
      _polling = false;
      if (_pollOn) {
        final wait = _pollInterval() - DateTime.now().difference(started);
        _pollTimer?.cancel();
        _pollTimer = Timer(wait.isNegative ? Duration.zero : wait, _poll);
      }
    }
  }

  /// Reads the unary RPC one time, for a caller that dropped its state. The
  /// stream sends only changes, so it does not fill that state again. A frame
  /// that arrives during the read wins.
  Future<void> refresh() async {
    final frames = _frames;
    final P result;
    try {
      result = await _fetch();
    } catch (e) {
      if (!streaming) {
        _onPollError(e);
      }
      return;
    }
    if (_frames == frames) {
      _onPoll(result);
    }
  }

  Future<void> dispose() async {
    _stopPoll();
    await _health?.cancel();
    await _supervisor.dispose();
  }
}
