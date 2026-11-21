import 'package:bitwindow/providers/fork_provider.dart';
import 'package:bitwindow/widgets/fork_countdown_timer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

class _Fork extends ForkProvider {
  int reads = 0;
  bool _show = false;

  @override
  bool get showCountdown {
    reads++;
    return _show;
  }

  @override
  set showCountdown(bool value) => _show = value;
}

void main() {
  test('the fork strip counts the blocks that are left', () {
    expect(forkStripLabel('eCash', 10), 'ECASH HARDFORK · IN 10 BLOCKS');
    expect(forkStripLabel('eCash', 1), 'ECASH HARDFORK · IN 1 BLOCK');
    expect(forkStripLabel('', 0), 'HARDFORK · IN 0 BLOCKS');
  });

  testWidgets('a hidden strip does not rebuild each second', (tester) async {
    final fork = _Fork();
    GetIt.I.registerSingleton<ForkProvider>(fork);
    addTearDown(GetIt.I.reset);

    await tester.pumpWidget(const Directionality(textDirection: TextDirection.ltr, child: ForkCountdownTimer()));
    final reads = fork.reads;
    await tester.pump(const Duration(seconds: 3));

    expect(fork.reads, reads);
    expect(find.byType(SizedBox), findsOneWidget);
  });

  testWidgets('a shown strip ticks only its clock', (tester) async {
    final fork = _Fork()
      ..showCountdown = true
      ..forkHeight = 100
      ..forkTargetDate = DateTime.now().add(const Duration(seconds: 30, milliseconds: 500));
    GetIt.I.registerSingleton<ForkProvider>(fork);
    addTearDown(GetIt.I.reset);

    await tester.pumpWidget(
      SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: const Directionality(textDirection: TextDirection.ltr, child: ForkCountdownTimer()),
      ),
    );
    expect(find.text('00:00:30'), findsOneWidget);
    final reads = fork.reads;

    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 1100)));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('00:00:29'), findsOneWidget);
    expect(fork.reads, reads);
  });

  testWidgets('the strip fits a 390 px phone', (tester) async {
    await loadBundledFonts();
    final fork = _Fork()
      ..showCountdown = true
      ..networkName = 'Regtest'
      ..forkHeight = 400
      ..currentHeaders = 102
      ..forkTargetDate = DateTime.now().add(const Duration(days: 2, hours: 1));
    GetIt.I.registerSingleton<ForkProvider>(fork);
    addTearDown(GetIt.I.reset);

    await tester.pumpWidget(
      SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(width: 390, child: ForkCountdownTimer()),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getRect(find.text('BLOCK ~400')).right, lessThanOrEqualTo(390));
  });
}
