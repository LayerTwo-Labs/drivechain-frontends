import 'package:auto_route/auto_route.dart';
import 'package:bitwindow/dialogs/network_statistics_dialog.dart';
import 'package:bitwindow/pages/bitcoin_conf_editor_page.dart';
import 'package:bitwindow/pages/configure_homepage.dart';
import 'package:bitwindow/pages/console_page.dart';
import 'package:bitwindow/pages/cpu_mining_page.dart';
import 'package:bitwindow/pages/explorer/m4_explorer_page.dart';
import 'package:bitwindow/pages/learn_page.dart';
import 'package:bitwindow/pages/overview_page.dart';
import 'package:bitwindow/pages/remove_encryption_page.dart';
import 'package:bitwindow/pages/root_page.dart';
import 'package:bitwindow/pages/success_page.dart';
import 'package:bitwindow/pages/settings_page.dart';
import 'package:bitwindow/pages/sidechain_activation_management_page.dart';
import 'package:bitwindow/pages/sidechain_proposal_page.dart';
import 'package:bitwindow/pages/sidechains_page.dart';
import 'package:bitwindow/pages/wallet/cash_check_page.dart';
import 'package:bitwindow/pages/wallet/cash_check_success_page.dart';
import 'package:bitwindow/pages/wallet/check_detail_page.dart';
import 'package:bitwindow/pages/wallet/create_check_page.dart';
import 'package:bitwindow/pages/wallet/create_timestamp_page.dart';
import 'package:bitwindow/pages/wallet/timestamp_detail_page.dart';
import 'package:bitwindow/pages/wallet/verify_timestamp_page.dart';
import 'package:bitwindow/pages/wallet/wallet_page.dart';
import 'package:bitwindow/pages/welcome/create_another_wallet_page.dart';
import 'package:bitwindow/pages/welcome/create_wallet_page.dart';
import 'package:bitwindow/providers/wallet_writer_provider.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/routing/password_guard.dart';

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
        AutoRoute(
          path: 'console',
          page: ConsoleRoute.page,
        ),
        AutoRoute(
          path: 'settings',
          page: SettingsRoute.page,
        ),
      ],
      guards: [WalletGuard(), PasswordGuard()],
    ),
    AutoRoute(
      path: '/log',
      page: LogRoute.page,
    ),
    AutoRoute(
      path: '/shutting-down',
      page: ShutDownRoute.page,
    ),
    AutoRoute(
      path: '/configure-home',
      page: ConfigureHomeRoute.page,
    ),
    AutoRoute(
      path: '/create-wallet',
      page: CreateWalletRoute.page,
    ),
    AutoRoute(
      path: '/create-another-wallet',
      page: CreateAnotherWalletRoute.page,
    ),
    AutoRoute(
      path: '/unlock-wallet',
      page: UnlockWalletRoute.page,
    ),
    AutoRoute(
      path: '/bitcoin-config',
      page: BitcoinConfEditorRoute.page,
    ),
    AutoRoute(
      path: '/create-check',
      page: CreateCheckRoute.page,
    ),
    AutoRoute(
      path: '/cash-check',
      page: CashCheckRoute.page,
    ),
    AutoRoute(
      path: '/cash-check-success/:txid',
      page: CashCheckSuccessRoute.page,
    ),
    AutoRoute(
      path: '/check/:id',
      page: CheckDetailRoute.page,
    ),
    AutoRoute(
      path: '/timestamp-file',
      page: CreateTimestampRoute.page,
    ),
    AutoRoute(
      path: '/timestamp/:id',
      page: TimestampDetailRoute.page,
    ),
    AutoRoute(
      path: '/verify-timestamp',
      page: VerifyTimestampRoute.page,
    ),
    AutoRoute(
      path: '/cpu-mining',
      page: CpuMiningRoute.page,
    ),
    AutoRoute(
      path: '/m4-explorer',
      page: M4ExplorerRoute.page,
    ),
    AutoRoute(
      path: '/network-statistics',
      page: NetworkStatisticsRoute.page,
    ),
    AutoRoute(
      path: '/remove-encryption',
      page: RemoveEncryptionRoute.page,
    ),
    AutoRoute(
      path: '/success',
      page: SuccessRoute.page,
    ),
  ];
}

class WalletGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    if (await GetIt.I.get<WalletWriterProvider>().hasExistingWallet()) {
      resolver.next(true);
    } else {
      await router.push(CreateWalletRoute());
      resolver.next(true);
    }
  }
}
