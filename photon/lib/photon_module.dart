import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:photon/gen/version.dart';
import 'package:photon/routing/router.dart';
import 'package:photon/widgets/homepage_widget_catalog.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/shell/shell.dart';

class PhotonModule extends SidechainModule {
  @override
  Sidechain get chain => Photon();

  @override
  String get appName => 'Photon';

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
    if (!getIt.isRegistered<PhotonRPC>()) {
      getIt.registerSingleton<PhotonRPC>(PhotonLive());
    }
    return getIt.get<PhotonRPC>();
  }

  @override
  Map<String, String> confPorts(String network) {
    switch (network) {
      case 'regtest':
        return {
          'rpc-addr': '127.0.0.1:16099',
          'net-addr': '0.0.0.0:14099',
          'mainchain-grpc-url': 'http://localhost:50051',
        };
      case 'mainnet':
        return {
          'rpc-addr': '127.0.0.1:26099',
          'net-addr': '0.0.0.0:24099',
          'mainchain-grpc-url': 'http://localhost:50051',
        };
      case 'signet':
      default:
        return {
          'rpc-addr': '127.0.0.1:6099',
          'net-addr': '0.0.0.0:4099',
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
  Map<String, HomepageWidgetInfo> get widgetCatalog => PhotonWidgetCatalog.getCatalogMap();

  @override
  List<ShellTab> get tabs => const [
    ShellTab(label: 'Block Explorer', route: BlockExplorerRoute()),
    ShellTab(label: 'Mempool', route: MempoolExplorerRoute(), commandLabel: 'Mempool Explorer'),
    ShellTab(label: 'Withdrawals', route: WithdrawalsRoute()),
    ShellTab(label: 'Tx Builder', route: TransactionBuilderRoute(), commandLabel: 'Transaction Builder'),
  ];
}
