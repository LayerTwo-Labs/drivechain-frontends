import 'package:bitassets/providers/asset_analytics_provider.dart';
import 'package:bitassets/providers/bitassets_provider.dart';
import 'package:bitassets/widgets/portfolio_dashboard.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/rpc_mock_bitassets.dart';
import 'test_utils.dart';

const assetId = '1234567890abcdef1234567890abcdef';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await GetIt.I.reset();
    await registerTestDependencies();
    GetIt.I.registerSingleton<BitAssetsRPC>(MockBitAssetsRPC());
    GetIt.I.registerLazySingleton<NotificationProvider>(() => NotificationProvider());
    GetIt.I.registerLazySingleton<BitAssetsProvider>(
      () => BitAssetsProvider(),
      dispose: (provider) => provider.dispose(),
    );
    GetIt.I.registerLazySingleton<AssetAnalyticsProvider>(
      () => AssetAnalyticsProvider(),
      dispose: (provider) => provider.dispose(),
    );
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  testWidgets('complete estimates show allocation and raw amounts', (tester) async {
    await showPortfolio(
      tester,
      balance: 200000000,
      holdings: [
        AssetHolding(
          assetId: 'btc',
          assetName: null,
          amount: 200000000,
          estimatedValueSats: 200000000,
          percentageOfPortfolio: 25,
        ),
        AssetHolding(
          assetId: assetId,
          assetName: null,
          amount: 300,
          estimatedValueSats: 600000000,
          percentageOfPortfolio: 75,
        ),
      ],
    );

    expect(find.text('Estimated allocation'), findsOneWidget);
    expect(find.text('25.0%'), findsOneWidget);
    expect(find.text('75.0%'), findsOneWidget);
    expect(find.text('2.0000 BTC'), findsOneWidget);
    expect(find.text('300'), findsOneWidget);
    expect(find.text('Price data is unavailable'), findsNothing);
    expect(allocationChart(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('missing prices hide shares and keep raw amounts', (tester) async {
    await showPortfolio(
      tester,
      balance: 200000000,
      holdings: [
        AssetHolding(
          assetId: 'btc',
          assetName: null,
          amount: 200000000,
          estimatedValueSats: 200000000,
          percentageOfPortfolio: null,
        ),
        AssetHolding(
          assetId: assetId,
          assetName: null,
          amount: 300,
          estimatedValueSats: null,
          percentageOfPortfolio: null,
        ),
      ],
    );

    expect(find.text('Price data is unavailable'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(2));
    expect(find.text('2.0000 BTC'), findsOneWidget);
    expect(find.text('300'), findsOneWidget);
    expect(allocationChart(), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pending BTC stays in the amount and allocation', (tester) async {
    await showPortfolio(
      tester,
      balance: 100000000,
      pending: 100000000,
      holdings: [
        AssetHolding(
          assetId: 'btc',
          assetName: null,
          amount: 200000000,
          estimatedValueSats: 200000000,
          percentageOfPortfolio: 100,
        ),
      ],
    );

    expect(find.text('1.00000000 BTC'), findsOneWidget);
    expect(find.text('+1.00000000 BTC pending'), findsOneWidget);
    expect(find.text('2.0000 BTC'), findsOneWidget);
    expect(find.text('100.0%'), findsOneWidget);
    expect(allocationChart(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an empty wallet keeps the deposit actions', (tester) async {
    await showPortfolio(tester, holdings: []);

    expect(find.text('No holdings yet'), findsNWidgets(2));
    expect(
      find.byWidgetPredicate((widget) => widget is SailButton && widget.label == 'Browse Auctions'),
      findsOneWidget,
    );
    expect(find.byWidgetPredicate((widget) => widget is SailButton && widget.label == 'Swap Assets'), findsOneWidget);
    expect(find.text('Price data is unavailable'), findsNothing);
    expect(allocationChart(), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pool reads keep allocation in the loading state', (tester) async {
    await showPortfolio(
      tester,
      poolsLoading: true,
      holdings: [
        AssetHolding(
          assetId: 'btc',
          assetName: null,
          amount: 200000000,
          estimatedValueSats: 200000000,
          percentageOfPortfolio: 100,
        ),
      ],
    );

    expect(find.byType(SailCircularProgressIndicator), findsWidgets);
    expect(find.text('100.0%'), findsNothing);
    expect(find.text('Price data is unavailable'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final source in ['holdings', 'pools']) {
    testWidgets('a $source read error appears in the allocation card', (tester) async {
      await showPortfolio(
        tester,
        holdings: [],
        holdingsError: source == 'holdings' ? 'private wallet error' : null,
        poolsError: source == 'pools' ? 'private pool error' : null,
      );

      expect(find.text('Cannot load portfolio data'), findsOneWidget);
      expect(find.textContaining('private'), findsNothing);
      expect(find.text('Price data is unavailable'), findsNothing);
      expect(allocationChart(), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}

Future<void> showPortfolio(
  WidgetTester tester, {
  required List<AssetHolding> holdings,
  int balance = 0,
  int pending = 0,
  bool poolsLoading = false,
  String? holdingsError,
  String? poolsError,
}) async {
  await tester.pumpSailPage(const SingleChildScrollView(child: PortfolioDashboard()));
  await tester.pumpAndSettle();
  final provider = GetIt.I.get<AssetAnalyticsProvider>();
  provider
    ..holdings = holdings
    ..totalBtcBalance = balance
    ..pendingBtcBalance = pending
    ..holdingsError = holdingsError
    ..poolsError = poolsError
    ..isLoadingHoldings = false
    ..isLoadingPools = poolsLoading;
  provider.notifyListeners();
  await tester.pump();
}

Finder allocationChart() => find.descendant(
  of: find.byWidgetPredicate((widget) => widget is SailCard && widget.title == 'Estimated allocation'),
  matching: find.byType(CustomPaint),
);
