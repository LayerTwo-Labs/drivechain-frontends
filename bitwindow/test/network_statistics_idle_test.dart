import 'package:bitwindow/dialogs/network_statistics_dialog.dart';
import 'package:bitwindow/models/bandwidth_data.dart';
import 'package:bitwindow/providers/network_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/gen/bitwindowd/v1/bitwindowd.pb.dart';

import 'test_utils.dart';

class _IdleNetwork extends ChangeNotifier implements NetworkProvider {
  _IdleNetwork(this.bandwidthHistory);

  @override
  GetNetworkStatsResponse? stats = GetNetworkStatsResponse();

  @override
  List<BandwidthDataPoint> bandwidthHistory;

  @override
  String? error;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  tearDown(() => GetIt.I.reset());

  testWidgets('a node with no traffic draws a flat bandwidth graph', (tester) async {
    final start = DateTime(2026, 11, 18, 12);
    GetIt.I.registerSingleton<NetworkProvider>(
      _IdleNetwork([
        for (var i = 0; i < 3; i++)
          BandwidthDataPoint(time: start.add(Duration(seconds: 5 * i)), totalRxBytes: 100, totalTxBytes: 100),
      ]),
    );

    await tester.pumpSailPage(const NetworkStatisticsPage());

    expect(tester.takeException(), isNull);
    expect(find.text('Bandwidth Graph'), findsOneWidget);
  });
}
