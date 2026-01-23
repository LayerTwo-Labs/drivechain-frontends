import 'package:auto_route/auto_route.dart';
import 'package:sail_ui/pages/router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => RouteType.cupertino(); //.cupertino, .adaptive ..etc

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: ParentChainRoute.page),
    AutoRoute(page: LogRoute.page),
    AutoRoute(page: ShutDownRoute.page),
    AutoRoute(page: UnlockWalletRoute.page),
    AutoRoute(page: SailCreateWalletRoute.page),
    AutoRoute(page: BackupWalletRoute.page),
    AutoRoute(page: RestoreWalletRoute.page),
    AutoRoute(page: DataDirSetupRoute.page),
    AutoRoute(page: BitcoinConfEditorRoute.page),
    AutoRoute(page: EnforcerConfEditorRoute.page),
    AutoRoute(page: SailTestRoute.page),
    AutoRoute(page: ConsoleTabRoute.page),
  ];

  @override
  List<AutoRouteGuard> get guards => [
    // optionally add root guards here
  ];
}
