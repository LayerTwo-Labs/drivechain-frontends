import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:zside/pages/tabs/home_page.dart';
import 'package:zside/pages/tabs/settings/settings_tab.dart';
import 'package:zside/pages/tabs/sidechain_overview_page.dart';
import 'package:zside/pages/tabs/zcash/zcash_bill_page.dart';
import 'package:zside/pages/tabs/zcash/zcash_melt_cast_page.dart';
import 'package:zside/pages/tabs/zcash/zcash_operation_statuses.dart';
import 'package:zside/pages/tabs/zcash/zcash_rpc_tab_page.dart';
import 'package:zside/pages/tabs/zcash/zcash_shield_deshield_page.dart';
import 'package:zside/pages/tabs/zcash/zcash_transfer_page.dart';
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
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  // IMPORTANT: Update enum Tabs in home_page.dart when updating here,
  // routes should match exactly
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: HomeRoute.page,
          initial: true,
          children: [
            AutoRoute(
              page: ParentChainRoute.page,
            ),
            AutoRoute(
              page: SidechainOverviewTabRoute.page,
              initial: true,
            ),
            AutoRoute(
              page: ZCashMeltCastTabRoute.page,
            ),
            AutoRoute(
              page: ZCashShieldDeshieldTabRoute.page,
            ),
            AutoRoute(
              page: ZCashTransferTabRoute.page,
            ),
            AutoRoute(
              page: ZCashOperationStatusesTabRoute.page,
            ),
            AutoRoute(
              page: ZCashRPCTabRoute.page,
            ),
            AutoRoute(
              page: SettingsTabRoute.page,
            ),
          ],
        ),
        AutoRoute(
          page: ZCashBillRoute.page,
        ),
        AutoRoute(
          page: LogRoute.page,
        ),
        AutoRoute(
          page: ShuttingDownRoute.page,
        ),

        /// This route is used in tests so that we can pump a widget into a route
        /// and use the real router for our test
        AutoRoute(page: SailTestRoute.page),
      ];
}
