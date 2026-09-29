import 'package:flutter_test/flutter_test.dart';
import 'package:truthcoin/deeplink/truthcoin_link.dart';

void main() {
  group('parseTruthcoinLink', () {
    test('reads a market link', () {
      final link = parseTruthcoinLink(Uri.parse('truthcoin://market/c8fa97101f0c'));

      expect(link, const MarketLink('c8fa97101f0c'));
    });

    test('reads a market link that carries a slash after the host', () {
      final link = parseTruthcoinLink(Uri.parse('truthcoin:///market/494d3fd0489e'));

      expect(link, const MarketLink('494d3fd0489e'));
    });

    test('reads the market list', () {
      expect(parseTruthcoinLink(Uri.parse('truthcoin://markets')), const MarketListLink());
      expect(parseTruthcoinLink(Uri.parse('truthcoin://markets/')), const MarketListLink());
    });

    test('takes the scheme in any case', () {
      expect(parseTruthcoinLink(Uri.parse('TRUTHCOIN://Market/ABCD')), const MarketLink('ABCD'));
    });

    test('drops another scheme', () {
      expect(parseTruthcoinLink(Uri.parse('https://example.com/market/abcd')), isNull);
      expect(parseTruthcoinLink(Uri.parse('bitcoin://market/abcd')), isNull);
    });

    test('drops an unknown first segment', () {
      expect(parseTruthcoinLink(Uri.parse('truthcoin://wallet/abcd')), isNull);
      expect(parseTruthcoinLink(Uri.parse('truthcoin://')), isNull);
    });

    test('reads the 0x prefix the schema writes', () {
      expect(
        parseTruthcoinLink(Uri.parse('truthcoin://market/0xc8fa97101f0c')),
        const MarketLink('c8fa97101f0c'),
      );
      expect(
        parseTruthcoinLink(Uri.parse('truthcoin://market/0X494d3fd0489e')),
        const MarketLink('494d3fd0489e'),
      );
    });

    test('drops a market id that is not hex', () {
      expect(parseTruthcoinLink(Uri.parse('truthcoin://market/../../etc')), isNull);
      expect(parseTruthcoinLink(Uri.parse('truthcoin://market/hello-world')), isNull);
      expect(parseTruthcoinLink(Uri.parse('truthcoin://market/ab')), isNull);
      expect(parseTruthcoinLink(Uri.parse('truthcoin://market/${'a' * 65}')), isNull);
    });

    test('drops a market link that names more than one segment', () {
      expect(parseTruthcoinLink(Uri.parse('truthcoin://market/abcd/buy')), isNull);
    });

    test('drops an empty market id', () {
      expect(parseTruthcoinLink(Uri.parse('truthcoin://market/')), isNull);
      expect(parseTruthcoinLink(Uri.parse('truthcoin://market')), isNull);
    });
  });

  group('MarketLink', () {
    test('two links with the same id are equal', () {
      expect(const MarketLink('abcd'), const MarketLink('abcd'));
      expect(const MarketLink('abcd').hashCode, const MarketLink('abcd').hashCode);
      expect(const MarketLink('abcd') == const MarketLink('efab'), false);
    });
  });
}
