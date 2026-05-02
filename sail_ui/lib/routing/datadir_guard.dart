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

    // Only mainnet and forknet require an explicit datadir.
    if (network != BitcoinNetwork.BITCOIN_NETWORK_MAINNET && network != BitcoinNetwork.BITCOIN_NETWORK_FORKNET) {
      resolver.next(true);
      return;
    }

    // detectedDataDir is now the per-section value only — null means the
    // user hasn't picked one for this network yet.
    if (confProvider.detectedDataDir != null && confProvider.detectedDataDir!.isNotEmpty) {
      resolver.next(true);
      return;
    }

    await router.push(DataDirSetupRoute(network: network));

    final after = confProvider.detectedDataDir;
    if (after != null && after.isNotEmpty) {
      resolver.next(true);
    } else {
      resolver.next(false);
    }
  }
}
