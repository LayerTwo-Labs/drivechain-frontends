import 'package:auto_route/auto_route.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:coinshift/pages/tabs/home_page.dart';
import 'package:coinshift/pages/tabs/settings_page.dart';
import 'package:coinshift/pages/tabs/coinshift_configure_homepage_page.dart';
import 'package:coinshift/pages/tabs/coinshift_homepage.dart';
import 'package:coinshift/pages/tabs/swaps_page.dart';
import 'package:coinshift/pages/coinshift_conf_editor_page.dart';
import 'package:coinshift/pages/swap_analytics_page.dart';

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
        NetworkGuard(),
        WalletGuard(createWalletRoute: () => SailCreateWalletRoute(homeRoute: const HomeRoute())),
        PasswordGuard(),
      ],
      children: [
        AutoRoute(
          page: ParentChainRoute.page,
        ),
        AutoRoute(
          page: CoinShiftHomepageRoute.page,
          initial: true,
        ),
        AutoRoute(
          page: SwapsTabRoute.page,
        ),
        AutoRoute(
          page: SwapAnalyticsRoute.page,
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
      page: LogRoute.page,
    ),
    AutoRoute(
      page: ShutDownRoute.page,
    ),
    AutoRoute(
      page: CoinShiftConfigureHomepageRoute.page,
    ),
    AutoRoute(
      page: UnlockWalletRoute.page,
    ),
    AutoRoute(
      page: SailCreateWalletRoute.page,
    ),
    AutoRoute(
      page: BackupWalletRoute.page,
    ),
    AutoRoute(
      page: RestoreWalletRoute.page,
    ),
    AutoRoute(
      page: BitcoinConfEditorRoute.page,
    ),
    AutoRoute(
      page: EnforcerConfEditorRoute.page,
    ),
    AutoRoute(
      page: CoinShiftConfEditorRoute.page,
    ),

    /// This route is used in tests so that we can pump a widget into a route
    /// and use the real router for our test
    AutoRoute(page: SailTestRoute.page),
  ];
}
