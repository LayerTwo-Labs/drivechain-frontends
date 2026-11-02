import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/utils/lock.dart';

void main() {
  test('runs actions in call order', () async {
    final lock = Lock();
    final order = <int>[];
    await Future.wait([
      for (var i = 0; i < 20; i++)
        lock.synchronized(() async {
          await Future<void>.delayed(Duration(milliseconds: 20 - i));
          order.add(i);
        }),
    ]);
    expect(order, List.generate(20, (i) => i));
  });

  test('never runs two actions at the same time', () async {
    final lock = Lock();
    var running = 0;
    var most = 0;
    await Future.wait([
      for (var i = 0; i < 20; i++)
        lock.synchronized(() async {
          running++;
          most = running > most ? running : most;
          await Future<void>.delayed(const Duration(milliseconds: 2));
          running--;
        }),
    ]);
    expect(most, 1);
  });

  test('returns the result of a sync and an async action', () async {
    final lock = Lock();
    expect(await lock.synchronized(() => 7), 7);
    expect(await lock.synchronized(() async => 'x'), 'x');
  });

  test('gives the error to the caller and lets the next action run', () async {
    final lock = Lock();
    final failed = lock.synchronized<void>(() async => throw StateError('boom'));
    final next = lock.synchronized(() => 'ran');
    await expectLater(failed, throwsStateError);
    expect(await next, 'ran');
  });

  test('a sync throw also releases the lock', () async {
    final lock = Lock();
    await expectLater(lock.synchronized<void>(() => throw ArgumentError()), throwsArgumentError);
    expect(await lock.synchronized(() => 1), 1);
  });

  test('two locks do not wait for each other', () async {
    final a = Lock();
    final b = Lock();
    final gate = Completer<void>();
    final held = a.synchronized(() => gate.future);
    expect(await b.synchronized(() => 'free'), 'free');
    gate.complete();
    await held;
  });
}
