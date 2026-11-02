import 'dart:typed_data';

import 'package:bitwindow/utils/base58.dart';
import 'package:bitwindow/utils/ripemd160.dart';
import 'package:bitcoin_base/bitcoin_base.dart' as bb;
import 'package:blockchain_utils/blockchain_utils.dart' as bu;
import 'package:convert/convert.dart' as conv;
import 'package:crypto/crypto.dart';
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

/// Bitcoin version bytes and HRP for a network's addresses.
class _NetworkPrefixes {
  final int p2pkh;
  final int p2sh;
  final int wif;
  final String hrp;
  const _NetworkPrefixes(this.p2pkh, this.p2sh, this.wif, this.hrp);
}

_NetworkPrefixes _prefixesFor(BitcoinNetwork network) {
  return switch (network) {
    // eCash runs on mainnet params.
    BitcoinNetwork.BITCOIN_NETWORK_MAINNET ||
    BitcoinNetwork.BITCOIN_NETWORK_ECASH => const _NetworkPrefixes(0x00, 0x05, 0x80, 'bc'),
    BitcoinNetwork.BITCOIN_NETWORK_REGTEST => const _NetworkPrefixes(0x6F, 0xC4, 0xEF, 'bcrt'),
    _ => const _NetworkPrefixes(0x6F, 0xC4, 0xEF, 'tb'),
  };
}

/// The purpose level of a BIP32 path such as m/84'/0'/0'/0, or 0 when the
/// path has none.
int purposeOf(String path) {
  final levels = path.trim().split('/');
  if (levels.length < 2) {
    return 0;
  }
  return int.tryParse(levels[1].replaceAll(RegExp(r"['hH]$"), '')) ?? 0;
}

/// The address that a BIP32 purpose (44, 49, 84 or 86) uses for a compressed
/// public key. Any other purpose gets P2PKH.
String addressForPurpose(List<int> compressedPubKey, int purpose, BitcoinNetwork network) {
  final prefixes = _prefixesFor(network);
  final pubKeyHash = hash160(compressedPubKey);
  return switch (purpose) {
    49 => _base58Check(prefixes.p2sh, hash160([0x00, 0x14, ...pubKeyHash])),
    84 => bu.SegwitBech32Encoder.encode(prefixes.hrp, 0, pubKeyHash),
    86 => bu.SegwitBech32Encoder.encode(
      prefixes.hrp,
      1,
      conv.hex.decode(bb.ECPublic.fromBytes(compressedPubKey).toTaprootAddress().addressProgram),
    ),
    _ => _base58Check(prefixes.p2pkh, pubKeyHash),
  };
}

/// The compressed-key WIF of a 32-byte secret on the network.
String compressedWif(List<int> secret, BitcoinNetwork network) =>
    _base58Check(_prefixesFor(network).wif, [...secret, 0x01]);

String _base58Check(int version, List<int> payload) {
  final encoded = Base58Check.encode(version, payload);
  if (encoded == null) {
    throw const FormatException('Base58Check encoding failed');
  }
  return encoded;
}

Uint8List sha256Bytes(List<int> data) => Uint8List.fromList(sha256.convert(data).bytes);

Uint8List doubleSha256(List<int> data) => sha256Bytes(sha256Bytes(data));

Uint8List ripemd160Bytes(List<int> data) => ripemd160(data);

Uint8List hash160(List<int> data) => ripemd160Bytes(sha256Bytes(data));

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
