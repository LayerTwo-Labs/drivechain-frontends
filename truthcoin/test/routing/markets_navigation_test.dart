import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
// ignore: avoid_material_import
import 'package:flutter/material.dart' show MaterialApp;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/sail_test_page.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/mocks/mocks.dart';
import 'package:truthcoin/pages/market_detail_page.dart';
import 'package:truthcoin/pages/market_explorer_page.dart';
import 'package:truthcoin/providers/market_provider.dart';
import 'package:truthcoin/providers/price_history_provider.dart';
import 'package:truthcoin/routing/open_market.dart';
import 'package:truthcoin/routing/router.dart';

import '../mocks/mock_truthcoin_rpc.dart';
import '../test_utils.dart';

const _otherTab = PageRouteInfo<void>('OtherTabRoute');

/// The app router with a light home shell: the Markets tab and one more tab.
class _MarketsTestRouter extends AppRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: PageInfo(
        HomeRoute.name,
        builder: (_) => SailTestPage(child: const AutoTabsRouter(routes: [MarketsTabRoute(), _otherTab])),
      ),
      initial: true,
      children: [
        AutoRoute(
          page: MarketsTabRoute.page,
          children: [
            AutoRoute(page: MarketExplorerRoute.page, initial: true),
            AutoRoute(page: MarketDetailRoute.page),
          ],
        ),
        AutoRoute(page: PageInfo('OtherTabRoute', builder: (_) => const SizedBox())),
      ],
    ),
  ];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestTruthcoinRPC mockRpc;
  late _MarketsTestRouter router;

  final twoDecisions =
      jsonDecode(File('test/fixtures/market_two_dimensions.json').readAsStringSync()) as Map<String, dynamic>;

  setUp(() async {
    mockRpc = TestTruthcoinRPC();
    mockRpc.marketListResponse = [
      {
        'market_id': '5e5ed0d19c4f',
        'title': twoDecisions['title'],
        'description': '',
        'outcome_count': 4,
        'state': 'trading',
        'volume_sats': 85430943,
        'created_at_height': 540,
      },
    ];
    mockRpc.marketGetResponse = twoDecisions;
    router = _MarketsTestRouter();

    GetIt.I.registerLazySingleton<SidechainRPC>(() => mockRpc);
    GetIt.I.registerLazySingleton<TruthcoinRPC>(() => mockRpc);
    GetIt.I.registerLazySingleton<BitcoindConnection>(() => MockBitcoindConnection());
    GetIt.I.registerLazySingleton<Logger>(() => Logger(level: Level.off));
    GetIt.I.registerLazySingleton<AppRouter>(() => router);
    GetIt.I.registerLazySingleton<MarketProvider>(() => MarketProvider());
    GetIt.I.registerLazySingleton<PriceHistoryProvider>(() => PriceHistoryProvider());
    final balanceProvider = BalanceProvider(connections: [mockRpc]);
    GetIt.I.registerLazySingleton<BalanceProvider>(() => balanceProvider);
    await registerTestDependencies();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      SailApp(
        dense: false,
        builder: (context) => MaterialApp.router(routerConfig: router.config()),
        initMethod: (_) async => (),
        accentColor: SailColorScheme.black,
        log: GetIt.I.get<Logger>(),
      ),
    );
    await tester.pumpAndSettle();
    router.innerRouterOf<TabsRouter>(HomeRoute.name)!.setActiveIndex(0);
    await tester.pumpAndSettle();
  }

  testWidgets('a tap on a card of two decisions opens the market', (tester) async {
    await pumpApp(tester);
    expect(find.byType(MarketExplorerPage), findsOneWidget);

    await tester.tap(find.text(twoDecisions['title'] as String));
    await tester.pumpAndSettle();

    expect(find.byType(MarketDetailPage), findsOneWidget);
  });

  testWidgets('the line of left-out outcomes opens the market', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('+ 1 more outcome'));
    await tester.pumpAndSettle();

    expect(find.byType(MarketDetailPage), findsOneWidget);
  });

  testWidgets('a tap opens the market again after a deep link to it and a step back', (tester) async {
    await pumpApp(tester);
    await openMarketsRoute(MarketDetailRoute(marketId: '5e5ed0d19c4f'));
    await tester.pumpAndSettle();
    expect(find.byType(MarketDetailPage), findsOneWidget);

    await tester.tap(find.widgetWithText(SailButton, '←  Markets').first);
    await tester.pumpAndSettle();
    expect(find.byType(MarketExplorerPage), findsOneWidget, reason: 'back shows the grid');

    await tester.tap(find.text(twoDecisions['title'] as String));
    await tester.pumpAndSettle();
    expect(find.byType(MarketDetailPage), findsOneWidget);
  });
}
