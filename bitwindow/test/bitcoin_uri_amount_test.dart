import 'package:bitwindow/pages/wallet/wallet_send.dart';
import 'package:bitwindow/utils/bitcoin_uri.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/bitcoin.dart';

const _address = 'bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq';

void main() {
  group('BitcoinURI amount', () {
    final cases = {
      '0.001': 100000,
      '1': 100000000,
      '0.57': 57000000,
      '0.00000001': 1,
    };
    cases.forEach((text, sats) {
      test('amount=$text gives $sats sats', () {
        final uri = BitcoinURI.parse('bitcoin:$_address?amount=$text');
        expect(uri.amountSats, sats);
      });
    });

    test('no amount gives null', () {
      expect(BitcoinURI.parse('bitcoin:$_address').amountSats, isNull);
    });

    for (final text in ['-1', 'NaN', 'Infinity', '1e5', '0.123456789', '']) {
      test('amount="$text" is refused', () {
        expect(() => BitcoinURI.parse('bitcoin:$_address?amount=$text'), throwsFormatException);
      });
    }
  });

  group('amountTextInUnit', () {
    test('sats unit writes whole sats', () {
      expect(amountTextInUnit(100000, BitcoinUnit.sats), '100000');
    });

    test('btc unit writes 8 decimals', () {
      expect(amountTextInUnit(100000, BitcoinUnit.btc), '0.00100000');
      expect(amountTextInUnit(10, BitcoinUnit.btc), '0.00000010');
    });
  });
}
