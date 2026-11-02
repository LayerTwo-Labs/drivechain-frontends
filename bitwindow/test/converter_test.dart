import 'package:bitwindow/utils/converter.dart';
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
}
