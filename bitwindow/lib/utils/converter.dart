import 'dart:convert';
import 'dart:typed_data';

import 'package:bitwindow/utils/base58.dart';
import 'package:bitcoin_base/bitcoin_base.dart' as bb;
import 'package:blockchain_utils/blockchain_utils.dart' as bu;
import 'package:convert/convert.dart' as conv;
import 'package:crypto/crypto.dart';
import 'package:pointycastle/digests/ripemd160.dart';
import 'package:sail_ui/sail_ui.dart';

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

Uint8List sha256Bytes(List<int> data) => Uint8List.fromList(sha256.convert(data).bytes);

Uint8List doubleSha256(List<int> data) => sha256Bytes(sha256Bytes(data));

Uint8List ripemd160Bytes(List<int> data) {
  final digest = RIPEMD160Digest();
  final out = Uint8List(digest.digestSize);
  digest.update(Uint8List.fromList(data), 0, data.length);
  digest.doFinal(out, 0);
  return out;
}

Uint8List hash160(List<int> data) => ripemd160Bytes(sha256Bytes(data));

String _hex(List<int> bytes) => conv.hex.encode(bytes);

bool _looksHex(String s) => s.isNotEmpty && s.length.isEven && RegExp(r'^[0-9a-fA-F]+$').hasMatch(s);

bool _looksBech32(String s) => RegExp(r'^(bc|tb|bcrt)1[02-9ac-hj-np-z]{6,}$').hasMatch(s.toLowerCase());

ConverterFormat _detect(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) {
    return ConverterFormat.ascii;
  }
  if (_looksBech32(trimmed)) {
    return ConverterFormat.bech32;
  }
  if (Base58Check.decode(trimmed)?.checksumValid ?? false) {
    final decoded = Base58Check.decode(trimmed)!;
    if (decoded.payload.length == 32 || decoded.payload.length == 33) {
      return ConverterFormat.wif;
    }
    return ConverterFormat.base58check;
  }
  if (_looksHex(trimmed)) {
    return ConverterFormat.hex;
  }
  return ConverterFormat.ascii;
}

/// Decodes the input to raw bytes under [format], or throws with a reason.
Uint8List _toBytes(String input, ConverterFormat format) {
  final trimmed = input.trim();
  switch (format) {
    case ConverterFormat.hex:
      if (!_looksHex(trimmed)) {
        throw const FormatException('not valid hex');
      }
      return Uint8List.fromList(conv.hex.decode(trimmed));
    case ConverterFormat.base64:
      return Uint8List.fromList(base64.decode(trimmed));
    case ConverterFormat.base58:
      final decoded = bu.Base58Decoder.decode(trimmed);
      return Uint8List.fromList(decoded);
    case ConverterFormat.base58check:
      final decoded = Base58Check.decode(trimmed);
      if (decoded == null) {
        throw const FormatException('not valid Base58Check');
      }
      return Uint8List.fromList(decoded.payload);
    case ConverterFormat.wif:
      // A bad checksum here would present a mistyped key as spendable.
      final wif = Base58Check.decode(trimmed);
      if (wif == null) {
        throw const FormatException('not valid Base58Check');
      }
      if (!wif.checksumValid) {
        throw const FormatException('WIF checksum does not match');
      }
      return Uint8List.fromList(wif.payload);
    case ConverterFormat.bech32:
      // HRP-agnostic, so bcrt1 decodes as readily as bc1 and tb1, and the
      // witness version picks bech32 vs bech32m.
      return Uint8List.fromList(bu.SegwitBech32Decoder.decode(null, trimmed.toLowerCase()).$2);
    case ConverterFormat.passphrase:
      return sha256Bytes(utf8.encode(input));
    case ConverterFormat.ascii:
    case ConverterFormat.auto:
      return Uint8List.fromList(utf8.encode(input));
  }
}

/// Converts one input into every representation the tool knows.
ConverterResult convert(String input, ConverterFormat format, BitcoinNetwork network) {
  if (input.trim().isEmpty) {
    return const ConverterResult(detected: ConverterFormat.ascii);
  }

  final detected = format == ConverterFormat.auto ? _detect(input) : format;

  Uint8List bytes;
  try {
    bytes = _toBytes(input, detected);
  } catch (e) {
    return ConverterResult(detected: detected, error: 'Could not read input as ${detected.label}: $e');
  }

  return ConverterResult(
    detected: detected,
    encodings: _encodings(input, bytes, detected),
    hashes: _hashes(bytes),
    keys: _keys(bytes, detected, network),
  );
}

List<ConverterRow> _encodings(String input, Uint8List bytes, ConverterFormat detected) {
  final rows = <ConverterRow>[
    ConverterRow('Hex', _hex(bytes)),
    ConverterRow('Base64', base64.encode(bytes)),
    ConverterRow('Base58', bu.Base58Encoder.encode(bytes)),
    ConverterRow('Byte length', '${bytes.length}'),
  ];

  final asciiPrintable = bytes.every((b) => b >= 0x20 && b < 0x7F);
  if (asciiPrintable) {
    rows.add(ConverterRow('ASCII', utf8.decode(bytes)));
  }

  final decoded = Base58Check.decode(input.trim());
  if (decoded != null) {
    rows.add(ConverterRow('Base58Check version', decoded.versionHex));
    rows.add(ConverterRow('Base58Check valid', decoded.checksumValid ? 'yes' : 'no'));
  }
  return rows;
}

List<ConverterRow> _hashes(Uint8List bytes) => [
  ConverterRow('SHA-256', _hex(sha256Bytes(bytes))),
  ConverterRow('SHA-256d', _hex(doubleSha256(bytes))),
  ConverterRow('RIPEMD-160', _hex(ripemd160Bytes(bytes))),
  ConverterRow('HASH160', _hex(hash160(bytes))),
];

/// Key material only makes sense for a 32-byte secret, so anything else
/// reports the address forms of the bytes as a public key hash instead.
List<ConverterRow> _keys(Uint8List bytes, ConverterFormat detected, BitcoinNetwork network) {
  final prefixes = _prefixesFor(network);
  final rows = <ConverterRow>[];

  final isSecret = bytes.length == 32 || (bytes.length == 33 && detected == ConverterFormat.wif);
  if (!isSecret) {
    return rows;
  }

  final secret = Uint8List.fromList(bytes.sublist(0, 32));
  rows.add(ConverterRow('Private key (hex)', _hex(secret)));
  rows.add(ConverterRow('WIF (compressed)', Base58Check.encode(prefixes.wif, [...secret, 0x01]) ?? ''));
  rows.add(ConverterRow('WIF (uncompressed)', Base58Check.encode(prefixes.wif, secret) ?? ''));

  try {
    final privateKey = bb.ECPrivate.fromBytes(secret);
    final public = privateKey.getPublic();
    final compressedHex = public.toHex();

    rows.add(ConverterRow('Public key (compressed)', compressedHex));
    rows.add(ConverterRow('Public key (uncompressed)', public.toHex(mode: bb.PublicKeyType.uncompressed)));

    final pubKeyHash = conv.hex.decode(public.toHash160Hex());
    rows.add(ConverterRow('HASH160 of pubkey', _hex(pubKeyHash)));
    rows.add(ConverterRow('P2PKH address', Base58Check.encode(prefixes.p2pkh, pubKeyHash) ?? ''));
    rows.add(ConverterRow('P2WPKH address', bu.SegwitBech32Encoder.encode(prefixes.hrp, 0, pubKeyHash)));
    // The taproot output key is the tweaked one, which bitcoin_base derives.
    final taprootProgram = conv.hex.decode(public.toTaprootAddress().addressProgram);
    rows.add(ConverterRow('P2TR address', bu.SegwitBech32Encoder.encode(prefixes.hrp, 1, taprootProgram)));
  } catch (e) {
    rows.add(ConverterRow('Public key', 'not derivable: $e'));
  }

  return rows;
}
