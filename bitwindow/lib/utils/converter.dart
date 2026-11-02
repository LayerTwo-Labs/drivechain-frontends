import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/utils/v1/utils.pb.dart' as utilspb;

/// How the input text should be read. [auto] guesses from the text itself.
enum ConverterFormat { auto, hex, base64, base58, base58check, bech32, ascii, wif, passphrase }

extension ConverterFormatLabel on ConverterFormat {
  String get label => switch (this) {
    ConverterFormat.auto => 'Auto-detect',
    ConverterFormat.hex => 'Hex',
    ConverterFormat.base64 => 'Base64',
    ConverterFormat.base58 => 'Base58',
    ConverterFormat.base58check => 'Base58Check',
    ConverterFormat.bech32 => 'Bech32 / Bech32m',
    ConverterFormat.ascii => 'ASCII',
    ConverterFormat.wif => 'WIF private key',
    ConverterFormat.passphrase => 'Brainwallet passphrase',
  };
}

/// One labelled output row.
class ConverterRow {
  final String label;
  final String value;
  const ConverterRow(this.label, this.value);
}

/// Everything the converter can say about one input.
class ConverterResult {
  final ConverterFormat detected;
  final String? error;
  final List<ConverterRow> encodings;
  final List<ConverterRow> hashes;
  final List<ConverterRow> keys;

  const ConverterResult({
    required this.detected,
    this.error,
    this.encodings = const [],
    this.hashes = const [],
    this.keys = const [],
  });

  bool get isEmpty => encodings.isEmpty && hashes.isEmpty && keys.isEmpty;
}

const _toProto = {
  ConverterFormat.auto: utilspb.ConvertFormat.CONVERT_FORMAT_AUTO,
  ConverterFormat.hex: utilspb.ConvertFormat.CONVERT_FORMAT_HEX,
  ConverterFormat.base64: utilspb.ConvertFormat.CONVERT_FORMAT_BASE64,
  ConverterFormat.base58: utilspb.ConvertFormat.CONVERT_FORMAT_BASE58,
  ConverterFormat.base58check: utilspb.ConvertFormat.CONVERT_FORMAT_BASE58CHECK,
  ConverterFormat.bech32: utilspb.ConvertFormat.CONVERT_FORMAT_BECH32,
  ConverterFormat.ascii: utilspb.ConvertFormat.CONVERT_FORMAT_ASCII,
  ConverterFormat.wif: utilspb.ConvertFormat.CONVERT_FORMAT_WIF,
  ConverterFormat.passphrase: utilspb.ConvertFormat.CONVERT_FORMAT_PASSPHRASE,
};

List<ConverterRow> _rows(List<utilspb.ConvertRow> rows) => [for (final r in rows) ConverterRow(r.label, r.value)];

/// Converts one input into every representation bitwindowd knows, on the network of the node.
Future<ConverterResult> convert(String input, ConverterFormat format) async {
  if (input.trim().isEmpty) {
    return const ConverterResult(detected: ConverterFormat.ascii);
  }

  try {
    final response = await GetIt.I.get<BitwindowRPC>().utils.convert(input, _toProto[format]!);
    final detected = _toProto.entries.firstWhere((e) => e.value == response.detected).key;
    return ConverterResult(
      detected: detected,
      error: response.error.isEmpty ? null : response.error,
      encodings: _rows(response.encodings),
      hashes: _rows(response.hashes),
      keys: _rows(response.keys),
    );
  } catch (e) {
    return ConverterResult(detected: format, error: e.toString());
  }
}
