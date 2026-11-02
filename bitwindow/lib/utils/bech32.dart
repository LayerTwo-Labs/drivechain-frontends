/// The two checksum variants: BIP173 bech32 and BIP350 bech32m.
enum Bech32Variant { bech32, bech32m }

const _charset = 'qpzry9x8gf2tvdw0s3jn54khce6mua7l';
const _generator = [0x3b6a57b2, 0x26508e6d, 0x1ea119fa, 0x3d4233dd, 0x2a1462b3];
const _maxLength = 90;

int _constant(Bech32Variant variant) => variant == Bech32Variant.bech32 ? 1 : 0x2bc830a3;

int _polymod(List<int> values) {
  var chk = 1;
  for (final value in values) {
    final top = chk >> 25;
    chk = ((chk & 0x1ffffff) << 5) ^ value;
    for (var i = 0; i < 5; i++) {
      if ((top >> i) & 1 == 1) {
        chk ^= _generator[i];
      }
    }
  }
  return chk;
}

List<int> _hrpExpand(String hrp) => [
  for (final c in hrp.codeUnits) c >> 5,
  0,
  for (final c in hrp.codeUnits) c & 31,
];

/// A bech32 string split into its prefix and its 5-bit data words.
class Bech32Decoded {
  final String hrp;
  final List<int> words;
  final Bech32Variant variant;

  const Bech32Decoded(this.hrp, this.words, this.variant);
}

/// Decodes a BIP173 or BIP350 string, or returns null when it is not valid.
Bech32Decoded? decodeBech32(String input) {
  if (input.length > _maxLength) {
    return null;
  }
  final lower = input.toLowerCase();
  if (lower != input && input.toUpperCase() != input) {
    return null;
  }
  if (lower.codeUnits.any((c) => c < 33 || c > 126)) {
    return null;
  }
  final separator = lower.lastIndexOf('1');
  if (separator < 1 || separator + 7 > lower.length) {
    return null;
  }
  final hrp = lower.substring(0, separator);
  final words = <int>[];
  for (final c in lower.substring(separator + 1).split('')) {
    final value = _charset.indexOf(c);
    if (value < 0) {
      return null;
    }
    words.add(value);
  }
  final check = _polymod([..._hrpExpand(hrp), ...words]);
  final variant = switch (check) {
    1 => Bech32Variant.bech32,
    0x2bc830a3 => Bech32Variant.bech32m,
    _ => null,
  };
  if (variant == null) {
    return null;
  }
  return Bech32Decoded(hrp, words.sublist(0, words.length - 6), variant);
}

/// Encodes 5-bit [words] under [hrp] with the checksum of [variant].
String encodeBech32(String hrp, List<int> words, Bech32Variant variant) {
  final values = [..._hrpExpand(hrp), ...words, 0, 0, 0, 0, 0, 0];
  final mod = _polymod(values) ^ _constant(variant);
  final checksum = [for (var i = 0; i < 6; i++) (mod >> (5 * (5 - i))) & 31];
  return '${hrp}1${[...words, ...checksum].map((w) => _charset[w]).join()}';
}

/// Regroups bits, for example 8-bit bytes into 5-bit words. Throws when the
/// input does not regroup without loss.
List<int> convertBits(List<int> data, int from, int to, {required bool pad}) {
  var acc = 0;
  var bits = 0;
  final maxValue = (1 << to) - 1;
  final out = <int>[];
  for (final value in data) {
    if (value < 0 || value >> from != 0) {
      throw FormatException('value $value does not fit in $from bits');
    }
    acc = (acc << from) | value;
    bits += from;
    while (bits >= to) {
      bits -= to;
      out.add((acc >> bits) & maxValue);
    }
  }
  if (pad) {
    if (bits > 0) {
      out.add((acc << (to - bits)) & maxValue);
    }
  } else if (bits >= from || ((acc << (to - bits)) & maxValue) != 0) {
    throw const FormatException('the data has nonzero padding');
  }
  return out;
}

/// The bytes of a bech32 string with prefix [hrp] and checksum [variant].
List<int> bech32ToBytes(String hrp, String input, Bech32Variant variant) {
  final decoded = decodeBech32(input);
  if (decoded == null) {
    throw const FormatException('not a valid bech32 string');
  }
  if (decoded.hrp != hrp) {
    throw FormatException('prefix ${decoded.hrp} is not $hrp');
  }
  if (decoded.variant != variant) {
    throw FormatException('checksum is ${decoded.variant.name}, not ${variant.name}');
  }
  return convertBits(decoded.words, 5, 8, pad: false);
}

/// The bech32 string of [bytes] with prefix [hrp] and checksum [variant].
String bytesToBech32(String hrp, List<int> bytes, Bech32Variant variant) =>
    encodeBech32(hrp, convertBits(bytes, 8, 5, pad: true), variant);
