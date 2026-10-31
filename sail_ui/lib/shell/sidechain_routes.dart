import 'package:auto_route/auto_route.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/run_sidechain_app.dart';
import 'package:sail_ui/shell/sidechain_module.dart';

/// The full route list of a sidechain app. The tab routes of [module] go under the
/// home route, its page routes at the top level.
List<AutoRoute> sidechainShellRoutes(SidechainModule module) {
  return [
    AutoRoute(
      page: SidechainHomeRoute.page,
      initial: true,
      guards: [
        NetworkGuard(),
        WalletGuard(
          createWalletRoute: (onWalletCreated) => SailCreateWalletRoute(
            homeRoute: const SidechainHomeRoute(),
            onWalletCreated: onWalletCreated,
            additionalRestoreOptionsBuilder: (context) => WalletBackupRestoreOptions(
              bootBinaries: (log) async => bootSidechainBinaries(module, log),
              binariesToStop: module.binariesToStop,
            ),
          ),
        ),
        PasswordGuard(),
      ],
      children: shellTabRouteConfig(module.tabRoutes),
    ),
    AutoRoute(page: LogRoute.page),
    AutoRoute(page: ShutDownRoute.page),
    AutoRoute(page: SidechainConfigureHomepageRoute.page),
    AutoRoute(page: UnlockWalletRoute.page),
    AutoRoute(page: SailCreateWalletRoute.page),
    AutoRoute(page: BackupWalletRoute.page),
    AutoRoute(page: RestoreWalletRoute.page),
    AutoRoute(page: BitcoinConfEditorRoute.page),
    AutoRoute(page: EnforcerConfEditorRoute.page),
    AutoRoute(page: SidechainConfEditorRoute.page),
    ...module.pageRoutes,
    AutoRoute(page: SailTestRoute.page),
  ];
}

/// The tab routes of the chain shell, with [chainTabs] between the homepage and the settings.
List<AutoRoute> shellTabRouteConfig(List<AutoRoute> chainTabs) => [
  AutoRoute(page: ParentChainRoute.page),
  AutoRoute(page: ExplorerRoute.page),
  AutoRoute(page: BmmRoute.page),
  AutoRoute(page: SidechainHomepageRoute.page, initial: true),
  ...chainTabs,
  AutoRoute(page: SidechainSettingsRoute.page),
  AutoRoute(page: ConsoleTabRoute.page),
];
