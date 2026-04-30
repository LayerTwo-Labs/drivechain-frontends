import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// The cadence at which the orchestrator's server-streaming Watch* handlers
/// emit idle keepalive frames. Kept in lock-step with `WatchHeartbeatInterval`
/// in `sidechain-orchestrator/api/watch_heartbeat.go`. The two constants
/// must move together — the supervisor's [StreamSupervisor.heartbeatTimeout]
/// asserts `> 2 *` this value at construction time so a mismatch surfaces
/// loudly on first instantiation rather than as flapping reconnects.
const Duration kServerHeartbeatInterval = Duration(seconds: 5);

/// Reasons the supervisor itself classifies a stream failure as.
enum _FailureKind { stream, transport }

/// Wraps a server-streaming RPC with reconnect, transport recreation, and a
/// heartbeat watchdog so individual providers don't each reinvent reconnect
/// state machines.
///
/// Contract assumed of the wrapped stream:
///  - on (re)subscribe, the server emits the full current state as the first
///    frame so callers don't need to maintain delta-merge logic across
///    reconnects;
///  - the server emits idle keepalive frames at least once every 5s so
///    [heartbeatTimeout] can distinguish a quiet stream from a half-open
///    connection.
///
/// Usage:
/// ```dart
/// final supervisor = StreamSupervisor<WatchBinariesResponse>(
///   subscribe: () => orchestrator.watchBinaries(),
///   onEvent: _apply,
///   onTransportDeath: orchestrator.recreateConnection,
///   logger: log,
///   tag: 'BackendStateProvider',
/// )..start();
/// ...
/// await supervisor.dispose();
/// ```
class StreamSupervisor<T> {
  StreamSupervisor({
    required Stream<T> Function() subscribe,
    required void Function(T event) onEvent,
    required void Function() onTransportDeath,
    required Logger logger,
    required String tag,
    Duration heartbeatTimeout = const Duration(seconds: 12),
    Duration heartbeatCheckInterval = const Duration(seconds: 2),
    Duration serverHeartbeatInterval = kServerHeartbeatInterval,
    bool Function(Object error)? isTransportError,
    DateTime Function() now = _systemNow,
  }) : assert(
         heartbeatTimeout > serverHeartbeatInterval * 2,
         'heartbeatTimeout ($heartbeatTimeout) must be > 2 * '
         'serverHeartbeatInterval ($serverHeartbeatInterval). The '
         'worst-case inter-frame gap when the server is healthy is '
         '~2× the server interval (a real send right before the heartbeat '
         'ticker fires resets the ticker, pushing the next heartbeat one '
         'full interval out). A timeout ≤ 2× would produce spurious dead-'
         'stream detections under perfectly healthy conditions.',
       ),
       _subscribe = subscribe,
       _onEvent = onEvent,
       _onTransportDeath = onTransportDeath,
       _logger = logger,
       _tag = tag,
       _heartbeatTimeout = heartbeatTimeout,
       _heartbeatCheckInterval = heartbeatCheckInterval,
       _isTransportError = isTransportError ?? _defaultIsTransportError,
       _now = now;

  final Stream<T> Function() _subscribe;
  final void Function(T) _onEvent;
  final void Function() _onTransportDeath;
  final Logger _logger;
  final String _tag;
  final Duration _heartbeatTimeout;
  final Duration _heartbeatCheckInterval;
  final bool Function(Object) _isTransportError;
  final DateTime Function() _now;

  StreamSubscription<T>? _sub;
  Timer? _reconnectTimer;
  Timer? _watchdog;
  DateTime? _lastFrameAt;
  int _attempt = 0;
  bool _started = false;
  bool _disposed = false;

  /// Health changes (true=connected with recent traffic, false=reconnecting
  /// or stale). Provider can listen to drive a "reconnecting" badge.
  final _healthController = StreamController<bool>.broadcast();
  bool _healthy = false;

  bool get isHealthy => _healthy;
  Stream<bool> get healthStream => _healthController.stream;

  void start() {
    if (_disposed) {
      throw StateError('$_tag: StreamSupervisor.start after dispose');
    }
    if (_started) return;
    _started = true;
    _connect();
  }

  void _connect() {
    if (_disposed) return;
    _sub?.cancel();
    _reconnectTimer?.cancel();

    _logger.d('$_tag: subscribing (attempt ${_attempt + 1})');
    Stream<T> stream;
    try {
      stream = _subscribe();
    } catch (e, st) {
      _logger.w('$_tag: subscribe threw synchronously: $e');
      _setHealthy(false);
      _scheduleReconnect(_classify(e), e, st);
      return;
    }

    _lastFrameAt = _now();
    _startWatchdog();

    _sub = stream.listen(
      (event) {
        // Any frame proves liveness — reset backoff and watchdog timestamp.
        // Heartbeat detection is based on inter-frame gap, not payload, so
        // the supervisor doesn't care whether the event is a real update or
        // an idle ping.
        _attempt = 0;
        _lastFrameAt = _now();
        _setHealthy(true);
        try {
          _onEvent(event);
        } catch (e, st) {
          _logger.e('$_tag: onEvent threw: $e\n$st');
        }
      },
      onError: (Object e, StackTrace st) {
        final kind = _classify(e);
        _logger.w('$_tag: stream error (${kind.name}): $e');
        _setHealthy(false);
        _scheduleReconnect(kind, e, st);
      },
      onDone: () {
        _logger.i('$_tag: stream closed by server, reconnecting');
        _setHealthy(false);
        _scheduleReconnect(_FailureKind.stream, null, null);
      },
    );
  }

  void _startWatchdog() {
    _watchdog?.cancel();
    _watchdog = Timer.periodic(_heartbeatCheckInterval, (_) {
      final last = _lastFrameAt;
      if (last == null) return;
      if (_now().difference(last) > _heartbeatTimeout) {
        _logger.w(
          '$_tag: no frame in ${_heartbeatTimeout.inSeconds}s, declaring dead',
        );
        _setHealthy(false);
        _scheduleReconnect(_FailureKind.transport, null, null);
      }
    });
  }

  void _scheduleReconnect(
    _FailureKind kind,
    Object? error,
    StackTrace? stack,
  ) {
    _watchdog?.cancel();
    _watchdog = null;
    _sub?.cancel();
    _sub = null;

    if (_disposed) return;

    if (kind == _FailureKind.transport) {
      // Rebuild the underlying HTTP transport BEFORE the next subscribe —
      // this is what fixes a poisoned HTTP/2 connection. Stream-level
      // failures don't need this; the same transport can host a fresh sub.
      try {
        _onTransportDeath();
      } catch (e) {
        _logger.e('$_tag: onTransportDeath threw: $e');
      }
    }

    final delay = _backoffFor(_attempt);
    _attempt++;
    _logger.d('$_tag: reconnect in ${delay.inMilliseconds}ms');
    _reconnectTimer = Timer(delay, _connect);
  }

  _FailureKind _classify(Object error) => _isTransportError(error) ? _FailureKind.transport : _FailureKind.stream;

  void _setHealthy(bool h) {
    if (_healthy == h) return;
    _healthy = h;
    _healthController.add(h);
  }

  /// Stop reconnecting and release all resources. Idempotent.
  Future<void> dispose() async {
    _disposed = true;
    _started = false;
    _watchdog?.cancel();
    _watchdog = null;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    await _sub?.cancel();
    _sub = null;
    await _healthController.close();
  }
}

const _backoffSchedule = <Duration>[
  Duration(milliseconds: 100),
  Duration(milliseconds: 250),
  Duration(milliseconds: 500),
  Duration(seconds: 1),
  Duration(seconds: 2),
  Duration(seconds: 5),
  Duration(seconds: 10),
];

@visibleForTesting
Duration backoffForAttempt(int attempt, {Random? random}) => _backoffFor(attempt, random: random);

/// Exponential backoff with ±20% jitter, capped at 10s.
Duration _backoffFor(int attempt, {Random? random}) {
  final base = _backoffSchedule[attempt.clamp(0, _backoffSchedule.length - 1)];
  final r = random ?? _sharedRandom;
  // ±20% jitter so multiple supervisors don't reconnect in lockstep.
  final jitterFactor = 0.8 + r.nextDouble() * 0.4;
  return Duration(microseconds: (base.inMicroseconds * jitterFactor).round());
}

final _sharedRandom = Random();

DateTime _systemNow() => DateTime.now();

/// Default heuristic for "the underlying HTTP transport is poisoned and a
/// fresh subscribe on the same transport will fail again." The supervisor
/// triggers `onTransportDeath` only for these — stream-level errors get a
/// plain resubscribe.
bool _defaultIsTransportError(Object e) {
  final s = e.toString().toLowerCase();
  return s.contains('http/2 connection is finishing') ||
      s.contains('connection closed') ||
      s.contains('stream closed') ||
      s.contains('connection is being forcefully terminated') ||
      s.contains('protocol_error') ||
      s.contains('_cancreatenewstream') ||
      s.contains('socketexception');
}
