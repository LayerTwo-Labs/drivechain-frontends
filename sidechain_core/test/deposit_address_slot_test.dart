import 'package:flutter_test/flutter_test.dart';
import 'package:sidechain_core/bitcoin.dart';

void main() {
  group('depositAddressSlot', () {
    test('reads the slot that the address names', () {
      expect(depositAddressSlot(formatDepositAddress('abc', 8)), 8);
      expect(depositAddressSlot(formatDepositAddress('abc', 9)), 9);
      expect(depositAddressSlot(formatDepositAddress('abc', 255)), 255);
    });

    test('an unformatted address names no slot', () {
      expect(depositAddressSlot('abc'), isNull);
      expect(depositAddressSlot(''), isNull);
    });

    test('a text without the three parts names no slot', () {
      expect(depositAddressSlot('s8_abc'), isNull);
      expect(depositAddressSlot('s8_abc_def_ghi'), isNull);
    });

    test('a slot that is not a number reads as none', () {
      expect(depositAddressSlot('sx_abc_000000'), isNull);
    });

    test('an address that starts with another letter names no slot', () {
      expect(depositAddressSlot('x8_abc_000000'), isNull);
    });
  });
}
