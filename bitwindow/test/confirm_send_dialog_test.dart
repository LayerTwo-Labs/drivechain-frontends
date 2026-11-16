import 'package:bitwindow/widgets/confirm_send_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

const addressA = 'ecash:qp3wjpa3tjlj042z2wv7hahsldgwhwy0rq9sywjpyy';
const addressB = 'ecash:qr7za4c9kd0x3tq9w8yv5m2lp6n4h8sfj2c0ezu7dk';

SendConfirmation confirmation({
  List<({String address, int sats})>? payments,
  bool feeFromAmount = false,
  int totalSats = 35_002_260,
}) => SendConfirmation(
  payments: payments ?? [(address: addressA, sats: 25_000_000), (address: addressB, sats: 10_000_000)],
  payFrom: 'Largest First',
  feeTarget: 'Next block',
  feeSats: 2260,
  feeIsEstimate: false,
  feeFromAmount: feeFromAmount,
  totalSats: totalSats,
  unit: BitcoinUnit.btc,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await GetIt.I.reset();
    await registerTestDependencies();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('confirmSendPayments', () {
    test('keeps each address with its amount', () {
      expect(
        confirmSendPayments(
          destinations: {addressA: 25_000_000, addressB: 10_000_000},
          feeSats: 2260,
          feeFromAmount: false,
        ),
        [(address: addressA, sats: 25_000_000), (address: addressB, sats: 10_000_000)],
      );
    });

    test('takes the fee out of the amount when the recipient pays the fee', () {
      expect(
        confirmSendPayments(destinations: {addressA: 25_000_000}, feeSats: 2260, feeFromAmount: true),
        [(address: addressA, sats: 24_997_740)],
      );
    });

    test('never shows a negative amount', () {
      expect(
        confirmSendPayments(destinations: {addressA: 1000}, feeSats: 2260, feeFromAmount: true),
        [(address: addressA, sats: 0)],
      );
    });
  });

  Future<bool? Function()> openDialog(WidgetTester tester, SendConfirmation send) async {
    bool? confirmed;
    await tester.pumpSailPage(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async => confirmed = await askConfirmSend(context, send),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return () => confirmed;
  }

  testWidgets('shows each address in full with its amount, the fee and the total', (tester) async {
    await openDialog(tester, confirmation());

    expect(find.text('Confirm send'), findsOneWidget);
    expect(find.text('2 recipients'), findsOneWidget);
    expect(find.text(addressA), findsOneWidget);
    expect(find.text(addressB), findsOneWidget);
    expect(find.text(formatBitcoinWithUnit(0.25, BitcoinUnit.btc)), findsOneWidget);
    expect(find.text(formatBitcoinWithUnit(0.1, BitcoinUnit.btc)), findsOneWidget);
    expect(find.text('Largest First'), findsOneWidget);
    expect(find.text('Next block · ${formatBitcoinWithUnit(0.0000226, BitcoinUnit.btc)}'), findsOneWidget);
    expect(find.text(formatBitcoinWithUnit(0.3500226, BitcoinUnit.btc)), findsOneWidget);
  });

  testWidgets('a fee from the amount says so on the fee line', (tester) async {
    await openDialog(
      tester,
      confirmation(
        payments: [(address: addressA, sats: 24_997_740)],
        feeFromAmount: true,
        totalSats: 25_000_000,
      ),
    );

    expect(find.text('1 recipient'), findsOneWidget);
    expect(
      find.text('Next block · ${formatBitcoinWithUnit(0.0000226, BitcoinUnit.btc)} · from the amount'),
      findsOneWidget,
    );
  });

  testWidgets('Send returns true', (tester) async {
    final result = await openDialog(tester, confirmation());

    await tester.tap(find.text('Send').first);
    await tester.pumpAndSettle();

    expect(result(), isTrue);
    expect(find.text('Confirm send'), findsNothing);
  });

  testWidgets('Cancel returns false', (tester) async {
    final result = await openDialog(tester, confirmation());

    await tester.tap(find.text('Cancel').first);
    await tester.pumpAndSettle();

    expect(result(), isFalse);
  });

  testWidgets('Esc closes the dialog and does not send', (tester) async {
    final result = await openDialog(tester, confirmation());

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    expect(result(), isFalse);
    expect(find.text('Confirm send'), findsNothing);
  });

  testWidgets('Enter does not send', (tester) async {
    final result = await openDialog(tester, confirmation());

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();

    expect(result(), isNull);
    expect(find.text('Confirm send'), findsOneWidget);
  });
}
