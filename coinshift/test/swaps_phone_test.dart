import 'package:coinshift/pages/swap_analytics_page.dart';
import 'package:coinshift/pages/tabs/swaps_page.dart';
import 'package:coinshift/providers/analytics_provider.dart';
import 'package:coinshift/providers/swap_provider.dart';
import 'package:coinshift/widgets/swap/swap_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

class _Analytics extends ChangeNotifier implements AnalyticsProvider {
  @override
  AnalyticsTimeRange get selectedTimeRange => AnalyticsTimeRange.values.first;

  @override
  SwapStatistics get statistics => SwapStatistics.empty();

  @override
  Map<ParentChainType, ChainHealth> get chainHealth => {};

  @override
  List<CoinShiftSwap> get swapsNeedingAttention => [];

  @override
  bool get isLoading => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Swaps extends ChangeNotifier implements SwapProvider {
  @override
  List<CoinShiftSwap> get swaps => [];

  @override
  List<CoinShiftSwap> get activeSwaps => [];

  @override
  List<CoinShiftSwap> get claimableSwaps => [];

  @override
  List<CoinShiftSwap> get completedSwaps => [];

  @override
  bool get isLoading => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, Widget child) async {
  final width = SailStyleValues.phoneLayoutOverride == true ? 390.0 : 1200.0;
  await tester.binding.setSurfaceSize(Size(width, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: Scaffold(body: child),
      ),
    ),
  );
  await tester.pump();
}

double _fontSize(WidgetTester tester, String text) => tester.widget<Text>(find.text(text).first).style!.fontSize!;

void main() {
  setUp(() async {
    await registerTestDependencies();
    GetIt.I.registerLazySingleton<FormatterProvider>(() => FormatterProvider(GetIt.I.get<SettingsProvider>()));
    GetIt.I.registerSingleton<AnalyticsProvider>(_Analytics());
    GetIt.I.registerSingleton<SwapProvider>(_Swaps());
  });

  tearDown(() async {
    SailStyleValues.phoneLayoutOverride = null;
    await GetIt.I.reset();
  });

  testWidgets('a phone shows the swap analytics in one stat panel under a 16 px title', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await _pump(tester, const SwapAnalyticsPage());

    expect(tester.takeException(), isNull);
    expect(find.byType(SailStatList), findsOneWidget);
    expect(find.byType(SailStatRow), findsNWidgets(5));
    expect(_fontSize(tester, 'Swap Analytics'), 16);
  });

  testWidgets('the desktop keeps five stat cards under a 20 px title', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await _pump(tester, const SwapAnalyticsPage());

    expect(find.byType(SailStatList), findsNothing);
    expect(_fontSize(tester, 'Swap Analytics'), 20);
  });

  for (final (phone, size) in [(true, 15.0), (false, 24.0)]) {
    testWidgets('the swap counts are $size px when phoneLayout is $phone', (tester) async {
      SailStyleValues.phoneLayoutOverride = phone;
      await _pump(tester, SwapStats(model: SwapsPageViewModel()));

      expect(tester.takeException(), isNull);
      expect(_fontSize(tester, '0'), size);
    });
  }

  for (final (phone, size) in [(true, 13.0), (false, 15.0)]) {
    testWidgets('an empty swap list reads at $size px when phoneLayout is $phone', (tester) async {
      SailStyleValues.phoneLayoutOverride = phone;
      await _pump(tester, const SwapList());

      expect(_fontSize(tester, 'No swaps found'), size);
    });
  }
}
