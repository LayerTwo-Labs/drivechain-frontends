import 'dart:async';
import 'dart:io';

import 'package:bitwindow/pages/wallet/wallet_hd.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

const _mnemonic = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

class _Explore {
  _Explore(this.mnemonic, this.basePath, this.startIndex, this.count);

  final String mnemonic;
  final String basePath;
  final int startIndex;
  final int count;
}

class _FakeWallet implements OrchestratorWalletRPC {
  final explores = <_Explore>[];
  Object? exploreError;
  Completer<void>? gate;

  @override
  Future<wmpb.ExploreSeedResponse> exploreSeed({
    required String mnemonic,
    String passphrase = '',
    required String basePath,
    required int startIndex,
    required int count,
  }) async {
    explores.add(_Explore(mnemonic, basePath, startIndex, count));
    await gate?.future;
    if (exploreError != null) {
      throw exploreError!;
    }
    return wmpb.ExploreSeedResponse(
      seedHex: 'seed',
      xprv: 'xprv-master',
      xpub: 'xpub-master',
      bip47PaymentCode: 'PD1code',
      keys: [
        for (var i = startIndex; i < startIndex + 2; i++)
          wmpb.ExploredKey(path: '$basePath/$i', address: 'addr-$i', publicKey: 'pub-$i', wif: 'wif-$i'),
      ],
    );
  }

  @override
  Future<String> generateMnemonic() async => _mnemonic;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  _FakeOrchestrator(this.wallet);

  @override
  final OrchestratorWalletRPC wallet;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Conf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  bool get usesMainnetParams => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeWallet wallet;

  setUp(() async {
    await GetIt.I.reset();
    wallet = _FakeWallet();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.off));
    GetIt.I.registerSingleton<WalletReaderProvider>(WalletReaderProvider(Directory.systemTemp));
    GetIt.I.registerSingleton<HDWalletProvider>(HDWalletProvider());
    GetIt.I.registerSingleton<BitcoinConfProvider>(_Conf());
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator(wallet));
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('derives the first page of the default path in the orchestrator', () async {
    final model = HDWalletViewModel()..mnemonicController.text = _mnemonic;

    await model.deriveAddresses();

    final call = wallet.explores.single;
    expect(call.mnemonic, _mnemonic);
    expect(call.basePath, "m/84'/0'/0'/0");
    expect(call.startIndex, 0);
    expect(call.count, 10);
    expect(model.errorMessage, isNull);
    expect(model.masterSeed, 'seed');
    expect(model.xpriv, 'xprv-master');
    expect(model.xpub, 'xpub-master');
    expect(model.bip47PaymentCode, 'PD1code');
    expect(model.derivedEntries.map((e) => (e.path, e.address, e.publicKey, e.privateKey)), [
      ("m/84'/0'/0'/0/0", 'addr-0', 'pub-0', 'wif-0'),
      ("m/84'/0'/0'/0/1", 'addr-1', 'pub-1', 'wif-1'),
    ]);
  });

  test('the next page starts ten keys later', () async {
    final model = HDWalletViewModel()..mnemonicController.text = _mnemonic;
    await model.deriveAddresses();

    await model.changePage(true);

    expect(wallet.explores.last.startIndex, 10);
    expect(model.derivedEntries.first.path, "m/84'/0'/0'/0/10");
  });

  test('shows the reason when the orchestrator refuses', () async {
    wallet.exploreError = Exception('invalid mnemonic');
    final model = HDWalletViewModel()..mnemonicController.text = 'abandon abandon';

    await model.deriveAddresses();

    expect(model.errorMessage, contains('invalid mnemonic'));
    expect(model.derivedEntries, isEmpty);
  });

  test('asks for nothing without a mnemonic', () async {
    final model = HDWalletViewModel();

    await model.deriveAddresses();

    expect(wallet.explores, isEmpty);
    expect(model.errorMessage, 'Please enter a mnemonic seed phrase');
  });

  test('a random mnemonic comes from the orchestrator', () async {
    final model = HDWalletViewModel();

    await model.generateRandomMnemonic();

    expect(model.mnemonicController.text, _mnemonic);
  });

  test('Clear drops the keys of a request that is still open', () async {
    wallet.gate = Completer<void>();
    final model = HDWalletViewModel()..mnemonicController.text = _mnemonic;

    final pending = model.deriveAddresses();
    model.clearAll();
    wallet.gate!.complete();
    await pending;

    expect(model.masterSeed, isEmpty);
    expect(model.xpriv, isEmpty);
    expect(model.bip47PaymentCode, isEmpty);
    expect(model.derivedEntries, isEmpty);
  });
}
