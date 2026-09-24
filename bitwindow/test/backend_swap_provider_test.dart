import 'package:bitwindow/providers/backend_swap_provider.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late DateTime clock;
  late BackendSwapProvider swap;

  setUp(() {
    clock = DateTime(2026, 9, 24, 12);
    swap = BackendSwapProvider(clock: () => clock);
  });

  tearDown(() => swap.dispose());

  test('no swap gives no label', () {
    expect(swap.swapping, isFalse);
    expect(swap.navLabel, '');
    expect(swap.seconds, 0);
    expect(swap.steps, isEmpty);
  });

  test('the label names the step and the seconds on it', () {
    swap.report(BackendSwapStep.stop);
    expect(swap.navLabel, 'Old backend stops (0s)');

    clock = clock.add(const Duration(seconds: 12));
    expect(swap.navLabel, 'Old backend stops (12s)');
  });

  test('a new step starts the seconds again', () {
    swap.report(BackendSwapStep.stop);
    clock = clock.add(const Duration(seconds: 12));
    swap.report(BackendSwapStep.start);

    expect(swap.seconds, 0);
    expect(swap.steps, [BackendSwapStep.stop, BackendSwapStep.start]);
  });

  test('the same step twice keeps the seconds', () {
    swap.report(BackendSwapStep.stop);
    clock = clock.add(const Duration(seconds: 12));
    swap.report(BackendSwapStep.stop);

    expect(swap.seconds, 12);
    expect(swap.steps, [BackendSwapStep.stop]);
  });

  test('the end clears the report', () {
    swap.report(BackendSwapStep.claim);
    swap.finish();

    expect(swap.swapping, isFalse);
    expect(swap.step, isNull);
    expect(swap.steps, isEmpty);
    expect(swap.navLabel, '');
  });

  test('a failure keeps the steps and names the step that stopped', () {
    swap.report(BackendSwapStep.stop);
    swap.fail(StateError('no bitwindowd binary'));

    expect(swap.swapping, isFalse);
    expect(swap.failedStep, BackendSwapStep.stop);
    expect(swap.steps, [BackendSwapStep.stop]);
    expect(swap.error, 'Bad state: no bitwindowd binary');
  });

  test('a new swap clears the last failure', () {
    swap.report(BackendSwapStep.stop);
    swap.fail(StateError('no bitwindowd binary'));
    swap.report(BackendSwapStep.stop);

    expect(swap.failedStep, isNull);
    expect(swap.error, isNull);
    expect(swap.steps, [BackendSwapStep.stop]);
  });

  test('a new swap drops the steps of the swap that stopped', () {
    swap.report(BackendSwapStep.stop);
    swap.fail(StateError('no bitwindowd binary'));
    swap.report(BackendSwapStep.claim);

    expect(swap.steps, [BackendSwapStep.claim]);
  });

  test('a second end tells nobody', () {
    var calls = 0;
    swap.addListener(() => calls++);

    swap.report(BackendSwapStep.stop);
    swap.finish();
    swap.finish();

    expect(calls, 2);
  });

  test('the seconds refresh while the step runs', () {
    fakeAsync((async) {
      final ticked = BackendSwapProvider(tick: const Duration(seconds: 1), clock: () => clock);
      var calls = 0;
      ticked.addListener(() => calls++);

      ticked.report(BackendSwapStep.stop);
      async.elapse(const Duration(seconds: 3));
      expect(calls, 4);

      ticked.finish();
      async.elapse(const Duration(seconds: 3));
      expect(calls, 5);
      ticked.dispose();
    });
  });
}
