import 'package:bitwindow/pages/wallet/wallet_receive.dart';
import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

import 'test_utils.dart';

const _address = 'bcrt1qc862dcz4ellepph35s0lmjg0nn5tt84zte54lw';

class _FakeAddressBook extends ChangeNotifier implements AddressBookProvider {
  @override
  List<AddressBookEntry> get receiveEntries => [];

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

  testWidgets('Add Label closes the row menu before the dialog opens', (tester) async {
    await registerTestDependencies();
    await tester.pumpSailPage(ReceiveAddressesTable(model: ReceivePageViewModel()));
    await tester.pumpAndSettle();

    await tester.tap(find.text(_address), buttons: kSecondaryButton);
    await tester.pumpAndSettle();
    expect(find.text('View on mempool.space'), findsOneWidget);

    await tester.tap(find.text('Add Label'));
    await tester.pumpAndSettle();

    expect(find.text("Set a label and click Save when you're done"), findsOneWidget);
    expect(find.text('View on mempool.space'), findsNothing);
  });
}
