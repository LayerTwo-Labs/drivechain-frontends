import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Future<void> pumpBalance(
  WidgetTester tester, {
  required double balance,
  required double pendingBalance,
  required bool showUnconfirmed,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: Scaffold(
          body: BalanceDisplay(
            balance: balance,
            pendingBalance: pendingBalance,
            balanceSyncing: false,
            showUnconfirmed: showUnconfirmed,
            onToggleUnconfirmed: () {},
            usdBalance: null,
          ),
        ),
      ),
    ),
  );
  expect(tester.takeException(), isNull);
}

Finder get unconfirmed => find.byWidgetPredicate(
  (widget) => widget is Tooltip && widget.message == 'Unconfirmed balance',
);

void main() {
  // A sidechain deposit waits hours for the mainchain block that carries it.
  // The bottom nav must report that money without a toggle, or the user reads
  // the wallet as empty and thinks the deposit is lost.
  testWidgets('the bottom nav shows a pending balance with the toggle off', (tester) async {
    await pumpBalance(tester, balance: 0, pendingBalance: 0.01, showUnconfirmed: false);

    expect(unconfirmed, findsOneWidget);
    expect(find.text(formatBitcoin(0.01)), findsOneWidget);
  });

  testWidgets('nothing pending and the toggle off shows only the confirmed balance', (tester) async {
    await pumpBalance(tester, balance: 1.5, pendingBalance: 0, showUnconfirmed: false);

    expect(unconfirmed, findsNothing);
  });

  testWidgets('the toggle shows the unconfirmed balance while it reads zero', (tester) async {
    await pumpBalance(tester, balance: 1.5, pendingBalance: 0, showUnconfirmed: true);

    expect(unconfirmed, findsOneWidget);
  });
}
