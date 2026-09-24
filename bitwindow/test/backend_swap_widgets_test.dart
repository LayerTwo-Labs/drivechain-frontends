import 'package:bitwindow/providers/backend_swap_provider.dart';
import 'package:bitwindow/widgets/backend_swap.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

void main() {
  late DateTime clock;
  late BackendSwapProvider swap;

  setUp(() {
    clock = DateTime(2026, 9, 24, 12);
    swap = BackendSwapProvider(tick: const Duration(minutes: 1), clock: () => clock);
  });

  tearDown(() => swap.dispose());

  testWidgets('the splash names the step and why the app waits', (tester) async {
    swap.report(BackendSwapStep.stop);
    await tester.pumpSailPage(BackendSwapSplash(swap: swap));

    expect(find.text('Old backend stops (0s)'), findsOneWidget);
    expect(find.text(BackendSwapStep.stop.detail), findsOneWidget);

    swap.finish();
  });

  testWidgets('the splash reads as a plain start when no swap runs', (tester) async {
    await tester.pumpSailPage(BackendSwapSplash(swap: swap));

    expect(find.text(splashStartLabel), findsOneWidget);
    expect(find.text(BackendSwapStep.stop.detail), findsNothing);
  });

  testWidgets('the detail lists the steps the app did', (tester) async {
    swap.report(BackendSwapStep.claim);
    swap.report(BackendSwapStep.stop);
    await tester.pumpSailPage(BackendSwapSteps(swap: swap));

    expect(find.text(backendSwapReason), findsOneWidget);
    expect(find.text(BackendSwapStep.claim.label), findsOneWidget);
    expect(find.text('Old backend stops (0s)'), findsOneWidget);

    swap.finish();
  });

  testWidgets('the bottom bar names the step and offers the steps', (tester) async {
    swap.report(BackendSwapStep.stop);
    await tester.pumpSailPage(BackendSwapBar(swap: swap, child: const SizedBox.shrink()));

    expect(find.text('Old backend stops (0s)'), findsOneWidget);
    expect(find.text(backendSwapOpenSteps), findsOneWidget);

    swap.finish();
  });

  testWidgets('the bottom bar keeps its child when no swap runs', (tester) async {
    await tester.pumpSailPage(BackendSwapBar(swap: swap, child: SailText.primary12('the banner')));

    expect(find.text('the banner'), findsOneWidget);
    expect(find.text(backendSwapOpenSteps), findsNothing);
  });

  testWidgets('the detail names a swap that stopped', (tester) async {
    swap.report(BackendSwapStep.stop);
    await tester.pumpSailPage(BackendSwapSteps(swap: swap));
    swap.fail(StateError('no bitwindowd binary'));
    await tester.pump();

    expect(find.text('The swap stopped: Bad state: no bitwindowd binary'), findsOneWidget);
    expect(find.text(backendSwapDone), findsNothing);
  });

  testWidgets('the detail says the new backend runs once the swap ends', (tester) async {
    swap.report(BackendSwapStep.stop);
    await tester.pumpSailPage(BackendSwapSteps(swap: swap));
    swap.finish();
    await tester.pump();

    expect(find.text(backendSwapDone), findsOneWidget);
  });
}
