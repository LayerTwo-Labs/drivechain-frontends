import 'package:bitwindow/pages/wallet/wallet_send.dart';
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

  Future<RecipientModel> pumpFields(WidgetTester tester, {bool canSubtractFee = true}) async {
    final recipient = RecipientModel();
    await tester.pumpSailPage(
      RecipientFields(
        index: 0,
        recipient: recipient,
        addressBookEntries: const [],
        selectedEntry: null,
        onAddressSelected: (_) {},
        onUseAvailableBalance: (_) async {},
        subtractFee: recipient.subtractFee,
        canSubtractFee: canSubtractFee,
        onSubtractFeeChanged: (val) => recipient.subtractFee = val,
        currentUnit: BitcoinUnit.btc,
        onSaveToAddressBook: (context, address) async {},
      ),
    );
    await tester.pumpAndSettle();
    return recipient;
  }

  testWidgets('Add fee on top of amount is ticked by default', (tester) async {
    final recipient = await pumpFields(tester);

    expect(recipient.subtractFee, isFalse);
    final checkbox = tester.widget<SailCheckbox>(
      find.byWidgetPredicate((w) => w is SailCheckbox && w.label == 'Add fee on top of amount'),
    );
    expect(checkbox.value, isTrue);
  });

  testWidgets('unticking the box subtracts the fee from the amount', (tester) async {
    final recipient = await pumpFields(tester);

    await tester.tap(find.byType(SailCheckbox));
    await tester.pumpAndSettle();

    expect(recipient.subtractFee, isTrue);
  });

  testWidgets('the box is absent when more than one recipient exists', (tester) async {
    await pumpFields(tester, canSubtractFee: false);

    expect(find.byType(SailCheckbox), findsNothing);
  });
}
