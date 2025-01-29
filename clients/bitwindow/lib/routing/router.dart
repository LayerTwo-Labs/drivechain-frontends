import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/pages/learn_page.dart';
import 'package:bitwindow/pages/overview_page.dart';
import 'package:bitwindow/pages/root_page.dart';
import 'package:bitwindow/pages/sidechain_activation_management_page.dart';
import 'package:bitwindow/pages/sidechain_proposal_page.dart';
import 'package:bitwindow/pages/sidechains_page.dart';
import 'package:bitwindow/pages/wallet_page.dart';
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
          path: '/',
          page: RootRoute.page,
          initial: true,
          children: [
            RedirectRoute(
              path: '',
              redirectTo: 'overview',
            ),
            AutoRoute(
              path: 'overview',
              page: OverviewRoute.page,
            ),
            AutoRoute(
              path: 'learn',
              page: LearnRoute.page,
            ),
            AutoRoute(
              path: 'wallet',
              page: WalletRoute.page,
            ),
            AutoRoute(
              path: 'sidechains',
              page: SidechainsRoute.page,
            ),
          ],
        ),
        AutoRoute(
          page: SailLogRoute.page,
        ),
        AutoRoute(
          page: ShuttingDownRoute.page,
        ),
      ];
}
