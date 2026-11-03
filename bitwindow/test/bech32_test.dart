import 'package:bitwindow/utils/bech32.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BIP173 vectors', () {
    test('valid bech32 strings', () {
      for (final s in [
        'A12UEL5L',
        'a12uel5l',
        'an83characterlonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1tt5tgs',
        'abcdef1qpzry9x8gf2tvdw0s3jn54khce6mua7lmqqqxw',
        'split1checkupstagehandshakeupstreamerranterredcaperred2y9e3w',
        '?1ezyfcl',
      ]) {
        final decoded = decodeBech32(s);
        expect(decoded, isNotNull, reason: s);
        expect(decoded!.variant, Bech32Variant.bech32, reason: s);
        expect(encodeBech32(decoded.hrp, decoded.words, Bech32Variant.bech32), s.toLowerCase(), reason: s);
      }
    });

    test('invalid strings', () {
      for (final s in [
        '1nwldj5',
        'abc1rzg',
        'x1b4n0q5v',
        'li1dgmt3',
        'A1G7SGD8',
        '10a06t8',
        '1qzzfhee',
        'pzry9x0s0muk',
        '1pzry9x0s0muk',
        'an84characterslonghumanreadablepartthatcontainsthenumber1andtheexcludedcharactersbio1569pvx',
        'A12uEL5L',
      ]) {
        expect(decodeBech32(s), isNull, reason: s);
      }
    });
  });

  group('BIP350 vectors', () {
    test('valid bech32m strings', () {
      for (final s in [
        'A1LQFN3A',
        'a1lqfn3a',
        'an83characterlonghumanreadablepartthatcontainsthetheexcludedcharactersbioandnumber11sg7hg6',
        'abcdef1l7aum6echk45nj3s0wdvt2fg8x9yrzpqzd3ryx',
        'split1checkupstagehandshakeupstreamerranterredcaperredlc445v',
        '?1v759aa',
      ]) {
        final decoded = decodeBech32(s);
        expect(decoded, isNotNull, reason: s);
        expect(decoded!.variant, Bech32Variant.bech32m, reason: s);
        expect(encodeBech32(decoded.hrp, decoded.words, Bech32Variant.bech32m), s.toLowerCase(), reason: s);
      }
    });

    test('invalid strings', () {
      for (final s in ['1xj0phk', 'a1fuyfcl', 'M1VUXWEZ', '16plkw9', '1p2gdwpf']) {
        expect(decodeBech32(s), isNull, reason: s);
      }
    });
  });

  group('bytes', () {
    test('a key round-trips and rejects the other variant and prefix', () {
      final bytes = List<int>.generate(32, (i) => i * 7 % 256);
      final key = bytesToBech32('bn-svk', bytes, Bech32Variant.bech32m);

      expect(bech32ToBytes('bn-svk', key, Bech32Variant.bech32m), bytes);
      expect(() => bech32ToBytes('bn-svk', key, Bech32Variant.bech32), throwsFormatException);
      expect(() => bech32ToBytes('bc', key, Bech32Variant.bech32m), throwsFormatException);
      expect(() => bech32ToBytes('bn-svk', '${key}q', Bech32Variant.bech32m), throwsFormatException);
    });

    test('rejects nonzero padding', () {
      final words = [...convertBits(List<int>.filled(32, 0), 8, 5, pad: true)];
      words[words.length - 1] = 1;
      final s = encodeBech32('bn-svk', words, Bech32Variant.bech32m);
      expect(() => bech32ToBytes('bn-svk', s, Bech32Variant.bech32m), throwsFormatException);
    });
  });
}
