import 'package:bitwindow/utils/fee_estimation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('btcPerKvbToSatPerVByte', () {
    test('converts BTC/kvB to sat/vB', () {
      // 0.00001 BTC/kvB = 1000 sat/kvB = 1 sat/vB
      expect(btcPerKvbToSatPerVByte(0.00001), closeTo(1.0, 1e-9));
      // 0.0001 BTC/kvB = 10 sat/vB
      expect(btcPerKvbToSatPerVByte(0.0001), closeTo(10.0, 1e-9));
    });
  });

  group('estimateTxVBytes', () {
    test('base + inputs + outputs', () {
      expect(estimateTxVBytes(numInputs: 1, numOutputs: 2), 10 + 148 + 68);
      expect(estimateTxVBytes(numInputs: 2, numOutputs: 2), 10 + 296 + 68);
    });
  });

  group('feeSatsForRate', () {
    test('rounds up', () {
      expect(feeSatsForRate(satPerVByte: 1.0, txVBytes: 226), 226);
      expect(feeSatsForRate(satPerVByte: 1.5, txVBytes: 226), 339);
      // ceil applies on any fractional sat
      expect(feeSatsForRate(satPerVByte: 2.5, txVBytes: 101), 253);
      expect(feeSatsForRate(satPerVByte: 0.25, txVBytes: 226), 57);
    });
  });

  test('feeRateConfTargets is ascending', () {
    for (var i = 1; i < feeRateConfTargets.length; i++) {
      expect(feeRateConfTargets[i] > feeRateConfTargets[i - 1], isTrue);
    }
  });
}
