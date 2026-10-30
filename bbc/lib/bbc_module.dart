import 'package:auto_route/auto_route.dart';
import 'package:bbc/gen/version.dart';
import 'package:bbc/routing/router.dart';
import 'package:bbc/widgets/homepage_widget_catalog.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/shell.dart';

class BbcModule extends SidechainModule {
  @override
  Sidechain get chain => Bbc();

  @override
  String get appName => 'Bbc';

  @override
  String get fullName => 'Big Block Covenant';

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
    if (!getIt.isRegistered<BbcRPC>()) {
      getIt.registerSingleton<BbcRPC>(BbcLive());
    }
    return getIt.get<BbcRPC>();
  }

  @override
  Map<String, String> confPorts(String network) {
    switch (network) {
      case 'regtest':
        return {
          'rpc-addr': '127.0.0.1:16009',
          'net-addr': '0.0.0.0:14009',
          'mainchain-grpc-url': 'http://localhost:50051',
        };
      case 'mainnet':
        return {
          'rpc-addr': '127.0.0.1:26009',
          'net-addr': '0.0.0.0:24009',
          'mainchain-grpc-url': 'http://localhost:50051',
        };
      case 'signet':
      default:
        return {
          'rpc-addr': '127.0.0.1:6009',
          'net-addr': '0.0.0.0:4009',
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
  Map<String, HomepageWidgetInfo> get widgetCatalog => BbcWidgetCatalog.getCatalogMap();
}
