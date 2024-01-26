import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:sidesail/config/runtime_args.dart';
import 'package:sidesail/config/sidechains.dart';
import 'package:sidesail/pages/tabs/dashboard_tab_page.dart';
import 'package:sidesail/pages/tabs/ethereum/ethereum_rpc_tab_page.dart';
import 'package:sidesail/pages/tabs/home_page.dart';
import 'package:sidesail/pages/tabs/settings/app_settings_tab.dart';
import 'package:sidesail/pages/tabs/settings/node_settings_tab.dart';
import 'package:sidesail/pages/tabs/sidechain_explorer_tab_page.dart';
import 'package:sidesail/pages/tabs/testchain/mainchain/bmm_tab_page.dart';
import 'package:sidesail/pages/tabs/testchain/mainchain/transfer_mainchain_tab_route.dart';
import 'package:sidesail/pages/tabs/testchain/mainchain/withdrawal_bundle_tab_page.dart';
import 'package:sidesail/pages/tabs/testchain/testchain_rpc_tab_page.dart';
import 'package:sidesail/pages/tabs/zcash/zcash_melt_cast_page.dart';
import 'package:sidesail/pages/tabs/zcash/zcash_operation_statuses.dart';
import 'package:sidesail/pages/tabs/zcash/zcash_rpc_tab_page.dart';
import 'package:sidesail/pages/tabs/zcash/zcash_shield_deshield_page.dart';
import 'package:sidesail/pages/tabs/zcash/zcash_transfer_page.dart';
import 'package:sidesail/pages/test_page.dart';

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
class AppRouter extends _$AppRouter {
  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: HomeRoute.page,
          initial: true,
          children: [
            AutoRoute(
              page: SidechainExplorerTabRoute.page,
            ),
            AutoRoute(
              page: DashboardTabRoute.page,
              initial: RuntimeArgs.chain.toLowerCase() == TestSidechain().name.toLowerCase() ? true : false,
            ),
            AutoRoute(
              page: TestchainRPCTabRoute.page,
            ),
            AutoRoute(
              page: TransferMainchainTabRoute.page,
            ),
            AutoRoute(
              page: WithdrawalBundleTabRoute.page,
            ),
            AutoRoute(
              page: BlindMergedMiningTabRoute.page,
            ),
            AutoRoute(
              page: EthereumRPCTabRoute.page,
              initial: RuntimeArgs.chain.toLowerCase() == EthereumSidechain().name.toLowerCase() ? true : false,
            ),
            AutoRoute(
              page: ZCashMeltCastTabRoute.page,
              initial: RuntimeArgs.chain.toLowerCase() == ZCashSidechain().name.toLowerCase() ? true : false,
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
              page: NodeSettingsTabRoute.page,
            ),
            AutoRoute(
              page: SettingsTabRoute.page,
            ),
          ],
        ),

        /// This route is used in tests so that we can pump a widget into a route
        /// and use the real router for our test
        AutoRoute(page: SailTestRoute.page),
      ];
}
