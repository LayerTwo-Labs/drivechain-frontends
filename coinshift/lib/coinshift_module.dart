import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:coinshift/gen/version.dart';
import 'package:coinshift/providers/analytics_provider.dart';
import 'package:coinshift/providers/swap_provider.dart';
import 'package:coinshift/routing/router.dart';
import 'package:coinshift/widgets/homepage_widget_catalog.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/shell.dart';

class CoinShiftModule extends SidechainModule {
  @override
  Sidechain get chain => CoinShift();

  @override
  String get appName => 'CoinShift';

  @override
  SidechainAppVersion get version => const SidechainAppVersion(
    version: AppVersion.version,
    versionString: AppVersion.versionString,
    buildDate: AppVersion.buildDate,
    commitFull: AppVersion.commitFull,
    appName: AppVersion.appName,
  );

  @override
  RootStackRouter registerRouter(GetIt getIt) {
    if (!getIt.isRegistered<AppRouter>()) {
      getIt.registerSingleton<AppRouter>(AppRouter());
    }
    return getIt.get<AppRouter>();
  }

  @override
  SidechainRPC registerRPC(GetIt getIt) {
    if (!getIt.isRegistered<CoinShiftRPC>()) {
      getIt.registerSingleton<CoinShiftRPC>(CoinShiftLive());
    }
    return getIt.get<CoinShiftRPC>();
  }

  @override
  Future<void> registerChainProviders(GetIt getIt, Directory applicationDir, Logger log) async {
    if (!getIt.isRegistered<SwapProvider>()) {
      getIt.registerLazySingleton<SwapProvider>(() => SwapProvider(), dispose: (provider) => provider.dispose());
    }
    if (!getIt.isRegistered<AnalyticsProvider>()) {
      getIt.registerLazySingleton<AnalyticsProvider>(
        () => AnalyticsProvider(),
        dispose: (provider) => provider.dispose(),
      );
    }
  }

  @override
  Map<String, String> confPorts(String network) {
    switch (network) {
      case 'regtest':
        return {
          'rpc-addr': '127.0.0.1:16255',
          'net-addr': '0.0.0.0:14255',
          'mainchain-grpc-url': 'http://localhost:50051',
        };
      case 'mainnet':
        return {
          'rpc-addr': '127.0.0.1:26255',
          'net-addr': '0.0.0.0:24255',
          'mainchain-grpc-url': 'http://localhost:50051',
        };
      case 'signet':
      default:
        return {
          'rpc-addr': '127.0.0.1:6255',
          'net-addr': '0.0.0.0:4255',
          'mainchain-grpc-url': 'http://localhost:50051',
        };
    }
  }

  @override
  List<String> get defaultHomepageWidgets => [
    'quote_bar',
    'balance_card',
    'receive_card',
    'send_card',
    'swap_card',
    'active_swaps',
    'utxo_table',
  ];

  @override
  Map<String, HomepageWidgetInfo> get widgetCatalog => CoinShiftWidgetCatalog.getCatalogMap();

  @override
  List<ShellTab> get tabs => const [
    ShellTab(label: 'Swaps', route: SwapsTabRoute(), sourceFiles: ['swaps_page.dart']),
  ];

  @override
  List<AutoRoute> get tabRoutes => [
    AutoRoute(page: SwapsTabRoute.page),
    AutoRoute(page: SwapAnalyticsRoute.page),
  ];
}
