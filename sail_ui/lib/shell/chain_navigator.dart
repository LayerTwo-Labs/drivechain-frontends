import 'package:auto_route/auto_route.dart';
import 'package:sail_ui/pages/router.gr.dart';

/// Moves between the pages of the open sidechain, in its own app or inside BitWindow.
abstract class ChainNavigator {
  /// Opens [tab], a tab route of the chain, with any child routes it holds.
  Future<void> openTab(PageRouteInfo tab);

  /// Puts [route], a page of the chain, on top of the current page.
  Future<void> push(PageRouteInfo route);

  /// Closes the top page or dialog.
  Future<void> pop();
}

/// The navigator of a sidechain app, on the router of the app.
class ShellChainNavigator implements ChainNavigator {
  final RootStackRouter router;

  const ShellChainNavigator(this.router);

  @override
  Future<void> openTab(PageRouteInfo tab) => router.navigate(SidechainHomeRoute(children: [tab]));

  @override
  Future<void> push(PageRouteInfo route) => router.push(route);

  @override
  Future<void> pop() => router.maybePop();
}
