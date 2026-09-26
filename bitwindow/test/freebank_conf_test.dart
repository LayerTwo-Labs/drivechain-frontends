import 'dart:math';

import 'package:bitwindow/utils/freebank_conf.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('readCoinbaseTag', () {
    test('reads the name, and the last line wins as in Core', () {
      expect(readCoinbaseTag('server=1\ncoinbasetag=alice\n'), 'alice');
      expect(readCoinbaseTag('coinbasetag=alice\ncoinbasetag=bob\n'), 'bob');
    });

    test('reads no name from a conf that sets none', () {
      expect(readCoinbaseTag(''), isNull);
      expect(readCoinbaseTag('server=1\n# coinbasetag=old\n'), isNull);
    });
  });

  group('coinbaseTagProblem', () {
    test('takes what freebankd takes', () {
      expect(coinbaseTagProblem('alice'), isNull);
      expect(coinbaseTagProblem('Pool One (EU)'), isNull);
      expect(coinbaseTagProblem('x' * 64), isNull);
    });

    test('refuses what freebankd or the conf file would refuse or bend', () {
      expect(coinbaseTagProblem('  '), isNotNull);
      expect(coinbaseTagProblem('x' * 65), isNotNull);
      expect(coinbaseTagProblem('café'), isNotNull);
      expect(coinbaseTagProblem('a#b'), isNotNull);
      expect(coinbaseTagProblem('"alice"'), isNotNull);
    });
  });

  group('setCoinbaseTag', () {
    test('adds the line to a conf without one, keeping the rest', () {
      expect(setCoinbaseTag('server=1\n', 'alice'), 'server=1\ncoinbasetag=alice\n');
      expect(setCoinbaseTag('', 'alice'), 'coinbasetag=alice\n');
    });

    test('replaces the name in place and drops duplicates', () {
      expect(
        setCoinbaseTag('a=1\ncoinbasetag=old\nb=2\ncoinbasetag=older\n', ' new '),
        'a=1\ncoinbasetag=new\nb=2\n',
      );
    });

    test('keeps a commented-out name as a comment', () {
      expect(setCoinbaseTag('# coinbasetag=x\n', 'y'), '# coinbasetag=x\ncoinbasetag=y\n');
    });
  });

  test('suggests a name freebankd takes, different each time', () {
    final names = {for (var seed = 0; seed < 20; seed++) suggestCoinbaseTag(Random(seed))};
    for (final name in names) {
      expect(name, matches(RegExp(r'^bitwindow-[a-z2-9]{4}$')));
      expect(coinbaseTagProblem(name), isNull);
    }
    expect(names.length, greaterThan(15));
  });
}
