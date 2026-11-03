import 'package:bitwindow/utils/ripemd160.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

String _hash(String ascii) => hex.encode(ripemd160(ascii.codeUnits));

void main() {
  group('RIPEMD-160 vectors from the authors', () {
    test('short messages', () {
      expect(_hash(''), '9c1185a5c5e9fc54612808977ee8f548b2258d31');
      expect(_hash('a'), '0bdc9d2d256b3ee9daae347be6f4dc835a467ffe');
      expect(_hash('abc'), '8eb208f7e05d987a9b044a8e98c6b087f15a0bfc');
      expect(_hash('message digest'), '5d0689ef49d2fae572b881b123a85ffa21595f36');
      expect(_hash('abcdefghijklmnopqrstuvwxyz'), 'f71c27109c692c1b56bbdceb5b9d2865b3708dbc');
    });

    test('messages that cross a block', () {
      expect(
        _hash('abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq'),
        '12a053384a9c0c88e405a06c27dcf49ada62eb2b',
      );
      expect(
        _hash('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'),
        'b0e20b6e3116640286ed3a87a5713079b21f5189',
      );
      expect(_hash('1234567890' * 8), '9b752e45573d4b39f4dbd3323cab82bf63326bfb');
    });

    test('one million a', () {
      expect(_hash('a' * 1000000), '52783243c1697bdbe16d37f97f68f08325dc1528');
    });
  });

  test('HASH160 of the compressed generator point', () {
    final pubkey = hex.decode('0279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798');
    expect(hex.encode(ripemd160(sha256.convert(pubkey).bytes)), '751e76e8199196d454941c45d1b3a323f1433bd6');
  });
}
