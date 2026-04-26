import 'dart:io';

import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

const _validMnemonic = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

WalletData _enforcer({String l1Mnemonic = ''}) => WalletData(
  version: 1,
  master: MasterWallet(mnemonic: '', seedHex: '', masterKey: '', chainCode: ''),
  l1: L1Wallet(mnemonic: l1Mnemonic),
  sidechains: const [],
  id: 'enf',
  name: 'Enforcer',
  gradient: WalletGradient.fromWalletId('enf'),
  createdAt: DateTime.utc(2026, 1, 1),
  walletType: BinaryType.enforcer,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.warning));
    GetIt.I.registerSingleton<WalletReaderProvider>(
      WalletReaderProvider(Directory.systemTemp),
    );
    GetIt.I.registerSingleton<WalletWriterProvider>(
      WalletWriterProvider(bitwindowAppDir: Directory.systemTemp),
    );
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('HDWalletProvider stays uninitialised until enforcer wallet arrives', () async {
    final reader = GetIt.I.get<WalletReaderProvider>();
    final hd = HDWalletProvider();

    expect(hd.isInitialized, isFalse);
    expect(hd.error, isNull);

    // Enforcer arrives on the stream — fake it by mutating the reader and
    // notifying listeners (mirrors what _onData does in production).
    reader.wallets = [_enforcer(l1Mnemonic: _validMnemonic)];
    reader.activeWalletId = 'enf';
    reader.notifyListeners();

    // Allow the queued _loadMnemonic future to settle.
    for (int i = 0; i < 20 && !hd.isInitialized; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }

    expect(hd.isInitialized, isTrue, reason: 'should auto-load when enforcer arrives');
    expect(hd.error, isNull);
    expect(hd.mnemonic, _validMnemonic);
  });

  test('HDWalletProvider does not init when enforcer wallet absent', () async {
    final reader = GetIt.I.get<WalletReaderProvider>();
    final hd = HDWalletProvider();

    // Only a Bitcoin Core wallet on the stream — no enforcer yet.
    reader.wallets = [
      WalletData(
        version: 1,
        master: MasterWallet(mnemonic: '', seedHex: '', masterKey: '', chainCode: ''),
        l1: L1Wallet(mnemonic: 'core-l1-mnemonic'),
        sidechains: const [],
        id: 'core',
        name: 'Core',
        gradient: WalletGradient.fromWalletId('core'),
        createdAt: DateTime.utc(2026, 1, 1),
        walletType: BinaryType.bitcoinCore,
      ),
    ];
    reader.activeWalletId = 'core';
    reader.notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(hd.isInitialized, isFalse);
    expect(hd.mnemonic, isNull);
  });
}
