import 'package:bitwindow/pages/wallet/wallet_send.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('estimateFeeTarget', () {
    test('keeps the target when the node gives a rate', () async {
      final estimate = await estimateFeeTarget(
        3,
        (target) async => target == 3 ? 12.5 : null,
      );

      expect(estimate.confTarget, 3);
      expect(estimate.satPerVByte, 12.5);
      expect(estimate.error, isNull);
    });

    test('falls back to a typed fee when the node has no rate', () async {
      final estimate = await estimateFeeTarget(1, (_) async => null);

      expect(estimate.confTarget, isNull);
      expect(estimate.satPerVByte, isNull);
      expect(estimate.error, isNull);
    });

    test('falls back to a typed fee when the estimate fails', () async {
      final estimate = await estimateFeeTarget(
        1,
        (_) async => throw Exception('node not ready'),
      );

      expect(estimate.confTarget, isNull);
      expect(estimate.satPerVByte, isNull);
      expect(
        estimate.error,
        'Could not estimate the fee for next block: Exception: node not ready',
      );
    });
  });
}
