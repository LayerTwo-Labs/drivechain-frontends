import 'package:bitwindow/models/bandwidth_data.dart';
import 'package:bitwindow/widgets/traffic_graph_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'test_utils.dart';

List<BandwidthDataPoint> _history(double rate) => [
  for (var i = 0; i < 6; i++)
    BandwidthDataPoint(
      time: DateTime(2026, 1, 1, 0, 0, i * 5),
      totalRxBytes: 0,
      totalTxBytes: 0,
      rxBytesPerSec: rate,
      txBytesPerSec: rate / 2,
    ),
];

void main() {
  setUp(() async {
    await GetIt.I.reset();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  final cases = {
    0.0: ['0 B/s', '282 B/s', '563 B/s', '845 B/s', '1.1 KB/s'],
    10240.0: ['0 B/s', '2.8 KB/s', '5.5 KB/s', '8.3 KB/s', '11.0 KB/s'],
  };

  cases.forEach((rate, expected) {
    testWidgets('puts one axis label on each grid line at a peak of $rate B/s', (tester) async {
      await tester.pumpSailPage(
        SizedBox(
          width: 560,
          child: TrafficGraphContent(bandwidthHistory: _history(rate), currentRxRate: rate, currentTxRate: rate / 2),
        ),
      );
      await tester.pumpAndSettle();

      final labels = find
          .descendant(of: find.byType(LineChart), matching: find.textContaining('/s'))
          .evaluate()
          .map((e) => (e.widget as Text).data)
          .toList();

      expect(labels.toSet(), expected.toSet());
      expect(labels, hasLength(expected.length));
    });
  });
}
