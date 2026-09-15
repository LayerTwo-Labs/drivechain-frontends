import 'dart:async';

import 'package:bitwindow/widgets/burn_ecx_card.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart' as bwpb;
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

import 'test_utils.dart';

const _burnAddress = '1BgGZ9tcN4rm9KBzDn7KprQz87SZ26SAMH';
const _walletAddress = 'bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq';
const _minimumSats = 100000000000;
const _amount = '1,250.00000000';

WalletData _walletData({
  String id = 'wallet-1',
  bool watchOnly = false,
  bool hardware = false,
  bool multisig = false,
  BinaryType? walletType,
}) => WalletData(
  version: 1,
  master: MasterWallet(mnemonic: '', seedHex: '', masterKey: '', chainCode: ''),
  l1: L1Wallet(mnemonic: ''),
  sidechains: [],
  id: id,
  name: id,
  gradient: WalletGradient.fromWalletId(id),
  createdAt: DateTime(2026),
  walletType: walletType ?? BinaryType.BINARY_TYPE_UNSPECIFIED,
  isElectrum: walletType == null,
  isWatchOnly: watchOnly,
  hardwareDeviceType: hardware ? 'test-device' : '',
  multisig: multisig ? wmpb.MultisigInfo() : null,
);

class _FakeWallet extends ChangeNotifier implements WalletReaderProvider {
  @override
  String? activeWalletId = 'wallet-1';

  @override
  List<WalletData> wallets = [_walletData()];

  @override
  WalletData? get activeWallet => wallets.where((wallet) => wallet.id == activeWalletId).firstOrNull;

  @override
  bool get isWalletLocked => wallets.isEmpty;

  void changeWallet({String? id = 'wallet-2', bool locked = false}) {
    activeWalletId = id;
    wallets = locked ? [] : [_walletData(id: id ?? 'wallet-2')];
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeConf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_ECASH;

  @override
  String ecashNetworkId = 'alphanet';

  @override
  String currentNetworkOptionId = 'alphanet';

  @override
  String ecashExplorerHost = 'explorer.alphanet.example';

  void changeNetwork({BitcoinNetwork? value, String id = 'betanet'}) {
    network = value ?? BitcoinNetwork.BITCOIN_NETWORK_ECASH;
    ecashNetworkId = id;
    currentNetworkOptionId = id;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRpc implements OrchestratorWalletRPC {
  final calls = <String>[];
  final walletIds = <String>[];
  final amounts = <Map<String, int>>[];
  final opReturnAddresses = <String?>[];
  final previews = <String>[];
  final signedPreviews = <String>[];
  final finalPreviews = <String>[];
  final sentHex = <String>[];
  final feeOptions = <bool>[];
  final replayOptions = <bool>[];
  final deriveRanges = <(int, int)>[];
  Completer<void>? gate;
  String? holdStage;
  String? failedStage;
  bool hasFee = true;
  String warningMessage = '';
  List<String> addresses = [_walletAddress];

  Future<void> stage(String name) async {
    calls.add(name);
    if (holdStage == name) {
      await gate!.future;
    }
    if (failedStage == name) {
      throw StateError('$name failed');
    }
  }

  @override
  Future<wmpb.DeriveAddressesResponse> deriveAddresses({
    required String walletId,
    required int startIndex,
    required int count,
  }) async {
    walletIds.add(walletId);
    deriveRanges.add((startIndex, count));
    await stage('derive');
    return wmpb.DeriveAddressesResponse(addresses: addresses);
  }

  @override
  Future<String> createPsbt({
    required String walletId,
    required Map<String, int> destinations,
    int? feeRateSatPerVbyte,
    int? fixedFeeSats,
    bool subtractFeeFromAmount = false,
    String? opReturnMessage,
    String? opReturnHex,
    List<bwpb.UnspentOutput>? requiredInputs,
    bool allowReplay = false,
  }) async {
    walletIds.add(walletId);
    amounts.add(destinations);
    opReturnAddresses.add(opReturnMessage);
    feeOptions.add(subtractFeeFromAmount);
    replayOptions.add(allowReplay);
    final psbt = 'preview-${amounts.length}';
    await stage('create');
    return psbt;
  }

  @override
  Future<DecodedTransaction> decodeTransaction({required String input, String walletId = ''}) async {
    walletIds.add(walletId);
    previews.add(input);
    await stage('decode');
    return DecodedTransaction(
      form: wmpb.DecodedForm.DECODED_FORM_PSBT,
      isPsbt: true,
      signedInputs: 0,
      hasFee: hasFee,
      hasTotalInput: true,
      details: bwpb.GetTransactionDetailsResponse(feeSats: Int64(452), warningMessage: warningMessage),
    );
  }

  @override
  Future<String> signPsbt({required String walletId, required String psbtBase64}) async {
    walletIds.add(walletId);
    signedPreviews.add(psbtBase64);
    await stage('sign');
    return 'signed-$psbtBase64';
  }

  @override
  Future<String> finalizePsbt({required String psbtBase64}) async {
    finalPreviews.add(psbtBase64);
    await stage('finalize');
    return 'hex-$psbtBase64';
  }

  @override
  Future<String> broadcastTransaction({required String walletId, required String txHex}) async {
    walletIds.add(walletId);
    sentHex.add(txHex);
    await stage('broadcast');
    return 'a' * 64;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  @override
  final OrchestratorWalletRPC wallet;

  _FakeOrchestrator(this.wallet);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeRpc rpc;
  late _FakeWallet wallet;
  late _FakeConf conf;

  setUp(() async {
    await GetIt.I.reset();
    rpc = _FakeRpc();
    wallet = _FakeWallet();
    conf = _FakeConf();
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator(rpc));
    GetIt.I.registerSingleton<WalletReaderProvider>(wallet);
    GetIt.I.registerSingleton<BitcoinConfProvider>(conf);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Finder burnButton() => find.byWidgetPredicate(
    (widget) => widget is SailButton && widget.label == 'Burn Transaction',
  );

  Future<void> pumpCard(WidgetTester tester, {double width = 420, bool production = false}) async {
    await tester.pumpSailPage(
      SingleChildScrollView(
        child: Center(
          child: SizedBox(
            width: width,
            child: production
                ? const BurnEcxCard()
                : const BurnEcxCard(burnAddress: _burnAddress, minimumSats: _minimumSats),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> enterAmount(WidgetTester tester, [String value = _amount]) async {
    await tester.enterText(find.byType(SailTextField), value);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    await tester.pump();
  }

  Future<void> burn(WidgetTester tester) async {
    await tester.ensureVisible(burnButton());
    await tester.tap(burnButton());
    await tester.pump();
    await tester.pump();
  }

  testWidgets('starts with a disabled burn action', (tester) async {
    await pumpCard(tester);
    final title = find
        .text('Burn Alphanet Coins')
        .evaluate()
        .where((element) => element.findAncestorWidgetOfExactType<SailButton>() == null);
    expect(title, hasLength(1));
    expect(tester.widget<SailButton>(burnButton()).disabled, isTrue);
    expect(find.text('You cannot reverse this burn'), findsOneWidget);
    expect(rpc.calls, isEmpty);
  });

  testWidgets('shows the backend warning before and after the burn', (tester) async {
    rpc.warningMessage =
        'This transaction burns Alphanet coins for a claim of real ECX. You cannot reverse this transaction.';
    await pumpCard(tester, width: 360);
    await enterAmount(tester);
    expect(find.text(rpc.warningMessage), findsOneWidget);
    expect(find.text('You cannot reverse this burn'), findsNothing);
    expect(tester.widget<SailAlert>(find.byType(SailAlert)).variant, SailAlertVariant.warning);
    expect(tester.takeException(), isNull);

    await burn(tester);
    expect(find.text('Burn sent'), findsWidgets);
    expect(find.text(rpc.warningMessage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clears the backend warning when the amount changes', (tester) async {
    rpc.warningMessage = 'Check the transaction outputs.';
    await pumpCard(tester);
    await enterAmount(tester);
    expect(find.text(rpc.warningMessage), findsOneWidget);

    await enterAmount(tester, '');
    expect(find.text(rpc.warningMessage), findsNothing);
    expect(find.byType(SailAlert), findsNothing);
    expect(tester.widget<SailButton>(burnButton()).disabled, isTrue);
  });

  testWidgets('shows no alert when the backend returns no warning', (tester) async {
    await pumpCard(tester);
    await enterAmount(tester);
    expect(find.byType(SailAlert), findsNothing);
    expect(find.text('You cannot reverse this burn'), findsOneWidget);
  });

  for (final network in BitcoinNetwork.values.where((value) => value != BitcoinNetwork.BITCOIN_NETWORK_ECASH)) {
    testWidgets('hides the card on ${network.name}', (tester) async {
      conf.network = network;
      await pumpCard(tester);
      expect(burnButton(), findsNothing);
      expect(rpc.calls, isEmpty);
    });
  }

  testWidgets('hides the card on Betanet with the same ECASH enum', (tester) async {
    conf.ecashNetworkId = 'betanet';
    await pumpCard(tester);
    expect(burnButton(), findsNothing);
  });

  testWidgets('uses the catalog id when the explicit network id is empty', (tester) async {
    conf.ecashNetworkId = '';
    await pumpCard(tester);
    expect(burnButton(), findsOneWidget);
  });

  testWidgets('blocks a locked wallet', (tester) async {
    wallet.wallets = [];
    await pumpCard(tester);
    expect(find.text('Unlock this wallet to burn coins.'), findsOneWidget);
    expect(tester.widget<SailTextField>(find.byType(SailTextField)).enabled, isFalse);
    expect(tester.widget<SailButton>(burnButton()).disabled, isTrue);
    expect(rpc.calls, isEmpty);
  });

  for (final type in ['watchOnly', 'hardware', 'multisig']) {
    testWidgets('blocks a $type wallet', (tester) async {
      wallet.wallets = [
        _walletData(watchOnly: type != 'hardware', hardware: type == 'hardware', multisig: type == 'multisig'),
      ];
      await pumpCard(tester);
      expect(
        find.textContaining(
          type == 'multisig' ? 'Use the CLI to export this multisig burn' : 'This wallet cannot sign this burn.',
        ),
        findsOneWidget,
      );
      expect(tester.widget<SailButton>(burnButton()).disabled, isTrue);
      expect(rpc.calls, isEmpty);
    });
  }

  for (final type in {'Core': BinaryType.BINARY_TYPE_BITCOIND, 'enforcer': BinaryType.BINARY_TYPE_ENFORCER}.entries) {
    testWidgets('blocks the ${type.key} wallet before a burn RPC', (tester) async {
      wallet.wallets = [_walletData(walletType: type.value)];

      await pumpCard(tester);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('This wallet cannot burn coins. Select an Electrum wallet.'), findsOneWidget);
      expect(tester.widget<SailTextField>(find.byType(SailTextField)).enabled, isFalse);
      expect(tester.widget<SailButton>(burnButton()).disabled, isTrue);
      expect(rpc.calls, isEmpty);
    });
  }

  testWidgets('does not use another wallet when the active wallet is absent', (tester) async {
    wallet.activeWalletId = null;
    await pumpCard(tester);
    expect(find.text('Select a wallet to burn coins.'), findsOneWidget);
    expect(tester.widget<SailButton>(burnButton()).disabled, isTrue);
    expect(rpc.calls, isEmpty);
  });

  testWidgets('rejects the minimum and invalid amount text', (tester) async {
    await pumpCard(tester);
    for (final value in ['1000', '999.99999999', '0', '1e10', '1250.000000001', '-1250']) {
      await enterAmount(tester, value);
      expect(tester.widget<SailButton>(burnButton()).disabled, isTrue);
      expect(rpc.calls, isEmpty);
    }
  });

  for (final width in [420.0, 360.0]) {
    testWidgets('shows the exact fee and both full addresses at $width pixels', (tester) async {
      await pumpCard(tester, width: width);
      await enterAmount(tester);
      expect(rpc.deriveRanges, [(0, 1)]);
      expect(rpc.amounts, [
        {_burnAddress: 125000000000},
      ]);
      expect(rpc.opReturnAddresses, [_walletAddress]);
      expect(rpc.feeOptions, [false]);
      expect(rpc.replayOptions, [false]);
      expect(rpc.walletIds, everyElement('wallet-1'));
      expect(find.text(_burnAddress), findsOneWidget);
      expect(find.text(_walletAddress), findsOneWidget);
      expect(find.text('0 ECX'), findsOneWidget);
      expect(find.text('12.5 ECX'), findsOneWidget);
      expect(find.text('Real ECX'), findsOneWidget);
      expect(find.textContaining('1/100 of the amount'), findsNWidgets(2));
      expect(find.textContaining('Betanet'), findsNothing);
      expect(find.text('0.00000452 ECX'), findsOneWidget);
      expect(find.text('1,250.00000452 ECX'), findsOneWidget);
      expect(tester.widget<SailButton>(burnButton()).disabled, isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('rounds the credit up for a burn one satoshi above the minimum', (tester) async {
    await pumpCard(tester);
    await enterAmount(tester, '1000.00000001');
    expect(rpc.amounts.single, {_burnAddress: 100000000001});
    expect(find.text('10.00000001 ECX'), findsOneWidget);
    expect(find.text('The credit rounds up to a whole ECX satoshi.'), findsOneWidget);
    expect(tester.widget<SailButton>(burnButton()).disabled, isFalse);
  });

  testWidgets('uses the production burn address and strict Alphanet minimum', (tester) async {
    await pumpCard(tester, production: true);
    for (final amount in ['999.99999999', '1000']) {
      await enterAmount(tester, amount);
      expect(tester.widget<SailButton>(burnButton()).disabled, isTrue);
      expect(rpc.calls, isEmpty);
    }

    await enterAmount(tester, '1000.00000001');
    expect(rpc.amounts.single, {'1BitcoinEaterAddressDontSendf59kuE': 100000000001});
    expect(rpc.opReturnAddresses.single, _walletAddress);
    expect(find.text('1BitcoinEaterAddressDontSendf59kuE'), findsOneWidget);
    expect(find.text('10.00000001 ECX'), findsOneWidget);
    expect(find.text('0.00000452 ECX'), findsOneWidget);
    expect(find.text('1,000.00000453 ECX'), findsOneWidget);
    expect(tester.widget<SailButton>(burnButton()).disabled, isFalse);
  });

  testWidgets('sends the exact preview and shows credit as pending', (tester) async {
    await pumpCard(tester);
    await enterAmount(tester);
    await burn(tester);
    expect(rpc.calls, ['derive', 'create', 'decode', 'sign', 'finalize', 'broadcast']);
    expect(rpc.signedPreviews, rpc.previews);
    expect(rpc.finalPreviews, ['signed-preview-1']);
    expect(rpc.sentHex, ['hex-signed-preview-1']);
    expect(find.text('Burn sent'), findsNWidgets(2));
    expect(find.text('Credit pending'), findsOneWidget);
    expect(find.text('Your real ECX credit remains pending.'), findsOneWidget);
    expect(find.text('12.5 ECX'), findsOneWidget);
    expect(find.text(_walletAddress), findsOneWidget);
    expect(find.text('a' * 64), findsOneWidget);
    expect(find.text(_burnAddress), findsOneWidget);
    expect(find.text('0 ECX'), findsOneWidget);
    expect(find.text('0.00000452 ECX'), findsOneWidget);
    expect(find.text('1,250.00000452 ECX'), findsOneWidget);
    expect(find.text('View on the explorer'), findsWidgets);
  });

  testWidgets('blocks a preview without an exact fee', (tester) async {
    rpc.hasFee = false;
    await pumpCard(tester);
    await enterAmount(tester);
    expect(find.text('The transaction has no exact network fee.'), findsOneWidget);
    expect(tester.widget<SailButton>(burnButton()).disabled, isTrue);
    expect(rpc.signedPreviews, isEmpty);
  });

  testWidgets('blocks a wallet without its first address', (tester) async {
    rpc.addresses = [];
    await pumpCard(tester);
    await enterAmount(tester);
    expect(find.text('The wallet did not return its first address.'), findsOneWidget);
    expect(rpc.calls, ['derive']);
    expect(tester.widget<SailButton>(burnButton()).disabled, isTrue);
  });

  for (final stage in ['derive', 'create', 'decode', 'sign', 'finalize', 'broadcast']) {
    testWidgets('shows the error when $stage fails', (tester) async {
      rpc.failedStage = stage;
      await pumpCard(tester);
      await enterAmount(tester);
      if (['sign', 'finalize', 'broadcast'].contains(stage)) {
        await burn(tester);
      }
      expect(find.textContaining('$stage failed'), findsOneWidget);
      expect(find.text('Burn sent'), findsNothing);
      expect(rpc.calls.last, stage);
    });

    for (final change in ['wallet', 'network', 'lock']) {
      testWidgets('discards the $stage result after a $change change', (tester) async {
        rpc.holdStage = stage;
        rpc.gate = Completer<void>();
        await pumpCard(tester);
        await enterAmount(tester);
        if (['sign', 'finalize', 'broadcast'].contains(stage)) {
          await burn(tester);
        }
        expect(rpc.calls.last, stage);
        final count = rpc.calls.length;
        if (change == 'network') {
          conf.changeNetwork();
        } else {
          wallet.changeWallet(locked: change == 'lock');
        }
        rpc.gate!.complete();
        await tester.pump();
        await tester.pump();
        expect(rpc.calls.length, count);
        expect(find.text('Burn sent'), findsNothing);
        expect(find.text(_walletAddress), findsNothing);
        if (change != 'network') {
          expect(tester.widget<SailButton>(burnButton()).disabled, isTrue);
        }
      });
    }
  }

  testWidgets('discards an old preview when the amount changes', (tester) async {
    rpc.holdStage = 'create';
    rpc.gate = Completer<void>();
    await pumpCard(tester);
    await enterAmount(tester);
    rpc.holdStage = null;
    await enterAmount(tester, '1500');
    rpc.gate!.complete();
    await tester.pump();
    await tester.pump();
    expect(rpc.previews, ['preview-2']);
    expect(find.text('15 ECX'), findsOneWidget);
    await burn(tester);
    expect(rpc.signedPreviews, ['preview-2']);
  });

  testWidgets('keeps the amount fixed and prevents duplicate sends during a burn', (tester) async {
    rpc.holdStage = 'sign';
    rpc.gate = Completer<void>();
    await pumpCard(tester);
    await enterAmount(tester);
    await burn(tester);
    expect(tester.widget<SailTextField>(find.byType(SailTextField)).enabled, isFalse);
    expect(tester.widget<SailButton>(burnButton()).loading, isTrue);
    await tester.widget<SailButton>(burnButton()).onPressed!();
    expect(rpc.signedPreviews, hasLength(1));
    rpc.gate!.complete();
    await tester.pump();
    await tester.pump();
    expect(rpc.sentHex, hasLength(1));
  });

  for (final result in ['true', 'false', 'error']) {
    testWidgets('shows the explorer result when the launcher returns $result', (tester) async {
      const channel = MethodChannel('plugins.flutter.io/url_launcher');
      String? url;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
        url = (call.arguments as Map)['url'] as String;
        if (result == 'error') {
          throw PlatformException(code: 'test-error', message: 'The browser did not start.');
        }
        return result == 'true';
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(channel, null));
      await pumpCard(tester);
      await enterAmount(tester);
      await burn(tester);
      final link = find.byWidgetPredicate((widget) => widget is SailButton && widget.label == 'View on the explorer');
      await tester.ensureVisible(link);
      await tester.tap(link);
      await tester.pump();
      expect(url, 'https://explorer.alphanet.example/tx/${'a' * 64}');
      expect(find.text('Credit pending'), findsOneWidget);
      if (result == 'error') {
        expect(find.textContaining('The browser did not start.'), findsOneWidget);
      } else {
        expect(find.text('The explorer did not open.'), result == 'false' ? findsOneWidget : findsNothing);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
