import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/utils/hidden_window_timers.dart';

void main() {
  test('a paused zone runs no timer, and runMissed runs each due timer one time', () {
    fakeAsync((async) {
      final timers = HiddenWindowTimers(now: async.getClock(DateTime(2026)).now);
      final zone = Zone.current.fork(specification: timers.zoneSpecification);
      var polls = 0;
      var delayed = 0;
      var later = 0;
      zone.run(() {
        Timer.periodic(const Duration(seconds: 5), (_) => polls++);
        Timer(const Duration(seconds: 3), () => delayed++);
        Timer(const Duration(minutes: 5), () => later++);
      });

      async.elapse(const Duration(seconds: 6));
      expect((polls, delayed), (1, 1));

      timers.pause();
      zone.run(() => Timer(Duration.zero, () => delayed++));
      async.elapse(const Duration(minutes: 1));
      expect((polls, delayed), (1, 1));

      timers.resume();
      async.elapse(const Duration(seconds: 1));
      expect((polls, delayed), (1, 1));

      timers.runMissed();
      expect((polls, delayed, later), (2, 2, 0));
      async.elapse(const Duration(seconds: 5));
      expect(polls, 3);
      async.elapse(const Duration(minutes: 4));
      expect(later, 1);
    });
  });

  test('a timer that the zone cancels while paused does not run', () {
    fakeAsync((async) {
      final timers = HiddenWindowTimers(now: async.getClock(DateTime(2026)).now);
      final zone = Zone.current.fork(specification: timers.zoneSpecification);
      var runs = 0;
      late Timer timer;
      zone.run(() => timer = Timer(const Duration(seconds: 1), () => runs++));

      timers.pause();
      async.elapse(const Duration(seconds: 2));
      expect(timer.isActive, isTrue);
      timer.cancel();
      timers.resume();
      timers.runMissed();
      async.elapse(const Duration(seconds: 2));

      expect(runs, 0);
      expect(timer.isActive, isFalse);
    });
  });

  test('a missed timer that runMissed runs can cancel another missed timer', () {
    fakeAsync((async) {
      final timers = HiddenWindowTimers(now: async.getClock(DateTime(2026)).now);
      final zone = Zone.current.fork(specification: timers.zoneSpecification);
      var retries = 0;
      late Timer retry;
      zone.run(() {
        Timer(const Duration(seconds: 1), () => retry.cancel());
        retry = Timer(const Duration(seconds: 2), () => retries++);
      });

      timers.pause();
      async.elapse(const Duration(seconds: 3));
      timers.resume();
      timers.runMissed();
      async.elapse(const Duration(seconds: 3));

      expect(retries, 0);
    });
  });
}
