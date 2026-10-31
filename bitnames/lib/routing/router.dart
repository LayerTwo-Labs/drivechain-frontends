import 'package:auto_route/auto_route.dart';
import 'package:bitnames/bitnames_module.dart';
import 'package:bitnames/pages/tabs/messaging_page.dart';
import 'package:bitnames/pages/tabs/reserve_register_page.dart';
import 'package:sail_ui/shell/shell.dart';

part 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter();

  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => sidechainShellRoutes(BitnamesModule());
}
