import 'dart:io';

import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:convert/convert.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

class _Vector {
  final String mnemonic;
  final String seedHex;
  final String masterKey;

  const _Vector(this.mnemonic, this.seedHex, this.masterKey);
}

const _abandonAbout = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';

const _vectors = <_Vector>[
  _Vector(
    _abandonAbout,
    '5eb00bbddcf069084889a8ab9155568165f5c453ccb85e70811aaed6f6da5fc1'
        '9a5ac40b389cd370d086206dec8aa6c43daea6690f20ad3d8d48b2d2ce9e38e4',
    '1837c1be8e2995ec11cda2b066151be2cfb48adf9e47b151d46adab3a21cdf67',
  ),
  _Vector(
    'legal winner thank year wave sausage worth useful legal winner thank yellow',
    '878386efb78845b3355bd15ea4d39ef97d179cb712b77d5c12b6be415fffeffe'
        '5f377ba02bf3f8544ab800b955e51fbff09828f682052a20faa6addbbddfb096',
    '7e56ecf5943d79e1f5f87e11c768253d7f3fcf30ae71335611e366c578b4564e',
  ),
  _Vector(
    'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon '
        'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon art',
    '408b285c123836004f4b8842c89324c1f01382450c0d439af345ba7fc49acf70'
        '5489c6fc77dbd4e3dc1dd8cc6bc9f043db8ada1e243c4a0eafb290d399480840',
    '235b34cd7c9f6d7e4595ffe9ae4b1cb5606df8aca2b527d20a07c8f56b2342f4',
  ),
  _Vector(
    'zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo zoo vote',
    'e28a37058c7f5112ec9e16a3437cf363a2572d70b6ceb3b6965447623d620f14'
        'd06bb321a26b33ec15fcd84a3b5ddfd5520e230c924c87aaa0d559749e044fef',
    '8472fc35dbe9f8ccf7ed306295e84902c0e606e576e5cb3f6c32d98537a21282',
  ),
];

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

  group('bip39_mnemonic package', () {
    for (final v in _vectors) {
      test('seed matches BIP39 vector for "${v.mnemonic.split(' ').take(2).join(' ')}..."', () {
        final mnemonic = Mnemonic.fromSentence(v.mnemonic, Language.english);
        expect(hex.encode(mnemonic.seed), v.seedHex);
      });
    }

    test('passphrase changes the seed', () {
      final bare = Mnemonic.fromSentence(_abandonAbout, Language.english);
      final withPass = Mnemonic.fromSentence(_abandonAbout, Language.english, passphrase: 'TREZOR');
      expect(hex.encode(bare.seed), _vectors.first.seedHex);
      expect(
        hex.encode(withPass.seed),
        'c55257c360c07c72029aebc1b53c05ed0362ada38ead3e3e9efa3708e5349553'
        '1f09a6987599d18264c1e1c92f2cf141630c7a3c4ab7c81b2f001698e7463b04',
      );
    });

    test('rejects a bad checksum', () {
      final bad = _abandonAbout.replaceFirst(RegExp(r'about$'), 'abandon');
      expect(() => Mnemonic.fromSentence(bad, Language.english), throwsA(isA<MnemonicException>()));
    });

    test('rejects a word outside the wordlist', () {
      final bad = _abandonAbout.replaceFirst(RegExp(r'about$'), 'notaword');
      expect(() => Mnemonic.fromSentence(bad, Language.english), throwsA(isA<MnemonicException>()));
    });

    test('generate produces a distinct, valid 12 word sentence', () {
      final a = Mnemonic.generate(Language.english, length: MnemonicLength.words12);
      final b = Mnemonic.generate(Language.english, length: MnemonicLength.words12);

      expect(a.words, hasLength(12));
      expect(a.entropy, hasLength(16));
      expect(a.sentence, isNot(b.sentence));
      expect(hex.encode(Mnemonic.fromSentence(a.sentence, Language.english).seed), hex.encode(a.seed));
    });
  });

  group('HDWalletProvider derivation', () {
    setUp(() async {
      await GetIt.I.reset();
      GetIt.I.registerSingleton<Logger>(Logger(level: Level.warning));
      GetIt.I.registerSingleton<WalletReaderProvider>(WalletReaderProvider(Directory.systemTemp));
      GetIt.I.registerSingleton<WalletWriterProvider>(
        WalletWriterProvider(bitwindowAppDir: Directory.systemTemp),
      );
    });

    tearDown(() async {
      await GetIt.I.reset();
    });

    for (final v in _vectors) {
      test('derives pinned seed and master key for "${v.mnemonic.split(' ').take(2).join(' ')}..."', () async {
        final reader = GetIt.I.get<WalletReaderProvider>();
        final hd = HDWalletProvider();

        reader.wallets = [_enforcer(v.mnemonic)];
        reader.activeWalletId = 'enf';
        reader.notifyListeners();

        for (int i = 0; i < 50 && !hd.isInitialized; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }

        expect(hd.isInitialized, isTrue, reason: hd.error ?? 'provider never initialised');
        expect(hd.seedHex, v.seedHex);
        // dart_bip32_bip44 keeps BIP32's 0x00 private-key prefix.
        expect(hd.masterKey, '00${v.masterKey}');
      });
    }
  });
}
