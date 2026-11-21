import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/config/backend_sidechain_runtime.dart';

void main() {
  test('the wait ends less than 50 ms after drivechaind answers', () {
    fakeAsync((async) {
      final start = async.elapsed;
      Duration? doneAt;
      waitForBackendReady(() async {
        if (async.elapsed - start < const Duration(milliseconds: 120)) {
          throw StateError('connection refused');
        }
      }).then((ready) {
        expect(ready, isTrue);
        doneAt = async.elapsed;
      });
      async.elapse(const Duration(seconds: 2));

      expect(doneAt, isNotNull);
      expect(doneAt! - start, lessThan(const Duration(milliseconds: 170)));
    });
  });

  test('the wait returns false after the timeout', () {
    fakeAsync((async) {
      bool? result;
      waitForBackendReady(
        () async => throw StateError('connection refused'),
        timeout: const Duration(seconds: 1),
      ).then((ready) => result = ready);
      async.elapse(const Duration(milliseconds: 900));
      expect(result, isNull);
      async.elapse(const Duration(milliseconds: 200));
      expect(result, isFalse);
    });
  });
}
