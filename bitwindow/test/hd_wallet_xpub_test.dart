import 'dart:io';

import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

const _mnemonic = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

class _Call {
  _Call(this.mnemonic, this.scriptType, this.multisig, this.derivationPath);

  final String? mnemonic;
  final String scriptType;
  final bool multisig;
  final String derivationPath;
}

class _FakeWallet implements OrchestratorWalletRPC {
  final calls = <_Call>[];

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
  }) async {
    calls.add(_Call(mnemonic, scriptType, multisig, derivationPath));
    return wmpb.DeriveKeystoreResponse(
      xpub: 'tpubDC8msFGeGuwnKG9Upg7DM2b4DaRqg3CUZa5g8v2SRQ6K4NSkxUgd7HsL2XVWbVm39yBA4LAxysQAm397zwQSQoQgewGiYZqrA9DsP4zbQ1M',
      fingerprint: '73c5da0a',
      originPath: derivationPath.substring(2),
    );
  }

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

WalletData _enforcer(String l1Mnemonic) => WalletData(
  version: 1,
  master: MasterWallet(mnemonic: '', seedHex: '', masterKey: '', chainCode: ''),
  l1: L1Wallet(mnemonic: l1Mnemonic),
  sidechains: const [],
  id: 'enf',
  name: 'Enforcer',
  gradient: WalletGradient.fromWalletId('enf'),
  createdAt: DateTime.utc(2026, 1, 1),
  walletType: BinaryType.BINARY_TYPE_ENFORCER,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeWallet wallet;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.warning));
    GetIt.I.registerSingleton<WalletReaderProvider>(
      WalletReaderProvider(Directory.systemTemp),
    );
    GetIt.I.registerSingleton<WalletWriterProvider>(
      WalletWriterProvider(bitwindowAppDir: Directory.systemTemp),
    );
    wallet = _FakeWallet();
    GetIt.I.registerSingleton<OrchestratorRPC>(_FakeOrchestrator(wallet));
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Future<HDWalletProvider> loaded() async {
    final reader = GetIt.I.get<WalletReaderProvider>();
    final hd = HDWalletProvider();
    reader.wallets = [_enforcer(_mnemonic)];
    reader.activeWalletId = 'enf';
    reader.notifyListeners();
    for (var i = 0; i < 20 && !hd.isInitialized; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(hd.isInitialized, isTrue);
    return hd;
  }

  test(
    'asks the orchestrator for the account xpub at the BIP84 path',
    () async {
      final hd = await loaded();

      final info = await hd.generateWalletXpub(3);

      final call = wallet.calls.single;
      expect(call.mnemonic, _mnemonic);
      expect(call.scriptType, 'wsh');
      expect(call.multisig, isTrue);
      expect(call.derivationPath, "m/84'/1'/3'");
      expect(info['xpub'], startsWith('tpub'));
      expect(info['fingerprint'], '73c5da0a');
      expect(info['derivation_path'], "m/84'/1'/3'");
      expect(info['xpub_with_origin'], "[73c5da0a/84'/1'/3']${info['xpub']}");
    },
  );

  test('uses coin 0 on mainnet params', () async {
    final hd = await loaded();

    await hd.generateWalletXpub(0, true);

    expect(wallet.calls.single.derivationPath, "m/84'/0'/0'");
  });

  test('passes a cosigner path to the orchestrator as it is', () async {
    final hd = await loaded();

    final derived = await hd.deriveAccountXpub("m/48'/1'/0'/2'");

    expect(wallet.calls.single.derivationPath, "m/48'/1'/0'/2'");
    expect(wallet.calls.single.multisig, isTrue);
    expect(derived.fingerprint, '73c5da0a');
  });

  test('throws and makes no call without a loaded seed', () async {
    final hd = HDWalletProvider();

    await expectLater(hd.generateWalletXpub(0), throwsStateError);
    expect(() => hd.deriveAccountXpub("m/84'/1'/0'"), throwsStateError);
    expect(wallet.calls, isEmpty);
  });
}
