import 'package:auto_route/auto_route.dart';
import 'package:sail_ui/shell/shell.dart';
import 'package:thunder/thunder_module.dart';

part 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter();

  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => sidechainShellRoutes(ThunderModule());
}
