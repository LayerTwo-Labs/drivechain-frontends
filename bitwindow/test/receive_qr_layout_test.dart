import 'package:bitwindow/pages/wallet/wallet_receive.dart';
import 'package:bitwindow/providers/address_book_provider.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/widgets/burn_ecx_card.dart';
import 'package:bitwindow/widgets/claim_ecx_card.dart';
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
const _derivationPath = "m/84'/1'/0'/0/0";

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
  String addressDerivationPath = _derivationPath;

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
  bool get isWalletLocked => false;

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

class _FakeConf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_REGTEST;

  @override
  String ecashNetworkId = '';

  @override
  String currentNetworkOptionId = 'regtest';

  void changeNetwork(BitcoinNetwork value, String id) {
    network = value;
    ecashNetworkId = value == BitcoinNetwork.BITCOIN_NETWORK_ECASH ? id : '';
    currentNetworkOptionId = id;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pumpReceiveTab(
  WidgetTester tester, {
  List<wmpb.AddressType> addressTypes = const [wmpb.AddressType.ADDRESS_TYPE_SEGWIT],
  _FakeConf? conf,
}) async {
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await GetIt.I.reset();
  });
  GetIt.I.registerSingleton<BitwindowRPC>(_FakeBitwindow());
  GetIt.I.registerSingleton<AddressBookProvider>(_FakeAddressBook());
  GetIt.I.registerSingleton<HDWalletProvider>(_FakeHDWallet());
  GetIt.I.registerSingleton<TransactionProvider>(_FakeTransactions(addressTypes));
  GetIt.I.registerSingleton<WalletReaderProvider>(_FakeWalletReader());
  GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator());
  GetIt.I.registerSingleton<BitcoinConfProvider>(conf ?? _FakeConf());

  await tester.pumpSailPage(const ReceiveTab());
  await tester.pump();
}

Finder _addressCard() => find.widgetWithText(SailCard, _cardTitle);

Finder _qr() => find.descendant(of: _addressCard(), matching: find.byType(QrImageView));

Finder _addressField() => find.descendant(of: _addressCard(), matching: find.byType(SailTextField)).first;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await GetIt.I.reset();
  });

  testWidgets('the Receive tab shows the production burn below the claim on Alphanet', (tester) async {
    final conf = _FakeConf()..changeNetwork(BitcoinNetwork.BITCOIN_NETWORK_ECASH, 'alphanet');
    await _pumpReceiveTab(tester, conf: conf);

    final card = tester.widget<BurnEcxCard>(find.byType(BurnEcxCard));
    expect(card.burnAddress, '1BitcoinEaterAddressDontSendf59kuE');
    expect(card.minimumSats, 100000000000);
    final title = find
        .text('Burn Alphanet Coins')
        .evaluate()
        .where((element) => element.findAncestorWidgetOfExactType<SailButton>() == null);
    expect(title, hasLength(1));
    expect(
      find.byWidgetPredicate((widget) => widget is SailButton && widget.label == 'Burn Transaction'),
      findsOneWidget,
    );
    expect(
      tester.getTopLeft(find.byType(BurnEcxCard)).dy,
      greaterThan(tester.getBottomLeft(find.byType(ClaimEcxCard)).dy),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the Receive tab changes burn access with the network', (tester) async {
    final conf = _FakeConf();
    await _pumpReceiveTab(tester, conf: conf);
    void expectNoBurnGap() {
      expect(find.byType(BurnEcxCard), findsNothing);
      final actionCards = find.byWidgetPredicate(
        (widget) => widget is SailColumn && widget.children.any((child) => child is ClaimEcxCard),
      );
      expect(tester.getSize(actionCards).height, tester.getSize(find.byType(ClaimEcxCard)).height);
    }

    expectNoBurnGap();

    conf.changeNetwork(BitcoinNetwork.BITCOIN_NETWORK_ECASH, 'alphanet');
    await tester.pump();
    expect(find.byType(BurnEcxCard), findsOneWidget);

    conf.changeNetwork(BitcoinNetwork.BITCOIN_NETWORK_ECASH, 'betanet');
    await tester.pump();
    expectNoBurnGap();

    conf.changeNetwork(BitcoinNetwork.BITCOIN_NETWORK_MAINNET, 'alphanet');
    await tester.pump();
    expectNoBurnGap();
    expect(find.byType(ClaimEcxCard), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the Receive tab uses the catalog Alphanet ID when the explicit ID is empty', (tester) async {
    final conf = _FakeConf()
      ..network = BitcoinNetwork.BITCOIN_NETWORK_ECASH
      ..currentNetworkOptionId = 'alphanet';
    await _pumpReceiveTab(tester, conf: conf);

    expect(find.byType(BurnEcxCard), findsOneWidget);
    expect(tester.takeException(), isNull);
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

  testWidgets('the address type dropdown sits above the address field', (tester) async {
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

    final path = find.descendant(of: _addressCard(), matching: find.text(_derivationPath));
    expect(path, findsOneWidget);
    expect(tester.getTopLeft(path).dx, lessThan(tester.getTopLeft(_qr()).dx));
  });

  testWidgets('the derivation path drops below the field at the narrow window minimum', (tester) async {
    await _pumpReceiveTab(tester);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.binding.setSurfaceSize(const Size(400, 900));
    await tester.pump();
    await tester.pump();

    final path = find.descendant(of: _addressCard(), matching: find.text(_derivationPath));
    expect(path, findsOneWidget);
    expect(tester.getTopLeft(path).dy, greaterThan(tester.getBottomLeft(_addressField()).dy));
    expect(tester.takeException(), isNull);
    expect(tester.getSize(_addressField()).width, greaterThan(200));
  });
}
