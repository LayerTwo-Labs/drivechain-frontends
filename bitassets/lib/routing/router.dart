import 'package:auto_route/auto_route.dart';
import 'package:bitassets/pages/tabs/bitassets_configure_homepage_page.dart';
import 'package:bitassets/pages/tabs/bitassets_homepage.dart';
import 'package:bitassets/pages/tabs/console_page.dart';
import 'package:bitassets/pages/tabs/dutch_auction_page.dart';
import 'package:bitassets/pages/tabs/home_page.dart';
import 'package:bitassets/pages/tabs/messaging_page.dart';
import 'package:bitassets/pages/tabs/reserve_register_page.dart';
import 'package:bitassets/pages/tabs/settings_page.dart';
import 'package:bitassets/pages/test_page.dart';
import 'package:flutter/widgets.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/routing/password_guard.dart';

part 'router.gr.dart';

/* In this Router, all of the app routes are defined. Router code is auto-generated.
*  In replaceInRouteName we replace the Page suffix with Route in all generated
*  routes. e.g: The annotated HomePage class will be generated as HomeRoute. HomeRoute
*  is the component you route to.
*  
*  Use the [watch] flag to watch the files' system for edits and rebuild as necessary.
*  $ dart run build_runner watch
*  if you want the generator to run one time and exit, use
*  $ dart run build_runner build  --delete-conflicting-outputs

*/
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  // IMPORTANT: Update enum Tabs in home_page.dart when updating here,
  // routes should match exactly
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: HomeRoute.page,
      initial: true,
      guards: [
        PasswordGuard(),
      ],
      children: [
        AutoRoute(
          page: ParentChainRoute.page,
        ),
        AutoRoute(
          page: BitAssetsHomepageRoute.page,
          initial: true,
        ),
        AutoRoute(
          page: SidechainOverviewTabRoute.page,
        ),
        AutoRoute(
          page: BitAssetsTabRoute.page,
        ),
        AutoRoute(
          page: MessagingTabRoute.page,
        ),
        AutoRoute(
          page: DutchAuctionTabRoute.page,
        ),
        AutoRoute(
          page: SettingsTabRoute.page,
        ),
        AutoRoute(
          page: ConsoleTabRoute.page,
        ),
      ],
    ),
    AutoRoute(
      page: BitAssetsConfigureHomepageRoute.page,
    ),
    AutoRoute(
      page: LogRoute.page,
    ),
    AutoRoute(
      page: ShutDownRoute.page,
    ),

    /// This route is used in tests so that we can pump a widget into a route
    /// and use the real router for our test
    AutoRoute(page: SailTestRoute.page),
  ];
}
