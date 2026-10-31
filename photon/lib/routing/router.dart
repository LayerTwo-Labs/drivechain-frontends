import 'package:auto_route/auto_route.dart';
import 'package:photon/pages/tabs/block_explorer_page.dart';
import 'package:photon/pages/tabs/mempool_explorer_page.dart';
import 'package:photon/pages/tabs/transaction_builder_page.dart';
import 'package:photon/pages/tabs/withdrawals_page.dart';
import 'package:photon/photon_module.dart';
import 'package:sail_ui/shell/shell.dart';

part 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter();

  @override
  RouteType get defaultRouteType => const RouteType.adaptive();

  @override
  List<AutoRoute> get routes => sidechainShellRoutes(PhotonModule());
}
