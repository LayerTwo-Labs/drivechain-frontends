import 'package:bitwindow/main.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the wait ends less than 50 ms after drivechaind answers', () {
    fakeAsync((async) {
      final start = async.elapsed;
      Duration? readyAt;
      Duration? doneAt;
      waitForDrivechaind(() async {
        if (async.elapsed - start < const Duration(milliseconds: 120)) {
          throw StateError('connection refused');
        }
        readyAt ??= async.elapsed;
      }).then((ready) {
        expect(ready, isTrue);
        doneAt = async.elapsed;
      });
      async.elapse(const Duration(seconds: 2));

      expect(doneAt, isNotNull);
      expect(doneAt! - start, lessThan(const Duration(milliseconds: 170)));
      expect(doneAt, readyAt);
    });
  });

  test('the wait returns false after the timeout', () {
    fakeAsync((async) {
      bool? result;
      waitForDrivechaind(
        () async => throw StateError('connection refused'),
        timeout: const Duration(seconds: 1),
      ).then((ready) => result = ready);
      async.elapse(const Duration(milliseconds: 900));
      expect(result, isNull);
      async.elapse(const Duration(milliseconds: 200));
      expect(result, isFalse);
    });
  });

  test('slow failed probes still end the wait at the timeout', () async {
    var probes = 0;
    final ready = await waitForDrivechaind(
      () async {
        probes++;
        await Future<void>.delayed(const Duration(milliseconds: 40));
        throw StateError('connection timed out');
      },
      every: const Duration(milliseconds: 1),
      timeout: const Duration(milliseconds: 200),
    );

    expect(ready, isFalse);
    expect(probes, lessThan(10));
  });
}
