import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/pages/router.gr.dart';
import 'package:sail_ui/sail_ui.dart';

/// Guard that blocks mainnet/testnet for sidechain apps.
/// Sidechains only support networks with drivechain enabled:
/// - Forknet (drivechain testnet)
/// - Signet
/// - Regtest
///
/// Redirects to NetworkSwitchPage if on an unsupported network.
class NetworkGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final confProvider = GetIt.I.get<BitcoinConfProvider>();

    // Allow navigation if network supports sidechains
    if (confProvider.networkSupportsSidechains) {
      resolver.next(true);
      return;
    }

    // Block and show network switch page
    await router.push(NetworkSwitchRoute());

    // Check if user switched to a valid network
    if (confProvider.networkSupportsSidechains) {
      resolver.next(true);
    } else {
      resolver.next(false);
    }
  }
}
