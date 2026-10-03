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
      expect(formatBurnAmount(125000000000, 'bECX'), '1,250.00000000 bECX');
      expect(formatBurnAmount(125000000452, 'bECX'), '1,250.00000452 bECX');
      expect(formatBurnAmount(9007199254740993, 'bECX'), '90,071,992.54740993 bECX');
    });

    test('rounds one hundredth up to a whole ECX satoshi', () {
      expect(formatEcxCredit(10000000000, 100), '1.00000000 ECX');
      expect(formatEcxCredit(125000000000, 100), '12.50000000 ECX');
      expect(formatEcxCredit(125000000001, 100), '12.50000001 ECX');
      expect(formatEcxCredit(0, 100), '0.00000000 ECX');
      expect(formatEcxCredit(1, 100), '0.00000001 ECX');
      expect(formatEcxCredit(10, 100), '0.00000001 ECX');
      expect(formatEcxCredit(99, 100), '0.00000001 ECX');
      expect(formatEcxCredit(100, 100), '0.00000001 ECX');
      expect(formatEcxCredit(101, 100), '0.00000002 ECX');
      expect(formatEcxCredit(9007199254740993, 100), '900,719.92547410 ECX');
      expect(formatEcxCredit(9223372036854775807, 100), '922,337,203.68547759 ECX');
    });

    test('keeps exact credit boundaries without integer overflow', () {
      expect(calculateEcxCreditSats(0, 100), 0);
      expect(calculateEcxCreditSats(1, 100), 1);
      expect(calculateEcxCreditSats(99, 100), 1);
      expect(calculateEcxCreditSats(100, 100), 1);
      expect(calculateEcxCreditSats(101, 100), 2);
      expect(calculateEcxCreditSats(100000000000, 100), 1000000000);
      expect(calculateEcxCreditSats(100000000001, 100), 1000000001);
      expect(calculateEcxCreditSats(100000000099, 100), 1000000001);
      expect(calculateEcxCreditSats(100000000100, 100), 1000000001);
      expect(calculateEcxCreditSats(100000000101, 100), 1000000002);
      expect(calculateEcxCreditSats(9223372036854775800, 100), 92233720368547758);
      expect(calculateEcxCreditSats(9223372036854775807, 100), 92233720368547759);
    });

    test('rounds one fiftieth up to a whole ECX satoshi', () {
      expect(burnEcxNetworks['alphanet'], (name: 'Alphanet', creditDivisor: 100));
      expect(burnEcxNetworks['betanet'], (name: 'Betanet', creditDivisor: 50));
      expect(formatEcxCredit(100000000000, 100), '10.00000000 ECX');
      expect(formatEcxCredit(100000000000, 50), '20.00000000 ECX');
      expect(formatEcxCredit(125000000000, 50, compact: true), '25 ECX');
      expect(calculateEcxCreditSats(0, 50), 0);
      expect(calculateEcxCreditSats(1, 50), 1);
      expect(calculateEcxCreditSats(49, 50), 1);
      expect(calculateEcxCreditSats(50, 50), 1);
      expect(calculateEcxCreditSats(51, 50), 2);
      expect(calculateEcxCreditSats(100000000001, 50), 2000000001);
      expect(calculateEcxCreditSats(9223372036854775800, 50), 184467440737095516);
      expect(calculateEcxCreditSats(9223372036854775807, 50), 184467440737095517);
    });

    test('omits only trailing zero decimals for the route', () {
      expect(formatBurnAmount(125000000000, 'bECX', compact: true), '1,250 bECX');
      expect(formatBurnAmount(125000000001, 'bECX', compact: true), '1,250.00000001 bECX');
      expect(formatEcxCredit(125000000000, 100, compact: true), '12.5 ECX');
      expect(formatEcxCredit(125000000001, 100, compact: true), '12.50000001 ECX');
    });
  });
}
