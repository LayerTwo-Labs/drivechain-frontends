import 'dart:math';

import 'package:bitwindow/utils/ed25519_point.dart';
import 'package:blockchain_utils/bip/ecc/keys/ed25519_keys.dart';
import 'package:convert/convert.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts the RFC 8032 test public keys', () {
    for (final key in [
      'd75a980182b10ab7d54bfed3c964073a0ee172f3daa62325af021a68f707511a',
      '3d4017c3e843895a92b70aa74d1b7ebc9c982ccf2ec4968cc0cd55f12af4660c',
      'fc51cd8e6218a1a38da47ed00230f0580816ed13ba3303ac5deb911548908025',
      '278117fc144c72340f67d0f2316e8386ceffbf2b2428c9c51fef7c597f1d426e',
    ]) {
      expect(isEd25519Point(hex.decode(key)), isTrue, reason: key);
    }
  });

  test('accepts the base point and the identity', () {
    expect(isEd25519Point(hex.decode('5866666666666666666666666666666666666666666666666666666666666666')), isTrue);
    expect(isEd25519Point(hex.decode('0100000000000000000000000000000000000000000000000000000000000000')), isTrue);
  });

  test('rejects a value with no square root, a y of p or more, and x = 0 with the sign bit', () {
    expect(isEd25519Point(hex.decode('0200000000000000000000000000000000000000000000000000000000000000')), isFalse);
    expect(isEd25519Point(hex.decode('edffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff7f')), isFalse);
    expect(isEd25519Point(hex.decode('0100000000000000000000000000000000000000000000000000000000000080')), isFalse);
    expect(isEd25519Point(List<int>.filled(31, 0)), isFalse);
  });

  test('gives the same answer as blockchain_utils for random input', () {
    final random = Random(11);
    var valid = 0;
    for (var i = 0; i < 2000; i++) {
      final bytes = List<int>.generate(32, (_) => random.nextInt(256));
      final expected = Ed25519PublicKey.isValidBytes(bytes);
      expect(isEd25519Point(bytes), expected, reason: hex.encode(bytes));
      if (expected) {
        valid++;
      }
    }
    expect(valid, inInclusiveRange(800, 1200));
  });
}
