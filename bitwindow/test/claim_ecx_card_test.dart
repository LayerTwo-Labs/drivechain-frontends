import 'package:bitwindow/widgets/claim_ecx_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/gen/wallet/v1/wallet.pbenum.dart';
import 'package:sail_ui/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

// Private key 0x01, compressed mainnet — the standard WIF test vector.
const _validWif = 'KwDiBf89QgGbjEhKnhXJuH7LrciVrZi3qYjgd9M7rFU73sVHnoWn';
const _walletAddress = 'bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq';

SweepPreview _preview({required int amountSats, int feeSats = 452}) {
  return SweepPreview(
    address: 'bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4',
    addressKind: SweepAddressKind.SWEEP_ADDRESS_KIND_P2WPKH,
    amountSats: amountSats,
    outputCount: 3,
    feeSatPerVbyte: 2,
    feeSats: amountSats == 0 ? 0 : feeSats,
    receiveSats: amountSats == 0 ? 0 : amountSats - feeSats,
  );
}

class _FakeWalletApi implements WalletAPI {
  SweepPreview preview = _preview(amountSats: 0);
  Object? previewError;
  Object? sweepError;
  String? sweptTo;

  @override
  Future<SweepPreview> previewSweep(String privateKeyWif, {int feeSatPerVbyte = 0}) async {
    if (previewError != null) {
      throw previewError!;
    }
    return preview;
  }

  @override
  Future<SweepChequeResult> sweepCheque(
    String walletId,
    String privateKeyWif,
    String destinationAddress,
    int feeSatPerVbyte,
  ) async {
    if (sweepError != null) {
      throw sweepError!;
    }
    sweptTo = destinationAddress;
    return SweepChequeResult(txid: 'a' * 64, amountSats: preview.receiveSats);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeBitwindow implements BitwindowRPC {
  @override
  final WalletAPI wallet;

  _FakeBitwindow(this.wallet);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestratorWallet implements OrchestratorWalletRPC {
  @override
  Future<wmpb.GetNewAddressResponse> getNewAddress(
    String walletId, {
    wmpb.AddressType? addressType,
  }) async {
    return wmpb.GetNewAddressResponse(address: _walletAddress);
  }

  @override
  Future<wmpb.GetTestSidechainsResponse> getTestSidechains() async {
    return wmpb.GetTestSidechainsResponse();
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

class _FakeWalletReader extends ChangeNotifier implements WalletReaderProvider {
  @override
  String? activeWalletId = 'wallet-1';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeConf implements BitcoinConfProvider {
  @override
  BitcoinNetwork get network => BitcoinNetwork.BITCOIN_NETWORK_SIGNET;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  late _FakeWalletApi walletApi;

  setUp(() async {
    await GetIt.I.reset();
    walletApi = _FakeWalletApi();
    GetIt.I.registerSingleton<BitwindowRPC>(_FakeBitwindow(walletApi));
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator());
    GetIt.I.registerSingleton<WalletReaderProvider>(_FakeWalletReader());
    GetIt.I.registerSingleton<BitcoinConfProvider>(_FakeConf());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Future<void> pumpCard(WidgetTester tester) async {
    await tester.pumpSailPage(
      Center(child: SizedBox(width: 480, child: const ClaimEcxCard())),
    );
    await tester.pump();
  }

  // The card checks a key 400ms after the last keystroke.
  Future<void> enterKey(WidgetTester tester, String key) async {
    await tester.enterText(find.byType(SailTextField).first, key);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    await tester.pump();
  }

  group('ClaimEcxCard', () {
    testWidgets('starts with nothing revealed and no claim available', (tester) async {
      await pumpCard(tester);

      expect(find.text('Claim your ECX'), findsOneWidget);
      expect(find.text('The key stays on this computer.'), findsOneWidget);
      expect(find.text('SEND TO'), findsNothing);
      expect(find.text('You receive'), findsNothing);
    });

    testWidgets('rejects a key that is not a private key', (tester) async {
      await pumpCard(tester);
      await enterKey(tester, 'not-a-private-key');

      expect(find.text('Not a private key — check for a missing character.'), findsOneWidget);
      expect(find.text('SEND TO'), findsNothing);
    });

    testWidgets('reports an empty key and offers another check', (tester) async {
      walletApi.preview = _preview(amountSats: 0);
      await pumpCard(tester);
      await enterKey(tester, _validWif);

      expect(find.text('This key is empty — nothing to claim.'), findsOneWidget);
      expect(find.text('Check again'), findsWidgets);
      expect(find.text('SEND TO'), findsNothing);
    });

    testWidgets('reveals the amount and destination once the key has funds', (tester) async {
      walletApi.preview = _preview(amountSats: 125000000000);
      await pumpCard(tester);
      await enterKey(tester, _validWif);

      expect(find.text('This key has funds to claim.'), findsOneWidget);
      expect(find.text('1,250.00000000 ECX'), findsOneWidget);
      expect(find.text('SEND TO'), findsOneWidget);
      expect(find.text('You receive'), findsOneWidget);
      expect(find.text('1,249.99999548 ECX'), findsWidgets);
    });

    testWidgets('claims to the wallet address and shows the transaction', (tester) async {
      walletApi.preview = _preview(amountSats: 125000000000);
      await pumpCard(tester);
      await enterKey(tester, _validWif);

      await tester.tap(find.text('Claim 1,249.99999548 ECX').first);
      await tester.pump();
      await tester.pump();

      expect(walletApi.sweptTo, _walletAddress);
      expect(find.text('ECX claimed'), findsOneWidget);
      expect(find.text('Claim another key'), findsWidgets);
      expect(find.text('View on the explorer'), findsWidgets);
    });

    testWidgets('keeps a failure on screen with its reason', (tester) async {
      walletApi.preview = _preview(amountSats: 125000000000);
      walletApi.sweepError = Exception('fee below the minimum relay fee');
      await pumpCard(tester);
      await enterKey(tester, _validWif);

      await tester.tap(find.text('Claim 1,249.99999548 ECX').first);
      await tester.pump();
      await tester.pump();

      expect(find.text('Claim failed'), findsOneWidget);
      expect(find.textContaining('fee below the minimum relay fee'), findsOneWidget);
      expect(find.text('Try again'), findsWidgets);
      expect(find.text('Use a different key'), findsWidgets);
    });

    testWidgets('claiming another key clears the form', (tester) async {
      walletApi.preview = _preview(amountSats: 125000000000);
      await pumpCard(tester);
      await enterKey(tester, _validWif);

      await tester.tap(find.text('Claim 1,249.99999548 ECX').first);
      await tester.pump();
      await tester.pump();

      await tester.tap(find.text('Claim another key').first);
      await tester.pump();
      await tester.pump();

      expect(find.text('Claim your ECX'), findsOneWidget);
      expect(find.text('The key stays on this computer.'), findsOneWidget);
      expect(find.text('ECX claimed'), findsNothing);
    });
  });

  testWidgets('a new key clears the previous preview at once', (tester) async {
    walletApi.preview = _preview(amountSats: 125000000000);
    await pumpCard(tester);
    await enterKey(tester, _validWif);
    expect(find.text('Claim 1,249.99999548 ECX'), findsWidgets);

    // typed, not yet checked: the old amount must not still be claimable
    await tester.enterText(find.byType(SailTextField).first, '${_validWif}x');
    await tester.pump();

    expect(find.text('Claim 1,249.99999548 ECX'), findsNothing);
    expect(find.text('SEND TO'), findsNothing);
    expect(walletApi.sweptTo, isNull);
  });

  group('formatEcx', () {
    test('groups thousands and always shows eight decimals', () {
      expect(formatEcx(125000000000), '1,250.00000000 ECX');
      expect(formatEcx(124999999548), '1,249.99999548 ECX');
      expect(formatEcx(1), '0.00000001 ECX');
      expect(formatEcx(0), '0.00000000 ECX');
    });
  });

  group('shortenAddress', () {
    test('elides the middle of long values only', () {
      expect(shortenAddress('short'), 'short');
      expect(
        shortenAddress('bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4'),
        'bc1qw508d6qe…7kv8f3t4',
      );
    });
  });
}
