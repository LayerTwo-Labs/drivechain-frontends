import 'dart:convert';

import 'package:bitwindow/utils/converter.dart';
import 'package:convert/convert.dart' as conv;
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

String _row(ConverterResult result, String label) {
  final all = [...result.encodings, ...result.hashes, ...result.keys];
  return all.firstWhere((r) => r.label == label, orElse: () => const ConverterRow('', '')).value;
}

void main() {
  const mainnet = BitcoinNetwork.BITCOIN_NETWORK_MAINNET;
  const signet = BitcoinNetwork.BITCOIN_NETWORK_SIGNET;

  group('hashes', () {
    test('sha256 of the empty string', () {
      expect(
        conv.hex.encode(sha256Bytes(const [])),
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
      );
    });

    test('sha256 of abc', () {
      expect(
        conv.hex.encode(sha256Bytes(utf8.encode('abc'))),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
    });

    test('ripemd160 of abc', () {
      expect(conv.hex.encode(ripemd160Bytes(utf8.encode('abc'))), '8eb208f7e05d987a9b044a8e98c6b087f15a0bfc');
    });

    test('hash160 is ripemd160 over sha256', () {
      final direct = ripemd160Bytes(sha256Bytes(utf8.encode('abc')));
      expect(conv.hex.encode(hash160(utf8.encode('abc'))), conv.hex.encode(direct));
    });
  });

  group('encodings', () {
    test('hex input round-trips through every encoding', () {
      final result = convert('deadbeef', ConverterFormat.hex, mainnet);
      expect(result.error, isNull);
      expect(_row(result, 'Hex'), 'deadbeef');
      expect(_row(result, 'Base64'), base64.encode([0xde, 0xad, 0xbe, 0xef]));
      expect(_row(result, 'Byte length'), '4');
    });

    test('odd-length hex is rejected with a reason, not a crash', () {
      final result = convert('abc', ConverterFormat.hex, mainnet);
      expect(result.error, isNotNull);
      expect(result.isEmpty, isTrue);
    });

    test('an empty input produces nothing at all', () {
      expect(convert('   ', ConverterFormat.auto, mainnet).isEmpty, isTrue);
    });
  });

  group('keys and addresses', () {
    // Private key 0x01…01, the standard test vector.
    const secretHex = '0000000000000000000000000000000000000000000000000000000000000001';

    test('derives the well-known pubkey for privkey 1', () {
      final result = convert(secretHex, ConverterFormat.hex, mainnet);
      expect(
        _row(result, 'Public key (compressed)'),
        '0279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798',
      );
      expect(_row(result, 'Public key (uncompressed)').startsWith('04'), isTrue);
    });

    test('address prefixes follow the network', () {
      final main = convert(secretHex, ConverterFormat.hex, mainnet);
      expect(_row(main, 'P2PKH address').startsWith('1'), isTrue);
      expect(_row(main, 'P2WPKH address').startsWith('bc1q'), isTrue);
      expect(_row(main, 'P2TR address').startsWith('bc1p'), isTrue);
      expect(_row(main, 'WIF (compressed)').startsWith('K') || _row(main, 'WIF (compressed)').startsWith('L'), isTrue);

      final test = convert(secretHex, ConverterFormat.hex, signet);
      expect(_row(test, 'P2WPKH address').startsWith('tb1q'), isTrue);
      expect(_row(test, 'P2TR address').startsWith('tb1p'), isTrue);
      expect(_row(test, 'WIF (compressed)').startsWith('c'), isTrue);
    });

    test('a WIF round-trips back to its private key', () {
      final fromHex = convert(secretHex, ConverterFormat.hex, mainnet);
      final wif = _row(fromHex, 'WIF (compressed)');

      final fromWif = convert(wif, ConverterFormat.auto, mainnet);
      expect(fromWif.detected, ConverterFormat.wif);
      expect(_row(fromWif, 'Private key (hex)'), secretHex);
    });

    test('a mistyped WIF is rejected, not shown as key material', () {
      final fromHex = convert(secretHex, ConverterFormat.hex, mainnet);
      final wif = _row(fromHex, 'WIF (compressed)');
      final mistyped = wif.substring(0, wif.length - 1) + (wif.endsWith('a') ? 'b' : 'a');

      final result = convert(mistyped, ConverterFormat.wif, mainnet);
      expect(result.error, isNotNull);
      expect(result.keys, isEmpty);
    });

    test('non-secret-length input reports no key material', () {
      expect(convert('deadbeef', ConverterFormat.hex, mainnet).keys, isEmpty);
    });
  });

  group('detection', () {
    test('a bech32 address is detected and decodes to its program', () {
      final secret = convert(
        '0000000000000000000000000000000000000000000000000000000000000001',
        ConverterFormat.hex,
        mainnet,
      );
      final address = _row(secret, 'P2WPKH address');
      final expected = _row(secret, 'HASH160 of pubkey');

      final result = convert(address, ConverterFormat.auto, mainnet);
      expect(result.detected, ConverterFormat.bech32);
      expect(_row(result, 'Hex'), expected);
    });

    test('a base58check address is detected and its version surfaces', () {
      final secret = convert(
        '0000000000000000000000000000000000000000000000000000000000000001',
        ConverterFormat.hex,
        mainnet,
      );
      final result = convert(_row(secret, 'P2PKH address'), ConverterFormat.auto, mainnet);
      expect(result.detected, ConverterFormat.base58check);
      expect(_row(result, 'Base58Check valid'), 'yes');
      expect(_row(result, 'Base58Check version'), '0x00');
    });
  });

  // Regtest has its own HRP, and bitcoin_base has no regtest network — the
  // addresses are encoded from the prefix table, so this is the guard.
  test('regtest addresses use the bcrt prefix and round-trip', () {
    const regtest = BitcoinNetwork.BITCOIN_NETWORK_REGTEST;
    const secretHex = '0000000000000000000000000000000000000000000000000000000000000001';

    final result = convert(secretHex, ConverterFormat.hex, regtest);
    final segwit = _row(result, 'P2WPKH address');
    final taproot = _row(result, 'P2TR address');

    expect(segwit.startsWith('bcrt1q'), isTrue, reason: 'got $segwit');
    expect(taproot.startsWith('bcrt1p'), isTrue, reason: 'got $taproot');

    final decoded = convert(segwit, ConverterFormat.auto, regtest);
    expect(decoded.detected, ConverterFormat.bech32);
    expect(_row(decoded, 'Hex'), _row(result, 'HASH160 of pubkey'));
  });

  // The brainwallet mode exists to inspect keys that are already compromised;
  // it must derive exactly sha256(passphrase).
  test('brainwallet derives sha256 of the passphrase', () {
    final result = convert('satoshi', ConverterFormat.passphrase, mainnet);
    expect(_row(result, 'Private key (hex)'), conv.hex.encode(sha256Bytes(utf8.encode('satoshi'))));
    expect(_row(result, 'P2PKH address').startsWith('1'), isTrue);
  });
}
