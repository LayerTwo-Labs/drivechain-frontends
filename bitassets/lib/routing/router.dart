import 'package:auto_route/auto_route.dart';
import 'package:bitassets/bitassets_module.dart';
import 'package:bitassets/pages/tabs/amm_page.dart';
import 'package:bitassets/pages/tabs/asset_explorer_page.dart';
import 'package:bitassets/pages/tabs/auction_browser_page.dart';
import 'package:bitassets/pages/tabs/dutch_auction_page.dart';
import 'package:bitassets/pages/tabs/messaging_page.dart';
import 'package:bitassets/pages/tabs/reserve_register_page.dart';
import 'package:sail_ui/shell/shell.dart';

part 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter();

  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => sidechainShellRoutes(
    BitAssetsModule(),
    chainTabs: [
      AutoRoute(page: BitAssetsTabRoute.page),
      AutoRoute(page: MessagingTabRoute.page),
      AutoRoute(page: DutchAuctionTabRoute.page),
      AutoRoute(page: AmmTabRoute.page),
      AutoRoute(page: AssetExplorerTabRoute.page),
      AutoRoute(page: AuctionBrowserTabRoute.page),
    ],
  );
}
