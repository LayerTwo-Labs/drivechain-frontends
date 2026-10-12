import 'dart:io';

import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

const _mnemonic = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HDWalletProvider hd;

  setUp(() async {
    await GetIt.I.reset();
    GetIt.I.registerSingleton<Logger>(Logger(level: Level.warning));
    GetIt.I.registerSingleton<WalletReaderProvider>(WalletReaderProvider(Directory.systemTemp));
    hd = HDWalletProvider();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  test('derives mainnet keys with xpub and xprv versions', () async {
    final info = await hd.deriveExtendedKeyInfo(_mnemonic, "m/84'/0'/0'", true);

    expect(
      info['xpub'],
      'xpub6CatWdiZiodmUeTDp8LT5or8nmbKNcuyvz7WyksVFkKB4RHwCD3XyuvPEbvqAQY3rAPshWcMLoP2fMFMKHPJ4ZeZXYVUhLv1VMrjPC7PW6V',
    );
    expect(
      info['xprv'],
      'xprv9ybY78BftS5UGANki6oSifuQEjkpyAC8ZmBvBNTshQnCBcxnefjHS7buPMkkqhcRzmoGZ5bokx7GuyDAiktd5HemohAU4wV1ZPMDRmLpBMm',
    );
    expect(info['address'], '1Q59X2jXqdASameV9tGgGKbCg7Z3UAzUHN');
    expect(info['derivation_path'], "m/84'/0'/0'");
  });

  test('derives test network keys with tpub and tprv versions', () async {
    final info = await hd.deriveExtendedKeyInfo(_mnemonic, "m/84'/1'/0'", false);

    expect(
      info['xpub'],
      'tpubDC8msFGeGuwnKG9Upg7DM2b4DaRqg3CUZa5g8v2SRQ6K4NSkxUgd7HsL2XVWbVm39yBA4LAxysQAm397zwQSQoQgewGiYZqrA9DsP4zbQ1M',
    );
    expect(
      info['xprv'],
      'tprv8fSjiqEQ8YG7Ro7gw2ScwcvweYuuWi1ZzGUtrPz918HvDtBzL5s2voFTrN4y3yUwj5cYD54pLhxk6NKCzHUjcka3zbKjbTEcsuAnkzbjhkL',
    );
    expect(info['address'], 'n2pA3kWU5pXdf4PxCyER7a6sjkz7nHJ8Q3');
  });

  test('derivation errors reach the caller', () async {
    await expectLater(hd.deriveExtendedKeyInfo('not a mnemonic', "m/84'/1'/0'"), throwsA(anything));
    await expectLater(hd.deriveExtendedKeyInfo(_mnemonic, 'not a path'), throwsA(anything));
    await expectLater(hd.generateWalletXpub(8000), throwsA(anything));
  });
}
