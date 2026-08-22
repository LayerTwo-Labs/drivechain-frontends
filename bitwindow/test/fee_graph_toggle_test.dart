import 'package:bitwindow/pages/wallet/widgets/fee_rate_chart.dart';
import 'package:bitwindow/utils/fee_estimation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  group('fee graph', () {
    testWidgets('draws at the compact height', (tester) async {
      final points = [
        FeeRatePoint(confTarget: 1, satPerVByte: 1.2),
        FeeRatePoint(confTarget: 6, satPerVByte: 1.0),
        FeeRatePoint(confTarget: 144, satPerVByte: 0.3),
      ];

      await tester.pumpSailPage(
        Center(
          child: SizedBox(
            width: 900,
            child: FeeRateChart(
              points: points,
              selectedConfTarget: 1,
              onSelected: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(FeeRateChart)).height, feeRateChartHeight);
    });
  });
}
