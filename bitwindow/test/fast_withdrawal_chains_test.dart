import 'package:bitwindow/providers/fast_withdrawal_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FastWithdrawalProvider.supportedLayer2Chains', () {
    test('still includes the historical Thunder + BitNames pair', () {
      expect(FastWithdrawalProvider.supportedLayer2Chains, contains('Thunder'));
      expect(FastWithdrawalProvider.supportedLayer2Chains, contains('BitNames'));
    });

    test('exposes the other sidechains the FW server accepts', () {
      expect(FastWithdrawalProvider.supportedLayer2Chains, contains('BitAssets'));
      expect(FastWithdrawalProvider.supportedLayer2Chains, contains('ZSide'));
      expect(FastWithdrawalProvider.supportedLayer2Chains, contains('Photon'));
      expect(FastWithdrawalProvider.supportedLayer2Chains, contains('Truthcoin'));
      expect(FastWithdrawalProvider.supportedLayer2Chains, contains('CoinShift'));
    });

    test('contains no duplicates', () {
      final list = FastWithdrawalProvider.supportedLayer2Chains;
      expect(list.toSet().length, list.length);
    });
  });
}
