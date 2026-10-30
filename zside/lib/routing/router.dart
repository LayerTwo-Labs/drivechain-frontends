import 'package:auto_route/auto_route.dart';
import 'package:sail_ui/shell/shell.dart';
import 'package:zside/pages/tabs/zside/zside_bill_page.dart';
import 'package:zside/pages/tabs/zside/zside_melt_cast_page.dart';
import 'package:zside/pages/tabs/zside/zside_shield_deshield_page.dart';
import 'package:zside/pages/tabs/zside/zside_transfer_page.dart';
import 'package:zside/zside_module.dart';

part 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter();

  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => sidechainShellRoutes(
    ZSideModule(),
    chainTabs: [
      AutoRoute(page: ZSideMeltCastTabRoute.page),
      AutoRoute(page: ZSideShieldDeshieldTabRoute.page),
      AutoRoute(page: ZSideTransferTabRoute.page),
    ],
    chainPages: [
      AutoRoute(page: ZSideBillRoute.page),
    ],
  );
}
