import 'dart:io';

import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:bitwindow/widgets/multisig_key_modal.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

const _mnemonic = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

class _FakeConf extends ChangeNotifier implements BitcoinConfProvider {
  _FakeConf(this.usesMainnetParams);

  @override
  final bool usesMainnetParams;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

String _xpubFor(String path) => 'xpub-for-$path';

class _FakeWallet implements OrchestratorWalletRPC {
  @override
  Future<wmpb.DeriveKeystoreResponse> deriveKeystore({
    String? mnemonic,
    String? passphrase,
    wmpb.HardwareDeviceSelector? device,
    String? rawKey,
    String scriptType = '',
    bool multisig = false,
    int account = 0,
    String derivationPath = '',
  }) async => wmpb.DeriveKeystoreResponse(
    xpub: _xpubFor(derivationPath),
    fingerprint: '73c5da0a',
    originPath: derivationPath.substring(2),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeOrchestrator implements OrchestratorRPC {
  @override
  final OrchestratorWalletRPC wallet = _FakeWallet();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FixedIndexHDWallet extends HDWalletProvider {
  @override
  Future<int> getNextAccountIndex([Set<int>? additionalUsedIndices]) async => 8000;
}

Future<MultisigKeyModalViewModel> _generateKey({required bool mainnet}) async {
  GetIt.I.registerSingleton<BitcoinConfProvider>(_FakeConf(mainnet));
  final hd = _FixedIndexHDWallet();
  GetIt.I.registerSingleton<HDWalletProvider>(hd);

  final reader = GetIt.I.get<WalletReaderProvider>();
  reader.wallets = [
    WalletData(
      version: 1,
      master: MasterWallet(mnemonic: '', seedHex: '', masterKey: '', chainCode: ''),
      l1: L1Wallet(mnemonic: _mnemonic),
      sidechains: const [],
      id: 'enf',
      name: 'Enforcer',
      gradient: WalletGradient.fromWalletId('enf'),
      createdAt: DateTime.utc(2026, 1, 1),
      walletType: BinaryType.BINARY_TYPE_ENFORCER,
    ),
  ];
  reader.activeWalletId = 'enf';
  reader.notifyListeners();
  for (int i = 0; i < 20 && !hd.isInitialized; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(hd.isInitialized, isTrue);

  final model = MultisigKeyModalViewModel();
  await model.init();
  expect(model.modalError, isNull);
  return model;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.warning));
    GetIt.I.registerSingleton<WalletReaderProvider>(WalletReaderProvider(Directory.systemTemp));
    GetIt.I.registerSingleton<WalletWriterProvider>(WalletWriterProvider(bitwindowAppDir: Directory.systemTemp));
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator());
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('multisig key on mainnet params uses coin type 0 and shows the orchestrator xpub', () async {
    final model = await _generateKey(mainnet: true);

    expect(model.keyInfo!['path'], "m/84'/0'/8000'");
    expect(model.keyInfo!['originPath'], "84'/0'/8000'");
    expect(model.keyInfo!['xpub'], _xpubFor("m/84'/0'/8000'"));
  });

  test('multisig key on test networks uses coin type 1 and shows the orchestrator xpub', () async {
    final model = await _generateKey(mainnet: false);

    expect(model.keyInfo!['path'], "m/84'/1'/8000'");
    expect(model.keyInfo!['xpub'], _xpubFor("m/84'/1'/8000'"));
  });
}
