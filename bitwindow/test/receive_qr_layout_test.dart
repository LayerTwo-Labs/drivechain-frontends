import 'package:bitwindow/pages/wallet/wallet_receive.dart';
import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

import 'test_utils.dart';

const _address = 'bcrt1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq';
const _cardTitle = 'Receive Bitcoin on L1';

class _FakeBitwindow extends ChangeNotifier implements BitwindowRPC {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeAddressBook extends ChangeNotifier implements AddressBookProvider {
  @override
  List<AddressBookEntry> get receiveEntries => const [];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHDWallet extends ChangeNotifier implements HDWalletProvider {
  @override
  bool get isInitialized => true;

  @override
  String get bip47PaymentCode => '';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTransactions extends ChangeNotifier implements TransactionProvider {
  _FakeTransactions(this.addressTypes);

  @override
  String address = _address;

  @override
  String addressDerivationPath = "m/84'/1'/0'/0/0";

  @override
  final List<wmpb.AddressType> addressTypes;

  @override
  wmpb.AddressType get addressType => addressTypes.first;

  @override
  List<ReceiveAddress> receiveAddresses = [];

  @override
  Future<void> fetch() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWalletReader extends ChangeNotifier implements WalletReaderProvider {
  @override
  String? activeWalletId = 'wallet-1';

  @override
  WalletData? get activeWallet => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestratorWallet implements OrchestratorWalletRPC {
  @override
  Future<wmpb.GetNewAddressResponse> getNewAddress(String walletId, {wmpb.AddressType? addressType}) async {
    return wmpb.GetNewAddressResponse(address: _address);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  @override
  OrchestratorWalletRPC wallet = _FakeOrchestratorWallet();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeConf implements BitcoinConfProvider {
  @override
  BitcoinNetwork get network => BitcoinNetwork.BITCOIN_NETWORK_REGTEST;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pumpReceiveTab(
  WidgetTester tester, {
  List<wmpb.AddressType> addressTypes = const [wmpb.AddressType.ADDRESS_TYPE_SEGWIT],
}) async {
  GetIt.I.registerSingleton<BitwindowRPC>(_FakeBitwindow());
  GetIt.I.registerSingleton<AddressBookProvider>(_FakeAddressBook());
  GetIt.I.registerSingleton<HDWalletProvider>(_FakeHDWallet());
  GetIt.I.registerSingleton<TransactionProvider>(_FakeTransactions(addressTypes));
  GetIt.I.registerSingleton<WalletReaderProvider>(_FakeWalletReader());
  GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator());
  GetIt.I.registerSingleton<BitcoinConfProvider>(_FakeConf());

  await tester.pumpSailPage(const ReceiveTab());
  await tester.pump();
}

Finder _addressCard() => find.widgetWithText(SailCard, _cardTitle);

Finder _qr() => find.descendant(of: _addressCard(), matching: find.byType(QrImageView));

Finder _addressField() => find.descendant(of: _addressCard(), matching: find.byType(SailTextField)).first;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  setUp(() async {
    await GetIt.I.reset();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('the QR code sits inside the address card', (tester) async {
    await _pumpReceiveTab(tester);

    expect(_addressCard(), findsOneWidget);
    expect(_qr(), findsOneWidget);
  });

  testWidgets('the QR code sits to the right of the address field', (tester) async {
    await _pumpReceiveTab(tester);

    expect(tester.getTopLeft(_qr()).dx, greaterThanOrEqualTo(tester.getTopRight(_addressField()).dx));
  });

  testWidgets('the address type dropdown sits in the card header', (tester) async {
    await _pumpReceiveTab(
      tester,
      addressTypes: const [wmpb.AddressType.ADDRESS_TYPE_SEGWIT, wmpb.AddressType.ADDRESS_TYPE_TAPROOT],
    );

    final dropdown = find.descendant(
      of: _addressCard(),
      matching: find.byType(SailDropdownButton<wmpb.AddressType>),
    );
    expect(dropdown, findsOneWidget);
    expect(tester.getTopLeft(dropdown).dy, lessThan(tester.getTopLeft(_addressField()).dy));
  });

  testWidgets('a wallet with one address type shows no dropdown', (tester) async {
    await _pumpReceiveTab(tester);

    expect(find.byType(SailDropdownButton<wmpb.AddressType>), findsNothing);
  });

  testWidgets('the derivation path sits beside the copy button', (tester) async {
    await _pumpReceiveTab(tester);

    final path = find.descendant(of: _addressCard(), matching: find.text("m/84'/1'/0'/0/0"));
    expect(path, findsOneWidget);
    expect(tester.getTopLeft(path).dx, lessThan(tester.getTopLeft(_qr()).dx));
  });
}
