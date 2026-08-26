import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/router.gr.dart' show DataDirSetupRoute;
import 'package:sail_ui/sail_ui.dart';

/// Prompts for a Bitcoin datadir when one is actually needed. Whether it is
/// depends on the wallet backend as well as the network, so the backend decides.
class DataDirGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final confProvider = GetIt.I.get<BitcoinConfProvider>();

    // The node mode gate runs first and decides whether a local node runs at
    // all, so a polled value can predate the mode the user just picked.
    await confProvider.loadConfig();
    if (!confProvider.mustSelectDatadir) {
      resolver.next(true);
      return;
    }

    await router.push(DataDirSetupRoute(network: confProvider.network));
    await confProvider.loadConfig();

    final ready = !confProvider.mustSelectDatadir;
    if (ready) {
      // The backend refuses to boot without a directory, so the mode choice
      // started nothing. Now it can.
      await _startLocalBackends();
    }
    resolver.next(ready);
  }

  Future<void> _startLocalBackends() async {
    if (!NodeModeProvider.runsLocalBackends) {
      return;
    }
    try {
      await GetIt.I.get<OrchestratorRPC>().startWithL1('enforcer');
    } catch (e) {
      GetIt.I.get<Logger>().w('DataDirGuard: could not start the Bitcoin backends: $e');
    }
  }
}
