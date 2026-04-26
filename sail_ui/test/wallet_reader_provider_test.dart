import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

WalletData _wallet({
  required String id,
  required BinaryType type,
  String l1 = '',
  List<SidechainWallet> sidechains = const [],
}) {
  return WalletData(
    version: 1,
    master: MasterWallet(mnemonic: '', seedHex: '', masterKey: '', chainCode: ''),
    l1: L1Wallet(mnemonic: l1),
    sidechains: sidechains,
    id: id,
    name: id,
    gradient: WalletGradient.fromWalletId(id),
    createdAt: DateTime.utc(2026, 1, 1),
    walletType: type,
  );
}

void main() {
  setUpAll(() {
    if (!GetIt.I.isRegistered<Logger>()) {
      GetIt.I.registerSingleton<Logger>(Logger(level: Level.warning));
    }
  });

  test('getL1Mnemonic reads from enforcer wallet, not the active one', () {
    final provider = WalletReaderProvider(Directory.systemTemp);
    provider.wallets = [
      _wallet(id: 'enf', type: BinaryType.enforcer, l1: 'enforcer-l1-mnemonic'),
      _wallet(id: 'core', type: BinaryType.bitcoinCore, l1: 'core-l1-mnemonic'),
    ];
    provider.activeWalletId = 'core';

    expect(provider.activeWallet?.id, 'core');
    expect(provider.enforcerWallet?.id, 'enf');
    expect(provider.getL1Mnemonic(), 'enforcer-l1-mnemonic');
  });

  test('getSidechainMnemonic reads from enforcer wallet, not the active one', () {
    final provider = WalletReaderProvider(Directory.systemTemp);
    provider.wallets = [
      _wallet(
        id: 'enf',
        type: BinaryType.enforcer,
        sidechains: [
          SidechainWallet(slot: 9, name: 'Thunder', mnemonic: 'thunder-starter'),
          SidechainWallet(slot: 5, name: 'BitNames', mnemonic: 'bitnames-starter'),
        ],
      ),
      _wallet(
        id: 'core',
        type: BinaryType.bitcoinCore,
        sidechains: [
          SidechainWallet(slot: 9, name: 'Thunder', mnemonic: 'core-thunder'),
        ],
      ),
    ];
    provider.activeWalletId = 'core';

    expect(provider.getSidechainMnemonic(9), 'thunder-starter');
    expect(provider.getSidechainMnemonic(5), 'bitnames-starter');
    expect(provider.getSidechainMnemonic(99), isNull);
  });

  test('getL1Mnemonic returns null when enforcer wallet absent', () {
    final provider = WalletReaderProvider(Directory.systemTemp);
    provider.wallets = [
      _wallet(id: 'core', type: BinaryType.bitcoinCore, l1: 'core-l1'),
    ];
    provider.activeWalletId = 'core';

    expect(provider.enforcerWallet, isNull);
    expect(provider.getL1Mnemonic(), isNull);
  });
}
