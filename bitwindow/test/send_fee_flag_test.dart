import 'package:bitwindow/pages/wallet/wallet_send.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

void main() {
  setUp(() async {
    await GetIt.I.reset();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Future<RecipientModel> pumpCheckbox(WidgetTester tester) async {
    final recipient = RecipientModel();
    await tester.pumpSailPage(
      StatefulBuilder(
        builder: (context, setState) => AddFeeOnTopCheckbox(
          subtractFee: recipient.subtractFee,
          onSubtractFeeChanged: (val) => setState(() => recipient.subtractFee = val),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return recipient;
  }

  Future<int> pumpRow(WidgetTester tester, {required bool canRemove}) async {
    var removed = 0;
    await tester.pumpSailPage(
      SizedBox(
        width: 1000,
        child: RecipientRow(
          index: 0,
          recipient: RecipientModel(),
          addressBookEntries: const [],
          onAddressSelected: (_) {},
          onUseAvailableBalance: (_) async {},
          currentUnit: BitcoinUnit.btc,
          onSaveToAddressBook: (context, address) async {},
          onRemove: canRemove ? () => removed++ : null,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return removed;
  }

  testWidgets('Add fee on top of amount is ticked by default', (tester) async {
    final recipient = await pumpCheckbox(tester);

    expect(recipient.subtractFee, isFalse);
    expect(tester.widget<SailCheckbox>(find.byType(SailCheckbox)).value, isTrue);
  });

  testWidgets('unticking the box subtracts the fee from the amount', (tester) async {
    final recipient = await pumpCheckbox(tester);

    await tester.tap(find.byType(SailCheckbox));
    await tester.pumpAndSettle();

    expect(recipient.subtractFee, isTrue);
  });

  testWidgets('a single recipient row has no remove button', (tester) async {
    await pumpRow(tester, canRemove: false);

    expect(find.byKey(const Key('recipient_remove_0')), findsNothing);
    expect(find.byKey(const Key('recipient_address_0')), findsOneWidget);
    expect(find.byKey(const Key('recipient_amount_0')), findsOneWidget);
  });

  testWidgets('a row among several recipients has a remove button', (tester) async {
    await pumpRow(tester, canRemove: true);

    expect(find.byKey(const Key('recipient_remove_0')), findsOneWidget);
  });
}
