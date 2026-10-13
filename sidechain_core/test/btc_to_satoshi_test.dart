import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/bitcoin.dart';

void main() {
  group('btcToSatoshi', () {
    final cases = <(double, int)>[
      (0.29, 29000000),
      (0.57, 57000000),
      (0.1 + 0.2, 30000000),
      (21e6, 2100000000000000),
      (0.00000001, 1),
      (0.00001, 1000),
    ];
    for (final (btc, sats) in cases) {
      test('$btc BTC is $sats sats', () {
        expect(btcToSatoshi(btc), sats);
      });
    }
  });

  group('parseAmountToSatoshis in BTC', () {
    final cases = <(String, int)>[
      ('0.29', 29000000),
      ('0.57', 57000000),
      ('0.3', 30000000),
      ('21000000', 2100000000000000),
      ('21000000.00000000', 2100000000000000),
      ('0.00000001', 1),
      ('.5', 50000000),
      ('1.', 100000000),
      ('1,000.5', 100050000000),
      ('', 0),
      ('.', 0),
      ('abc', 0),
      ('-1', 0),
      ('0.123456789', 0),
    ];
    for (final (input, sats) in cases) {
      test('"$input" is $sats sats', () {
        expect(parseAmountToSatoshis(input, BitcoinUnit.btc), sats);
      });
    }
  });
}
