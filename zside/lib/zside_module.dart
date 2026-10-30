import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/shell.dart';
import 'package:zside/gen/version.dart';
import 'package:zside/providers/cast_provider.dart';
import 'package:zside/providers/transactions_provider.dart';
import 'package:zside/providers/zside_provider.dart';
import 'package:zside/routing/router.dart';
import 'package:zside/widgets/homepage_widget_catalog.dart';

class ZSideModule extends SidechainModule {
  @override
  Sidechain get chain => ZSide();

  @override
  String get appName => 'ZSide';

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
    if (!getIt.isRegistered<ZSideRPC>()) {
      getIt.registerSingleton<ZSideRPC>(ZSideLive());
    }
    return getIt.get<ZSideRPC>();
  }

  @override
  Future<void> registerChainProviders(GetIt getIt, Directory applicationDir, Logger log) async {
    if (!getIt.isRegistered<ZSideProvider>()) {
      getIt.registerLazySingleton<ZSideProvider>(() => ZSideProvider());
    }
    if (!getIt.isRegistered<CastProvider>()) {
      getIt.registerLazySingleton<CastProvider>(() => CastProvider());
    }
    if (!getIt.isRegistered<TransactionsProvider>()) {
      getIt.registerLazySingleton<TransactionsProvider>(() => TransactionsProvider());
    }
  }

  @override
  Map<String, String> confPorts(String network) {
    switch (network) {
      case 'regtest':
        return {
          'rpc-addr': '127.0.0.1:16098',
          'net-addr': '0.0.0.0:14098',
          'mainchain-grpc-url': 'http://localhost:50051',
        };
      case 'mainnet':
        return {
          'rpc-addr': '127.0.0.1:26098',
          'net-addr': '0.0.0.0:24098',
          'mainchain-grpc-url': 'http://localhost:50051',
        };
      case 'signet':
      default:
        return {
          'rpc-addr': '127.0.0.1:6098',
          'net-addr': '0.0.0.0:4098',
          'mainchain-grpc-url': 'http://localhost:50051',
        };
    }
  }

  @override
  bool get hasConfEditor => false;

  @override
  List<String> get defaultHomepageWidgets => [
    'quote_bar',
    'balance_card',
    'transparent_receive_card',
    'shielded_receive_card',
    'send_card',
    'transactions_table',
  ];

  @override
  Map<String, HomepageWidgetInfo> get widgetCatalog => ZSideWidgetCatalog.getCatalogMap();

  @override
  String get homeTabLabel => 'Home';

  @override
  List<String> get homepageSourceFiles => const ['zside_transfer_page.dart', 'zside_bill_page.dart'];

  @override
  List<ShellTab> get tabs => const [
    ShellTab(
      label: 'Shield/Deshield',
      route: ZSideShieldDeshieldTabRoute(),
      sourceFiles: ['zside_shield_deshield_page.dart'],
    ),
    ShellTab(label: 'Melt/Cast', route: ZSideMeltCastTabRoute(), sourceFiles: ['zside_melt_cast_page.dart']),
  ];
}
