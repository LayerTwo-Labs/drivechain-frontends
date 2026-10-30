import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:sail_ui/shell/shell.dart';
import 'package:truthcoin/pages/market_creation_page.dart';
import 'package:truthcoin/pages/market_detail_page.dart';
import 'package:truthcoin/pages/market_explorer_page.dart';
import 'package:truthcoin/pages/tabs/markets_tab_page.dart';
import 'package:truthcoin/pages/tabs/portfolio_page.dart';
import 'package:truthcoin/pages/voting_dashboard_page.dart';
import 'package:truthcoin/truthcoin_module.dart';

part 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter();

  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => sidechainShellRoutes(
    TruthcoinModule(),
    chainTabs: [
      AutoRoute(
        page: MarketsTabRoute.page,
        children: [
          AutoRoute(page: MarketExplorerRoute.page, initial: true),
          AutoRoute(page: MarketDetailRoute.page),
          AutoRoute(page: MarketCreationRoute.page),
        ],
      ),
      AutoRoute(page: PortfolioRoute.page),
      AutoRoute(page: VotingDashboardRoute.page),
    ],
  );
}
