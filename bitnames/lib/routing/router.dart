import 'package:auto_route/auto_route.dart';
import 'package:bitnames/pages/tabs/console_page.dart';
import 'package:bitnames/pages/tabs/home_page.dart';
import 'package:bitnames/pages/tabs/messaging_page.dart';
import 'package:bitnames/pages/tabs/reserve_register_page.dart';
import 'package:bitnames/pages/tabs/settings_page.dart';
import 'package:bitnames/pages/test_page.dart';
import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

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
              page: BitnamesTabRoute.page,
            ),
            AutoRoute(
              page: MessagingTabRoute.page,
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
          page: ShuttingDownRoute.page,
        ),

        /// This route is used in tests so that we can pump a widget into a route
        /// and use the real router for our test
        AutoRoute(page: SailTestRoute.page),
      ];
}
