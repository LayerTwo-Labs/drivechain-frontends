import 'package:auto_route/auto_route.dart';
import 'package:coinshift/coinshift_module.dart';
import 'package:coinshift/pages/swap_analytics_page.dart';
import 'package:coinshift/pages/tabs/swaps_page.dart';
import 'package:sail_ui/shell/shell.dart';

part 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter();

  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => sidechainShellRoutes(CoinShiftModule());
}
