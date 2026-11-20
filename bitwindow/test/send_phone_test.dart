import 'package:bitwindow/pages/wallet/wallet_send.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

Finder _button(String label) => find.byWidgetPredicate((w) => w is SailButton && w.label == label);

Future<void> _pumpRow(WidgetTester tester) async {
  await tester.pumpSailPage(
    SizedBox(
      width: double.infinity,
      child: RecipientRow(
        index: 0,
        recipient: RecipientModel(),
        addressBookEntries: const [],
        onAddressSelected: (_) {},
        onUseAvailableBalance: (_) async {},
        currentUnit: BitcoinUnit.btc,
        onSaveToAddressBook: (context, address) async {},
        onRemove: () {},
      ),
    ),
  );
  if (SailStyleValues.phoneLayoutOverride == true) {
    await tester.usePhoneSize();
  }
  await tester.pumpAndSettle();
}

Future<void> _pumpActions(WidgetTester tester) async {
  await tester.pumpSailPage(
    SizedBox(
      width: double.infinity,
      child: SendActions(
        creating: false,
        sendsNow: false,
        onCreate: () async {},
        onCancel: () {},
        onClear: () async {},
        onAirgap: () async {},
        deviceType: null,
        onDevice: () async {},
      ),
    ),
  );
  if (SailStyleValues.phoneLayoutOverride == true) {
    await tester.usePhoneSize();
  }
  await tester.pump();
}

void main() {
  setUpAll(loadBundledFonts);

  setUp(() async {
    await GetIt.I.reset();
  });

  tearDown(() async {
    SailStyleValues.phoneLayoutOverride = null;
    await GetIt.I.reset();
  });

  testWidgets('on a phone the amount and the remove button share a line under the address', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await _pumpRow(tester);

    final address = tester.getRect(find.byKey(const Key('recipient_address_0')));
    final amount = tester.getRect(find.byKey(const Key('recipient_amount_0')));
    final remove = tester.getRect(find.byKey(const Key('recipient_remove_0')));
    expect(amount.top, greaterThanOrEqualTo(address.bottom));
    expect(remove.center.dy, closeTo(amount.center.dy, 1));
    expect(remove.left, greaterThan(amount.right - 1));
  });

  testWidgets('on a phone the amount field shows the unit before MAX', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await _pumpRow(tester);

    final unit = find.descendant(
      of: find.byKey(const Key('recipient_amount_0')),
      matching: find.text(BitcoinUnit.btc.symbol),
    );
    expect(unit, findsOneWidget);
    expect(tester.getRect(unit).right, lessThan(tester.getRect(_button('MAX')).left));
  });

  testWidgets('on a desktop the address, the amount and the remove button share one row', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await tester.binding.setSurfaceSize(const Size(1200, 720));
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
          onRemove: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final address = tester.getRect(find.byKey(const Key('recipient_address_0')));
    final amount = tester.getRect(find.byKey(const Key('recipient_amount_0')));
    expect(amount.left, greaterThan(address.right));
    expect(
      find.descendant(of: find.byKey(const Key('recipient_amount_0')), matching: find.text(BitcoinUnit.btc.symbol)),
      findsNothing,
    );
  });

  testWidgets('on a phone External signer and Clear All sit side by side', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await _pumpActions(tester);

    final create = tester.getRect(_button('Create Transaction'));
    final airgap = tester.getRect(_button('External signer (airgap)'));
    final clear = tester.getRect(_button('Clear All'));
    expect(airgap.center.dy, closeTo(clear.center.dy, 1));
    expect(clear.left, greaterThan(airgap.right - 1));
    expect(airgap.top, greaterThan(create.bottom - 1));
    expect(airgap.width, closeTo(clear.width, 1));
  });

  testWidgets('on a desktop External signer and Clear All stack', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await _pumpActions(tester);

    final airgap = tester.getRect(_button('External signer (airgap)'));
    final clear = tester.getRect(_button('Clear All'));
    expect(clear.top, greaterThan(airgap.bottom - 1));
  });
}
