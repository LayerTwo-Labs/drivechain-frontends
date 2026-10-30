import 'dart:async';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/shell.dart';
import 'package:truthcoin/deeplink/deep_link_service.dart';
import 'package:truthcoin/deeplink/scheme_registration.dart';
import 'package:truthcoin/gen/version.dart';
import 'package:truthcoin/providers/market_provider.dart';
import 'package:truthcoin/providers/price_history_provider.dart';
import 'package:truthcoin/providers/voting_provider.dart';
import 'package:truthcoin/routing/router.dart';
import 'package:truthcoin/widgets/homepage_widget_catalog.dart';

class TruthcoinModule extends SidechainModule {
  @override
  Sidechain get chain => Truthcoin();

  @override
  String get appName => 'Truthcoin';

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
    if (!getIt.isRegistered<TruthcoinRPC>()) {
      getIt.registerSingleton<TruthcoinRPC>(TruthcoinLive());
    }
    return getIt.get<TruthcoinRPC>();
  }

  @override
  Future<void> registerChainProviders(GetIt getIt, Directory applicationDir, Logger log) async {
    if (!getIt.isRegistered<MarketProvider>()) {
      getIt.registerLazySingleton<MarketProvider>(() => MarketProvider());
    }
    if (!getIt.isRegistered<PriceHistoryProvider>()) {
      final priceHistory = PriceHistoryProvider.inDirectory(applicationDir);
      // The cache read finishes first, so a fast market load cannot write a
      // point the read then drops.
      await priceHistory.load();
      getIt.registerSingleton<PriceHistoryProvider>(priceHistory);
    }
    if (!getIt.isRegistered<VotingProvider>()) {
      getIt.registerLazySingleton<VotingProvider>(() => VotingProvider());
    }
    // onFirstFrame starts the link stream, because a cold launch delivers the
    // first link at once and the router mounts later.
    if (!getIt.isRegistered<DeepLinkService>()) {
      getIt.registerSingleton<DeepLinkService>(DeepLinkService.live(log: log));
      unawaited(registerTruthcoinScheme(log));
    }
  }

  @override
  void onFirstFrame() {
    GetIt.I.get<DeepLinkService>().start();
  }

  @override
  Map<String, String> confPorts(String network) {
    switch (network) {
      case 'regtest':
        return {
          'rpc-addr': '127.0.0.1:16013',
          'net-addr': '0.0.0.0:14013',
          'mainchain-grpc-url': 'http://localhost:50051',
        };
      case 'mainnet':
        return {
          'rpc-addr': '127.0.0.1:26013',
          'net-addr': '0.0.0.0:24013',
          'mainchain-grpc-url': 'http://localhost:50051',
        };
      case 'signet':
      default:
        return {
          'rpc-addr': '127.0.0.1:6013',
          'net-addr': '0.0.0.0:4013',
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
    'utxo_table',
  ];

  @override
  Map<String, HomepageWidgetInfo> get widgetCatalog => TruthcoinWidgetCatalog.getCatalogMap();

  @override
  List<ShellTab> get tabs => const [
    ShellTab(label: 'Markets', route: MarketsTabRoute()),
    ShellTab(label: 'Portfolio', route: PortfolioRoute()),
    ShellTab(label: 'Voting', route: VotingDashboardRoute()),
  ];
}
