import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/pages/router.gr.dart' show DataDirSetupRoute;
import 'package:sail_ui/sail_ui.dart';

/// Prompts for a Bitcoin datadir when one is actually needed. Whether it is
/// depends on the wallet backend as well as the network, so the backend decides.
class DataDirGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final confProvider = GetIt.I.get<BitcoinConfProvider>();

    if (!confProvider.mustSelectDatadir) {
      resolver.next(true);
      return;
    }

    await router.push(DataDirSetupRoute(network: confProvider.network));
    await confProvider.loadConfig();

    resolver.next(!confProvider.mustSelectDatadir);
  }
}
