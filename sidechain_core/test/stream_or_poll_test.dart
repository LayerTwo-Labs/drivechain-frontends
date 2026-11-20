import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/rpcs/stream_or_poll.dart';

class _Harness {
  final streams = <StreamController<int>>[];
  final frames = <int>[];
  final polled = <int>[];
  final errors = <Object>[];
  int fetches = 0;
  Completer<int>? pendingFetch;
  int nextPoll = 100;

  late final StreamOrPoll<int, int> watch = StreamOrPoll<int, int>(
    subscribe: () {
      final c = StreamController<int>();
      streams.add(c);
      return c.stream;
    },
    onFrame: frames.add,
    isHeartbeat: (frame) => frame == 0,
    fetch: () {
      fetches++;
      final pending = pendingFetch;
      if (pending != null) {
        return pending.future;
      }
      return Future.value(nextPoll);
    },
    onPoll: polled.add,
    onPollError: errors.add,
    pollInterval: const Duration(milliseconds: 50),
    onTransportDeath: () {},
    logger: Logger(level: Level.off),
    tag: 'test',
  );
}

Future<void> _wait(int ms) => Future<void>.delayed(Duration(milliseconds: ms));

void main() {
  test('polls until the first frame, then stops', () async {
    final h = _Harness()..watch.start();
    await _wait(5);
    expect(h.fetches, 1);
    expect(h.watch.polling, isTrue);

    h.streams.last.add(1);
    await _wait(5);
    expect(h.frames, [1]);
    expect(h.watch.polling, isFalse);

    final fetches = h.fetches;
    await _wait(200);
    expect(h.fetches, fetches);
    await h.watch.dispose();
  });

  test('a broken stream polls at once, before the reconnect', () async {
    final h = _Harness()..watch.start();
    h.streams.last.add(1);
    await _wait(5);
    final fetches = h.fetches;

    h.streams.last.addError(Exception('connection refused'));
    await _wait(5);
    expect(h.fetches, fetches + 1);
    expect(h.watch.polling, isTrue);
    expect(h.polled.last, 100);
    await h.watch.dispose();
  });

  test('a stream that never comes up keeps the poll at its interval', () async {
    final h = _Harness()..watch.start();
    h.streams.last.addError(Exception('unimplemented'));
    await _wait(220);
    expect(h.fetches, greaterThanOrEqualTo(4));
    expect(h.watch.polling, isTrue);
    await h.watch.dispose();
  });

  test('a poll that answers after the first frame is dropped', () async {
    final h = _Harness()..pendingFetch = Completer<int>();
    h.watch.start();
    await _wait(5);
    h.streams.last.add(2);
    await _wait(5);
    h.pendingFetch!.complete(1);
    await _wait(5);
    expect(h.frames, [2]);
    expect(h.polled, isEmpty);
    await h.watch.dispose();
  });

  test('a poll error while down reaches the error callback', () async {
    final h = _Harness()..pendingFetch = (Completer<int>()..completeError(Exception('down')));
    h.watch.start();
    await _wait(5);
    expect(h.errors, hasLength(1));
    await h.watch.dispose();
  });

  test('a refresh reads one snapshot while the stream runs, and a frame wins', () async {
    final h = _Harness()..watch.start();
    h.streams.last.add(1);
    await _wait(5);
    h.polled.clear();

    await h.watch.refresh();
    expect(h.polled, [100]);
    expect(h.watch.polling, isFalse);

    h.pendingFetch = Completer<int>();
    final refresh = h.watch.refresh();
    h.streams.last.add(2);
    await _wait(5);
    h.pendingFetch!.complete(99);
    await refresh;
    expect(h.polled, [100]);
    expect(h.frames, [1, 2]);
    await h.watch.dispose();
  });

  test('a heartbeat during a refresh does not drop the read', () async {
    final h = _Harness()..watch.start();
    h.streams.last.add(1);
    await _wait(5);
    h.polled.clear();

    h.pendingFetch = Completer<int>();
    final refresh = h.watch.refresh();
    h.streams.last.add(0);
    await _wait(5);
    h.pendingFetch!.complete(7);
    await refresh;
    expect(h.polled, [7]);
    await h.watch.dispose();
  });
}
