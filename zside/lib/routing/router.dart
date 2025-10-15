import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/routing/password_guard.dart';
import 'package:zside/pages/tabs/home_page.dart';
import 'package:zside/pages/tabs/settings/settings_tab.dart';
import 'package:zside/pages/tabs/sidechain_overview_page.dart';
import 'package:zside/pages/tabs/zside/zside_bill_page.dart';
import 'package:zside/pages/tabs/zside/zside_melt_cast_page.dart';
import 'package:zside/pages/tabs/zside/zside_rpc_tab_page.dart';
import 'package:zside/pages/tabs/zside/zside_shield_deshield_page.dart';
import 'package:zside/pages/tabs/zside/zside_transfer_page.dart';
import 'package:zside/pages/tabs/zside_configure_homepage_page.dart';
import 'package:zside/pages/tabs/zside_homepage.dart';
import 'package:zside/pages/test_page.dart';

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
  AppRouter();

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
          page: ZSideHomepageRoute.page,
          initial: true,
        ),
        AutoRoute(
          page: SidechainOverviewTabRoute.page,
        ),
        AutoRoute(
          page: ZSideMeltCastTabRoute.page,
        ),
        AutoRoute(
          page: ZSideShieldDeshieldTabRoute.page,
        ),
        AutoRoute(
          page: ZSideTransferTabRoute.page,
        ),
        AutoRoute(
          page: ZSideRPCTabRoute.page,
        ),
        AutoRoute(
          page: SettingsTabRoute.page,
        ),
      ],
    ),
    AutoRoute(
      page: ZSideConfigureHomepageRoute.page,
    ),
    AutoRoute(
      page: ZSideBillRoute.page,
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
