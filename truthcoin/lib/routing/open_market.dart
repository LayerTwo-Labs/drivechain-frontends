import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/shell/chain_navigator.dart';
import 'package:truthcoin/routing/router.dart';

/// Opens a tab of the chain shell, in the app or inside BitWindow.
Future<void> openHomeTab(PageRouteInfo tab) {
  return GetIt.I.get<ChainNavigator>().openTab(tab);
}

/// Opens a page of the Markets tab, inside the home shell. The shell owns the
/// SailScaffold and the top navigation.
Future<void> openMarketsRoute(PageRouteInfo route) {
  return openHomeTab(MarketsTabRoute(children: [route]));
}
