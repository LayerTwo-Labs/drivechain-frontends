import 'package:bitwindow/utils/base58.dart';
import 'package:sidechain_core/utils/hex.dart';
import 'package:flutter_test/flutter_test.dart';

// Bitcoin Core src/test/data/base58_encode_decode.json.
const _vectors = <(String, String)>[
  ('', ''),
  ('61', '2g'),
  ('626262', 'a3gV'),
  ('636363', 'aPEr'),
  ('73696d706c792061206c6f6e6720737472696e67', '2cFupjhnEsSn59qHXstmK2ffpLv2'),
  ('00eb15231dfceb60925886b67d065299925915aeb172c06647', '1NS17iag9jJgTHD1VXjvLCEnZuQ3rJDE9L'),
  ('516b6fcd0f', 'ABnLTmg'),
  ('bf4f89001e670274dd', '3SEo3LWLoPntC'),
  ('572e4794', '3EFU7m'),
  ('ecac89cad93923c02321', 'EJDM8drfXA6uyA'),
  ('10c8511e', 'Rt5zm'),
  ('00000000000000000000', '1111111111'),
];

void main() {
  test('encodes and decodes the Bitcoin Core vectors', () {
    for (final (hexValue, encoded) in _vectors) {
      expect(base58Encode(hexDecode(hexValue)), encoded, reason: hexValue);
      expect(hexEncode(base58Decode(encoded)), hexValue, reason: encoded);
    }
  });

  test('a run of 1s decodes to the same number of zero bytes', () {
    expect(base58Decode('1'), [0]);
    expect(base58Decode('11'), [0, 0]);
  });

  test('rejects a character outside the alphabet', () {
    for (final s in ['0', 'O', 'I', 'l', 'abc+']) {
      expect(() => base58Decode(s), throwsArgumentError, reason: s);
    }
  });
}
