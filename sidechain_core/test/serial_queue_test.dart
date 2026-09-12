import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/sidechain_core.dart';

void main() {
  group('SerialQueue', () {
    test('runs one task at a time, in the order the callers arrive', () async {
      final queue = SerialQueue();
      final ran = <String>[];
      final slow = Completer<void>();

      final first = queue.add(() async {
        await slow.future;
        ran.add('slow');
      });
      final second = queue.add(() async => ran.add('quick'));

      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(ran, isEmpty, reason: 'the first task holds the queue');

      slow.complete();
      await Future.wait([first, second]);
      expect(ran, ['slow', 'quick'], reason: 'the newest task lands last');
    });

    test('a failed task leaves the queue running', () async {
      final queue = SerialQueue();

      await expectLater(queue.add(() async => throw StateError('boom')), throwsStateError);
      expect(await queue.add(() async => 'done'), 'done');
    });
  });
}
