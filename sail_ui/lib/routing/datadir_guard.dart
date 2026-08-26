import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/pages/router.gr.dart' show DataDirSetupRoute;
import 'package:sail_ui/sail_ui.dart';

/// Makes sure the running network has a data directory. Returns false when the
/// user backs out of the picker.
///
/// The orchestrator refuses to start L1 without a directory, so every path onto
/// full mode runs this: the guard below on the way into the app, and the
/// Settings toggle, which the guards never re-run for. It starts the backends
/// only when it supplies the missing directory, because that is the one case
/// where nothing else did: a network that already has one is booted by
/// bitwindow's startup or by NodeModeProvider.select. Two dispatches race each
/// other's pre-start checks, and the loser reports a startup failure.
Future<bool> ensureDataDirThenStartBackends(StackRouter router) async {
  final conf = GetIt.I.get<BitcoinConfProvider>();

  // The node mode decides whether a local node runs at all, and it is picked
  // one step earlier, so a polled value can predate it.
  await conf.loadConfig();
  if (!conf.mustSelectDatadir) {
    return true;
  }

  await router.push(DataDirSetupRoute(network: conf.network));
  await conf.loadConfig();
  if (conf.mustSelectDatadir) {
    return false;
  }

  if (!NodeModeProvider.runsLocalBackends) {
    return true;
  }
  try {
    await GetIt.I.get<OrchestratorRPC>().startWithL1('enforcer');
  } catch (e) {
    GetIt.I.get<Logger>().w('could not start the Bitcoin backends: $e');
  }
  return true;
}

/// Prompts for a Bitcoin datadir when one is actually needed. Whether it is
/// depends on the wallet backend as well as the network, so the backend decides.
class DataDirGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    resolver.next(await ensureDataDirThenStartBackends(router));
  }
}
