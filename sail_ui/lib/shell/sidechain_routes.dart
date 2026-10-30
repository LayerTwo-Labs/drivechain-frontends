import 'package:auto_route/auto_route.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/run_sidechain_app.dart';
import 'package:sail_ui/shell/sidechain_module.dart';

/// The full route list of a sidechain app. [chainTabs] go under the home route,
/// [chainPages] at the top level.
List<AutoRoute> sidechainShellRoutes(
  SidechainModule module, {
  List<AutoRoute> chainTabs = const [],
  List<AutoRoute> chainPages = const [],
}) {
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
      children: [
        AutoRoute(page: ParentChainRoute.page),
        AutoRoute(page: ExplorerRoute.page),
        AutoRoute(page: BmmRoute.page),
        AutoRoute(page: SidechainHomepageRoute.page, initial: true),
        ...chainTabs,
        AutoRoute(page: SidechainSettingsRoute.page),
        AutoRoute(page: ConsoleTabRoute.page),
      ],
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
    ...chainPages,
    AutoRoute(page: SailTestRoute.page),
  ];
}
