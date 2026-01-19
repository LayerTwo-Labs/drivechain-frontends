import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/pages/router.gr.dart' show DataDirSetupRoute;
import 'package:sail_ui/sail_ui.dart';

/// Guard that checks if data directory is configured for mainnet/forknet.
/// If not configured, navigates to setup page before allowing navigation.
class DataDirGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final confProvider = GetIt.I.get<BitcoinConfProvider>();
    final network = confProvider.network;

    // Only check for mainnet and forknet - they require explicit datadir
    if (network != BitcoinNetwork.BITCOIN_NETWORK_MAINNET && network != BitcoinNetwork.BITCOIN_NETWORK_FORKNET) {
      resolver.next(true);
      return;
    }

    // Check if datadir is configured
    final dataDir = confProvider.getDataDirForNetwork(network);
    if (dataDir != null && dataDir.isNotEmpty) {
      resolver.next(true);
      return;
    }

    // Datadir not configured - show setup page
    await router.push(DataDirSetupRoute());

    // Check if datadir was configured
    final newDataDir = confProvider.getDataDirForNetwork(network);
    if (newDataDir != null && newDataDir.isNotEmpty) {
      resolver.next(true);
    } else {
      resolver.next(false);
    }
  }
}
