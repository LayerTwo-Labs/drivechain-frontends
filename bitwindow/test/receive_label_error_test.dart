import 'package:bitwindow/pages/wallet/wallet_receive.dart';
import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

import 'test_utils.dart';

const _address = 'bcrt1qc862dcz4ellepph35s0lmjg0nn5tt84zte54lw';
const _duplicate = 'an address book entry with label "savings" already exists';

class _FakeAddressBook extends ChangeNotifier implements AddressBookProvider {
  @override
  List<AddressBookEntry> get receiveEntries => [];

  @override
  Future<void> createEntry(String label, String address, Direction direction) async {
    throw Exception(_duplicate);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHDWallet extends ChangeNotifier implements HDWalletProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTransactions extends ChangeNotifier implements TransactionProvider {
  @override
  List<ReceiveAddress> receiveAddresses = [ReceiveAddress(address: _address)];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeConf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_REGTEST;

  @override
  String ecashNetworkId = '';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<AddressBookProvider>(_FakeAddressBook());
    GetIt.I.registerSingleton<HDWalletProvider>(_FakeHDWallet());
    GetIt.I.registerSingleton<TransactionProvider>(_FakeTransactions());
    GetIt.I.registerSingleton<BitcoinConfProvider>(_FakeConf());
  });

  tearDown(() => GetIt.I.reset());

  testWidgets('a failed label save shows the error in the dialog', (tester) async {
    await registerTestDependencies();
    final model = ReceivePageViewModel();
    await tester.pumpSailPage(ReceiveAddressesTable(model: model));
    await tester.pumpAndSettle();

    await tester.tap(find.text(_address), buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Label'));
    await tester.pumpAndSettle();

    final dialog = find.byType(SailCardEditValues);
    await tester.enterText(find.descendant(of: dialog, matching: find.byType(TextField)), 'savings');
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();

    expect(dialog, findsOneWidget);
    expect(
      find.descendant(of: dialog, matching: find.widgetWithText(SailInlineError, 'Exception: $_duplicate')),
      findsOneWidget,
    );
    expect(model.modelError, isNull);
  });
}
