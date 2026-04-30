import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/rpcs/stream_supervisor.dart';

class _SilentLogger extends Logger {
  _SilentLogger() : super(level: Level.off);
}

/// A controllable fake stream factory: each call to [subscribe] returns a
/// fresh stream backed by a controller the test can drive.
class _FakeStreamSource<T> {
  int subscribeCount = 0;
  final List<StreamController<T>> controllers = [];

  Stream<T> subscribe() {
    subscribeCount++;
    final controller = StreamController<T>();
    controllers.add(controller);
    return controller.stream;
  }

  StreamController<T> get last => controllers.last;
  StreamController<T> at(int index) => controllers[index];
}

void main() {
  // Use small intervals so tests don't drag — the supervisor's behavior is
  // independent of wall-clock duration past the configured timeouts.
  Duration ms(int n) => Duration(milliseconds: n);

  test('delivers events from the wrapped stream', () async {
    final source = _FakeStreamSource<int>();
    final received = <int>[];

    final supervisor = StreamSupervisor<int>(
      subscribe: source.subscribe,
      onEvent: received.add,
      onTransportDeath: () {},
      logger: _SilentLogger(),
      tag: 'test',
    )..start();

    source.last.add(1);
    source.last.add(2);
    await Future<void>.delayed(ms(10));

    expect(received, [1, 2]);
    expect(supervisor.isHealthy, isTrue);

    await supervisor.dispose();
  });

  test('reconnects after a stream-level error without rebuilding transport', () async {
    final source = _FakeStreamSource<int>();
    var transportDeaths = 0;

    final supervisor = StreamSupervisor<int>(
      subscribe: source.subscribe,
      onEvent: (_) {},
      onTransportDeath: () => transportDeaths++,
      logger: _SilentLogger(),
      tag: 'test',
    )..start();

    // First subscription open; emit a generic stream error (not transport-classified).
    source.last.addError(StateError('boom'));
    await source.last.close();

    // Wait long enough for the first backoff slot (~100ms with jitter).
    await Future<void>.delayed(ms(300));

    expect(source.subscribeCount, greaterThanOrEqualTo(2));
    expect(transportDeaths, 0, reason: 'stream-level error must not trigger recreateConnection');

    await supervisor.dispose();
  });

  test('rebuilds transport on a transport-classified error', () async {
    final source = _FakeStreamSource<int>();
    var transportDeaths = 0;

    final supervisor = StreamSupervisor<int>(
      subscribe: source.subscribe,
      onEvent: (_) {},
      onTransportDeath: () => transportDeaths++,
      logger: _SilentLogger(),
      tag: 'test',
      isTransportError: (e) => true,
    )..start();

    source.last.addError(StateError('http/2 connection is finishing'));
    await Future<void>.delayed(ms(300));

    expect(transportDeaths, greaterThanOrEqualTo(1));
    expect(source.subscribeCount, greaterThanOrEqualTo(2));

    await supervisor.dispose();
  });

  test('declares stream dead via heartbeat watchdog when no frames arrive', () async {
    final source = _FakeStreamSource<int>();
    var transportDeaths = 0;

    final supervisor = StreamSupervisor<int>(
      subscribe: source.subscribe,
      onEvent: (_) {},
      onTransportDeath: () => transportDeaths++,
      logger: _SilentLogger(),
      tag: 'test',
      heartbeatTimeout: ms(50),
      heartbeatCheckInterval: ms(20),
      serverHeartbeatInterval: ms(20),
    )..start();

    // Don't emit anything. Watchdog should fire.
    await Future<void>.delayed(ms(200));

    expect(transportDeaths, greaterThanOrEqualTo(1));
    expect(source.subscribeCount, greaterThanOrEqualTo(2));
    expect(supervisor.isHealthy, isFalse);

    await supervisor.dispose();
  });

  test('any frame (incl. heartbeat) resets the watchdog', () async {
    final source = _FakeStreamSource<int>();
    var transportDeaths = 0;

    final supervisor = StreamSupervisor<int>(
      subscribe: source.subscribe,
      onEvent: (_) {},
      onTransportDeath: () => transportDeaths++,
      logger: _SilentLogger(),
      tag: 'test',
      heartbeatTimeout: ms(80),
      heartbeatCheckInterval: ms(20),
      serverHeartbeatInterval: ms(20),
    )..start();

    // Pulse a frame every 30ms — under the heartbeat timeout, so the
    // supervisor should never declare dead.
    for (var i = 0; i < 8; i++) {
      source.last.add(i);
      await Future<void>.delayed(ms(30));
    }

    expect(transportDeaths, 0);
    expect(source.subscribeCount, 1);
    expect(supervisor.isHealthy, isTrue);

    await supervisor.dispose();
  });

  test('healthStream emits transitions', () async {
    final source = _FakeStreamSource<int>();
    final transitions = <bool>[];

    final supervisor = StreamSupervisor<int>(
      subscribe: source.subscribe,
      onEvent: (_) {},
      onTransportDeath: () {},
      logger: _SilentLogger(),
      tag: 'test',
      heartbeatTimeout: ms(50),
      heartbeatCheckInterval: ms(20),
      serverHeartbeatInterval: ms(20),
    );
    supervisor.healthStream.listen(transitions.add);
    supervisor.start();

    // Frame → healthy
    source.last.add(1);
    await Future<void>.delayed(ms(30));
    // Stop emitting → watchdog fires → unhealthy
    await Future<void>.delayed(ms(150));

    expect(transitions, contains(true));
    expect(transitions, contains(false));

    await supervisor.dispose();
  });

  test('dispose stops reconnects and is idempotent', () async {
    final source = _FakeStreamSource<int>();
    final supervisor = StreamSupervisor<int>(
      subscribe: source.subscribe,
      onEvent: (_) {},
      onTransportDeath: () {},
      logger: _SilentLogger(),
      tag: 'test',
    )..start();

    source.last.addError(StateError('boom'));
    await supervisor.dispose();
    await supervisor.dispose(); // idempotent

    final countAtDispose = source.subscribeCount;
    await Future<void>.delayed(ms(300));

    expect(source.subscribeCount, countAtDispose, reason: 'no reconnects after dispose');
  });

  test('start after dispose throws', () async {
    final source = _FakeStreamSource<int>();
    final supervisor = StreamSupervisor<int>(
      subscribe: source.subscribe,
      onEvent: (_) {},
      onTransportDeath: () {},
      logger: _SilentLogger(),
      tag: 'test',
    );
    await supervisor.dispose();

    expect(supervisor.start, throwsStateError);
  });

  test('asserts heartbeatTimeout > 2 * serverHeartbeatInterval', () {
    expect(
      () => StreamSupervisor<int>(
        subscribe: () => const Stream<int>.empty(),
        onEvent: (_) {},
        onTransportDeath: () {},
        logger: _SilentLogger(),
        tag: 'test',
        // Violates the invariant: 10s timeout against 5s server interval is
        // exactly 2× — must be strictly greater.
        heartbeatTimeout: const Duration(seconds: 10),
        serverHeartbeatInterval: const Duration(seconds: 5),
      ),
      throwsA(isA<AssertionError>()),
    );
  });

  test('successful frame resets the backoff schedule', () async {
    final source = _FakeStreamSource<int>();
    final received = <int>[];

    final supervisor = StreamSupervisor<int>(
      subscribe: source.subscribe,
      onEvent: received.add,
      onTransportDeath: () {},
      logger: _SilentLogger(),
      tag: 'test',
    )..start();

    // Drive a few stream errors to advance the backoff counter.
    source.last.addError(StateError('boom1'));
    await Future<void>.delayed(ms(150));
    source.last.addError(StateError('boom2'));
    await Future<void>.delayed(ms(300));

    // Successful frame resets attempt; next error should retry quickly again.
    source.last.add(42);
    await Future<void>.delayed(ms(20));
    expect(received, contains(42));

    source.last.addError(StateError('boom3'));
    final priorCount = source.subscribeCount;
    await Future<void>.delayed(ms(250));
    expect(source.subscribeCount, greaterThan(priorCount));

    await supervisor.dispose();
  });
}
