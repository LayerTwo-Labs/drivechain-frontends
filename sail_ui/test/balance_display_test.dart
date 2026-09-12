import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Future<void> pumpBalance(
  WidgetTester tester, {
  required double balance,
  required double pendingBalance,
  required bool showUnconfirmed,
  double sidechainBalance = 0,
  double sidechainPendingBalance = 0,
}) async {
  await tester.binding.setSurfaceSize(const Size(1400, 400));
  addTearDown(() => tester.binding.setSurfaceSize(null));
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
            sidechainBalance: sidechainBalance,
            sidechainPendingBalance: sidechainPendingBalance,
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

Finder get sidechainTotal => find.textContaining('Sidechains ');

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

  // One number over L1 and the sidechains together reads as mainchain money
  // the Send page can spend. It cannot.
  testWidgets('a chain window with no sidechain balance shows one figure', (tester) async {
    await pumpBalance(tester, balance: 1.5, pendingBalance: 0, showUnconfirmed: false);

    expect(find.textContaining(formatBitcoin(1.5)), findsOneWidget);
    expect(sidechainTotal, findsNothing);
  });

  testWidgets('a sidechain balance leaves the mainchain figure alone', (tester) async {
    await pumpBalance(
      tester,
      balance: 0,
      pendingBalance: 330.99479104,
      showUnconfirmed: false,
      sidechainBalance: 2.01999,
      sidechainPendingBalance: 1,
    );

    expect(find.textContaining(formatBitcoin(0)), findsOneWidget);
    expect(find.text(formatBitcoin(330.99479104)), findsOneWidget);
    expect(find.text('Sidechains ${formatBitcoin(2.01999)}'), findsOneWidget);
    expect(find.text(formatBitcoin(1)), findsOneWidget);
  });

  testWidgets('a sidechain figure with nothing pending shows one number', (tester) async {
    await pumpBalance(
      tester,
      balance: 1,
      pendingBalance: 0,
      showUnconfirmed: false,
      sidechainBalance: 2.5,
    );

    expect(find.text('Sidechains ${formatBitcoin(2.5)}'), findsOneWidget);
    expect(find.text(formatBitcoin(0)), findsNothing);
  });
}
