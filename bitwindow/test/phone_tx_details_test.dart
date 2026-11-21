import 'package:bitwindow/pages/explorer/block_explorer_dialog.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => SailStyleValues.phoneLayoutOverride = null);

  final inputs = [
    TransactionInput(
      index: 0,
      valueSats: Int64(75000000),
      address: 'ecash:qz8f3m2abcdefghijklmnopv0k9e',
      sequence: Int64(1),
      prevTxid: 'ab' * 32,
    ),
    TransactionInput(
      index: 1,
      valueSats: Int64(25000226),
      address: 'ecash:qr4p0x7abcdefghijklmnopd2h6s',
      sequence: Int64(1),
      prevTxid: 'ab' * 32,
    ),
  ];
  final outputs = [
    TransactionOutput(
      index: 0,
      valueSats: Int64(90000000),
      address: 'ecash:qp9k2d1abcdefghijklmnm3x8r',
      scriptType: 'witness_v0_keyhash',
    ),
    TransactionOutput(
      index: 1,
      valueSats: Int64(10000000),
      address: 'ecash:qz7c5n4abcdefghijklmnt1w0a',
      scriptType: 'witness_v0_keyhash',
      isMine: true,
    ),
  ];

  double cellWidth(WidgetTester tester, String value) =>
      tester.getSize(find.ancestor(of: find.text(value).first, matching: find.byType(SailTableCell))).width;

  Future<void> pump(WidgetTester tester, Widget child, double width) async {
    await loadBundledFonts();
    await tester.pumpSailPage(SizedBox(width: width, height: 400, child: child));
    await tester.pumpAndSettle();
  }

  testWidgets('on a phone the inputs show a narrow index and an amount that fills the row', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await pump(tester, TxInputsTable(inputs: inputs), 358);

    expect(find.text('Address'), findsNothing);
    expect(find.text('Sequence'), findsNothing);
    final index = cellWidth(tester, '0');
    expect(index, lessThan(40));
    final amount = GetIt.I<FormatterProvider>().formatSats(75000000);
    expect(cellWidth(tester, amount), closeTo(358 - index - 8, 2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('on a phone the outputs show the index, the owner and a type that fills the row', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await pump(tester, TxOutputsTable(outputs: outputs), 358);

    expect(find.text('Amount'), findsNothing);
    expect(find.text('Owner'), findsOneWidget);
    final index = cellWidth(tester, '0');
    expect(index, lessThan(40));
    expect(cellWidth(tester, 'Your address'), closeTo(112, 1));
    expect(tester.getSize(find.text('Your address')).height, tester.getSize(find.text('0')).height);
    expect(cellWidth(tester, 'witness_v0_keyhash'), closeTo(358 - index - 112 - 16, 2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('on the desktop the inputs and outputs keep every column', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await pump(tester, TxOutputsTable(outputs: outputs), 1100);

    expect(find.text('Amount'), findsOneWidget);
    expect(find.text('Address'), findsOneWidget);
    expect(cellWidth(tester, '0'), greaterThan(40));
  });
}
