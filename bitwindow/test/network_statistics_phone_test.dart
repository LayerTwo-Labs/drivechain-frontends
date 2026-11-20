import 'package:bitwindow/dialogs/network_statistics_dialog.dart';
import 'package:bitwindow/models/bandwidth_data.dart';
import 'package:bitwindow/providers/network_provider.dart';
import 'package:fl_chart/fl_chart.dart';
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
    await loadBundledFonts();
    await tester.pumpSailPage(const NetworkStatisticsPage());
    await tester.binding.setSurfaceSize(const Size(390, 800));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(fontSize(tester, 'Bandwidth Graph'), 15);
    expect(fontSize(tester, 'Blockchain'), 15);
  });

  testWidgets('on a phone each section is its own panel with 13 px values', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await loadBundledFonts();
    await tester.pumpSailPage(const NetworkStatisticsPage());
    await tester.binding.setSurfaceSize(const Size(390, 800));
    await tester.pump();

    Finder panelOf(String text) => find.ancestor(
      of: find.text(text),
      matching: find.byWidgetPredicate((w) => w is DecoratedBox && w.decoration is BoxDecoration),
    );
    final blockchain = tester.getRect(panelOf('Blockchain').first);
    expect(blockchain.contains(tester.getCenter(find.text('Block Height'))), isTrue);
    expect(blockchain.contains(tester.getCenter(find.text('Total Peers'))), isFalse);
    expect(tester.getRect(panelOf('Bandwidth Graph').first).contains(tester.getCenter(find.text('Received'))), isTrue);
    expect(find.ancestor(of: find.text('Bandwidth Graph'), matching: find.byType(StatSection)), findsOneWidget);

    final value = find.descendant(of: find.byType(StatRow).first, matching: find.byType(Text)).last;
    expect(tester.widget<Text>(value).style!.fontSize, 13);
  });

  testWidgets('on desktop the section titles stay 20', (tester) async {
    await tester.pumpSailPage(const NetworkStatisticsPage());

    expect(fontSize(tester, 'Bandwidth Graph'), 20);
    expect(fontSize(tester, 'Blockchain'), 20);
  });

  testWidgets('on a phone the bandwidth chart has two plain lines, no axis labels and round legend dots', (
    tester,
  ) async {
    SailStyleValues.phoneLayoutOverride = true;
    await loadBundledFonts();
    await tester.pumpSailPage(const NetworkStatisticsPage());
    await tester.binding.setSurfaceSize(const Size(390, 800));
    await tester.pump();

    expect(tester.takeException(), isNull);
    final data = tester.widget<LineChart>(find.byType(LineChart)).data;
    expect(data.titlesData.show, isFalse);
    expect(data.gridData.show, isFalse);
    expect(data.lineBarsData, hasLength(2));
    for (final line in data.lineBarsData) {
      expect(line.belowBarData.show, isFalse);
      expect(line.isCurved, isFalse);
    }
    final colors = SailTheme.of(tester.element(find.byType(LineChart))).colors;
    expect(data.lineBarsData.map((l) => l.color), [colors.orange, colors.info]);

    final dots = find.byKey(const ValueKey('bandwidth-legend-dot'));
    expect(dots, findsNWidgets(2));
    final dot = tester.widget<Container>(dots.first).decoration! as BoxDecoration;
    expect(dot.shape, BoxShape.circle);
  });

  testWidgets('on desktop the bandwidth chart keeps its axis labels and fill', (tester) async {
    await tester.pumpSailPage(const NetworkStatisticsPage());

    final data = tester.widget<LineChart>(find.byType(LineChart)).data;
    expect(data.titlesData.show, isTrue);
    expect(data.lineBarsData.first.belowBarData.show, isTrue);
    expect(find.byKey(const ValueKey('bandwidth-legend-dot')), findsNothing);
  });
}
