import 'dart:typed_data';

const _digits = '0123456789abcdef';

/// The lower-case hex string of [bytes].
String hexEncode(List<int> bytes) {
  final out = StringBuffer();
  for (final b in bytes) {
    out
      ..write(_digits[(b >> 4) & 0x0f])
      ..write(_digits[b & 0x0f]);
  }
  return out.toString();
}

/// The bytes of a hex string in upper or lower case. Throws a [FormatException] on odd length or a non-hex character.
Uint8List hexDecode(String hex) {
  if (hex.length.isOdd) {
    throw FormatException('Invalid input length, must be even.', hex, hex.length);
  }
  final out = Uint8List(hex.length ~/ 2);
  for (var i = 0; i < out.length; i++) {
    out[i] = (_digit(hex, i * 2) << 4) | _digit(hex, i * 2 + 1);
  }
  return out;
}

int _digit(String hex, int index) {
  final c = hex.codeUnitAt(index);
  if (c >= 0x30 && c <= 0x39) {
    return c - 0x30;
  }
  final lower = c | 0x20;
  if (lower >= 0x61 && lower <= 0x66) {
    return lower - 0x61 + 10;
  }
  throw FormatException('Invalid hexadecimal character.', hex, index);
}
