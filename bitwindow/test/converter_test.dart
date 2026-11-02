import 'dart:convert';

import 'package:bip39_mnemonic/bip39_mnemonic.dart';
import 'package:bitwindow/utils/converter.dart';
import 'package:convert/convert.dart' as conv;
import 'package:dart_bip32_bip44/dart_bip32_bip44.dart' show Chain, ExtendedPrivateKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/api_mock.dart';

String _row(ConverterResult result, String label) {
  final all = [...result.encodings, ...result.hashes, ...result.keys];
  return all.firstWhere((r) => r.label == label, orElse: () => const ConverterRow('', '')).value;
}

class _Utils extends MockUtilsAPI {
  final calls = <(String, ConvertFormat)>[];
  ConvertResponse response = ConvertResponse();
  Object? failure;

  @override
  Future<ConvertResponse> convert(String input, ConvertFormat format) async {
    calls.add((input, format));
    if (failure != null) {
      throw failure!;
    }
    return response;
  }
}

class _Bitwindow extends MockAPI {
  _Bitwindow(this._utils) : super(binaryType: BinaryType.BINARY_TYPE_BITWINDOWD);

  final _Utils _utils;

  @override
  _Utils get utils => _utils;
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

  group('convert', () {
    late _Utils utils;

    setUp(() async {
      await GetIt.I.reset();
      utils = _Utils();
      GetIt.I.registerSingleton<BitwindowRPC>(_Bitwindow(utils));
    });

    tearDown(() async {
      await GetIt.I.reset();
    });

    test('sends the input and format, and shows the rows bitwindowd gives', () async {
      utils.response = ConvertResponse(
        detected: ConvertFormat.CONVERT_FORMAT_WIF,
        encodings: [ConvertRow(label: 'Hex', value: 'aa')],
        hashes: [ConvertRow(label: 'SHA-256', value: 'bb')],
        keys: [ConvertRow(label: 'P2WPKH address', value: 'bc1q')],
      );

      final result = await convert(' KwDi ', ConverterFormat.auto);

      expect(utils.calls, [(' KwDi ', ConvertFormat.CONVERT_FORMAT_AUTO)]);
      expect(result.detected, ConverterFormat.wif);
      expect(result.error, isNull);
      expect(_row(result, 'Hex'), 'aa');
      expect(_row(result, 'SHA-256'), 'bb');
      expect(_row(result, 'P2WPKH address'), 'bc1q');
    });

    test('maps every format to its proto value', () async {
      for (final format in ConverterFormat.values) {
        await convert('x', format);
      }
      expect(utils.calls.map((c) => c.$2.name), [
        'CONVERT_FORMAT_AUTO',
        'CONVERT_FORMAT_HEX',
        'CONVERT_FORMAT_BASE64',
        'CONVERT_FORMAT_BASE58',
        'CONVERT_FORMAT_BASE58CHECK',
        'CONVERT_FORMAT_BECH32',
        'CONVERT_FORMAT_ASCII',
        'CONVERT_FORMAT_WIF',
        'CONVERT_FORMAT_PASSPHRASE',
      ]);
    });

    test('shows the reason bitwindowd could not read the input', () async {
      utils.response = ConvertResponse(
        detected: ConvertFormat.CONVERT_FORMAT_HEX,
        error: 'Could not read input as Hex: not valid hex',
      );

      final result = await convert('abc', ConverterFormat.hex);

      expect(result.error, 'Could not read input as Hex: not valid hex');
      expect(result.isEmpty, isTrue);
    });

    test('a failed call is an error, not an empty result', () async {
      utils.failure = UtilsException('bitwindowd is not running');

      final result = await convert('abc', ConverterFormat.hex);

      expect(result.error, contains('bitwindowd is not running'));
      expect(result.keys, isEmpty);
    });

    test('an empty input asks bitwindowd for nothing', () async {
      final result = await convert('   ', ConverterFormat.auto);

      expect(utils.calls, isEmpty);
      expect(result.isEmpty, isTrue);
    });
  });

  group('HD explorer addresses', () {
    const mnemonic = 'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about';
    final chain = Chain.seed(conv.hex.encode(Mnemonic.fromSentence(mnemonic, Language.english).seed));

    List<int> pubKeyAt(String path) => (chain.forPath(path) as ExtendedPrivateKey).publicKey().q!.getEncoded(true);

    test('the address type follows the path purpose', () {
      const vectors = {
        "m/44'/0'/0'/0/0": '1LqBGSKuX5yYUonjxT5qGfpUsXKYYWeabA',
        "m/49'/0'/0'/0/0": '37VucYSaXLCAsxYyAPfbSi9eh4iEcbShgf',
        "m/84'/0'/0'/0/0": 'bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu',
        "m/86'/0'/0'/0/0": 'bc1p5cyxnuxmeuwuvkwfem96lqzszd02n6xdcjrs20cac6yqjjwudpxqkedrcr',
      };
      vectors.forEach((path, want) {
        expect(addressForPurpose(pubKeyAt(path), purposeOf(path), mainnet), want, reason: path);
      });
    });

    test('eCash gets the mainnet segwit address', () {
      const path = "m/84'/0'/0'/0/0";
      expect(
        addressForPurpose(pubKeyAt(path), purposeOf(path), BitcoinNetwork.BITCOIN_NETWORK_ECASH),
        'bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu',
      );
    });

    test('a test network gets a tb1 address', () {
      const path = "m/84'/1'/0'/0/0";
      expect(addressForPurpose(pubKeyAt(path), purposeOf(path), signet).startsWith('tb1q'), isTrue);
    });

    test('the WIF follows the network', () {
      final secret = (chain.forPath("m/84'/0'/0'/0/0") as ExtendedPrivateKey).key!.toRadixString(16).padLeft(64, '0');
      expect(compressedWif(conv.hex.decode(secret), mainnet), 'KyZpNDKnfs94vbrwhJneDi77V6jF64PWPF8x5cdJb8ifgg2DUc9d');
    });

    test('purposeOf reads the purpose level', () {
      expect(purposeOf("m/84'/0'/0'/0"), 84);
      expect(purposeOf('m/44h/1h/0h/0'), 44);
      expect(purposeOf('m'), 0);
    });
  });
}
