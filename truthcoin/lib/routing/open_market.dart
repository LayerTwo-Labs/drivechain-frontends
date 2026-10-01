import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:truthcoin/routing/router.dart';

/// Opens a tab of the home shell. The path starts at HomeRoute, so a cold
/// launch builds the shell and runs the startup guards first.
Future<void> openHomeTab(PageRouteInfo tab) {
  return GetIt.I.get<AppRouter>().navigate(HomeRoute(children: [tab]));
}

/// Opens a page of the Markets tab, inside the home shell. The shell owns the
/// SailScaffold and the top navigation.
Future<void> openMarketsRoute(PageRouteInfo route) {
  return openHomeTab(MarketsTabRoute(children: [route]));
}
