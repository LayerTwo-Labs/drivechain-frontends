import 'package:bitwindow/models/burn_ecx_amount.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseBurnAmount', () {
    test('keeps exact satoshis above the double integer limit', () {
      expect(parseBurnAmount('90,071,992.54740993'), 9007199254740993);
      expect(parseBurnAmount('1,250.00000001'), 125000000001);
      expect(parseBurnAmount('0.00000001'), 1);
      expect(parseBurnAmount(' 1250 '), 125000000000);
      expect(parseBurnAmount('0'), 0);
    });

    test('rejects invalid decimals and amounts outside the integer range', () {
      for (final value in ['', '-1', '+1', '1e3', '1.2.3', '1,25', '0.000000001', '92233720368.54775808']) {
        expect(() => parseBurnAmount(value), throwsFormatException, reason: value);
      }
    });
  });

  group('burn amounts', () {
    test('shows all eight decimal places without a double conversion', () {
      expect(formatBurnAmount(125000000000), '1,250.00000000 ECX');
      expect(formatBurnAmount(125000000452), '1,250.00000452 ECX');
      expect(formatBurnAmount(9007199254740993), '90,071,992.54740993 ECX');
    });

    test('rounds one hundredth up to a whole ECX satoshi', () {
      expect(formatEcxCredit(10000000000), '1.00000000 ECX');
      expect(formatEcxCredit(125000000000), '12.50000000 ECX');
      expect(formatEcxCredit(125000000001), '12.50000001 ECX');
      expect(formatEcxCredit(0), '0.00000000 ECX');
      expect(formatEcxCredit(1), '0.00000001 ECX');
      expect(formatEcxCredit(10), '0.00000001 ECX');
      expect(formatEcxCredit(99), '0.00000001 ECX');
      expect(formatEcxCredit(100), '0.00000001 ECX');
      expect(formatEcxCredit(101), '0.00000002 ECX');
      expect(formatEcxCredit(9007199254740993), '900,719.92547410 ECX');
      expect(formatEcxCredit(9223372036854775807), '922,337,203.68547759 ECX');
    });

    test('keeps exact credit boundaries without integer overflow', () {
      expect(calculateEcxCreditSats(0), 0);
      expect(calculateEcxCreditSats(1), 1);
      expect(calculateEcxCreditSats(99), 1);
      expect(calculateEcxCreditSats(100), 1);
      expect(calculateEcxCreditSats(101), 2);
      expect(calculateEcxCreditSats(100000000000), 1000000000);
      expect(calculateEcxCreditSats(100000000001), 1000000001);
      expect(calculateEcxCreditSats(100000000099), 1000000001);
      expect(calculateEcxCreditSats(100000000100), 1000000001);
      expect(calculateEcxCreditSats(100000000101), 1000000002);
      expect(calculateEcxCreditSats(9223372036854775800), 92233720368547758);
      expect(calculateEcxCreditSats(9223372036854775807), 92233720368547759);
    });

    test('omits only trailing zero decimals for the route', () {
      expect(formatBurnAmount(125000000000, compact: true), '1,250 ECX');
      expect(formatBurnAmount(125000000001, compact: true), '1,250.00000001 ECX');
      expect(formatEcxCredit(125000000000, compact: true), '12.5 ECX');
      expect(formatEcxCredit(125000000001, compact: true), '12.50000001 ECX');
    });
  });
}
