import 'package:bitwindow/dialogs/network_statistics_dialog.dart';
import 'package:bitwindow/models/bandwidth_data.dart';
import 'package:bitwindow/providers/network_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

class _Network extends ChangeNotifier implements NetworkProvider {
  @override
  GetNetworkStatsResponse? stats = GetNetworkStatsResponse();

  @override
  List<BandwidthDataPoint> bandwidthHistory = [
    for (var i = 0; i < 3; i++)
      BandwidthDataPoint(
        time: DateTime(2026, 11, 18, 12).add(Duration(seconds: 5 * i)),
        totalRxBytes: 100.0 * i,
        totalTxBytes: 50.0 * i,
      ),
  ];

  @override
  String? error;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() => GetIt.I.registerSingleton<NetworkProvider>(_Network()));
  tearDown(() {
    SailStyleValues.phoneLayoutOverride = null;
    return GetIt.I.reset();
  });

  double fontSize(WidgetTester tester, String text) => tester.widget<Text>(find.text(text)).style!.fontSize!;

  testWidgets('on a phone the bandwidth graph title is 15 like the other section titles', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await tester.pumpSailPage(const NetworkStatisticsPage());

    expect(tester.takeException(), isNull);
    expect(fontSize(tester, 'Bandwidth Graph'), 15);
    expect(fontSize(tester, 'Blockchain'), 15);
  });

  testWidgets('on desktop the section titles stay 20', (tester) async {
    await tester.pumpSailPage(const NetworkStatisticsPage());

    expect(fontSize(tester, 'Bandwidth Graph'), 20);
    expect(fontSize(tester, 'Blockchain'), 20);
  });
}
