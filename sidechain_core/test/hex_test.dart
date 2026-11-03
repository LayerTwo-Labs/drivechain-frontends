import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/utils/hex.dart';

const _vectors = <(List<int>, String)>[
  ([], ''),
  ([0x00], '00'),
  ([0x0f], '0f'),
  ([0xff], 'ff'),
  ([0xde, 0xad, 0xbe, 0xef], 'deadbeef'),
  ([0x01, 0x23, 0x45, 0x67, 0x89, 0xab, 0xcd, 0xef], '0123456789abcdef'),
];

void main() {
  test('encodes and decodes known vectors', () {
    for (final (bytes, hex) in _vectors) {
      expect(hexEncode(bytes), hex);
      expect(hexDecode(hex), bytes);
    }
  });

  test('a round trip of all byte values gives the same bytes', () {
    final bytes = Uint8List.fromList(List.generate(256, (i) => i));
    expect(hexDecode(hexEncode(bytes)), bytes);
  });

  test('decodes upper-case and mixed-case input', () {
    expect(hexDecode('DEADBEEF'), [0xde, 0xad, 0xbe, 0xef]);
    expect(hexDecode('DeAdBeEf'), [0xde, 0xad, 0xbe, 0xef]);
  });

  test('rejects odd length', () {
    for (final s in ['0', 'abc']) {
      expect(() => hexDecode(s), throwsFormatException, reason: s);
    }
  });

  test('rejects a non-hex character', () {
    for (final s in ['0g', 'zz', '0x', ' 0', '@0', '`0', '/0', ':0']) {
      expect(() => hexDecode(s), throwsFormatException, reason: s);
    }
  });
}
