import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:auto_route/auto_route.dart';
import 'package:logger/logger.dart';
import 'package:truthcoin/deeplink/truthcoin_link.dart';
import 'package:truthcoin/routing/router.dart';

/// Opens the page a truthcoin:// link names. The desktop app owns every write,
/// so the web page hands a market over with such a link.
class DeepLinkService {
  /// Takes the app to the guarded home route. A cold launch runs the network,
  /// wallet and password guards once here, so the market page never opens a
  /// second unlock prompt beside the one the home route opens.
  final Future<void> Function(PageRouteInfo route) navigate;

  final Future<void> Function(PageRouteInfo route) push;
  final Logger log;
  final Stream<Uri> links;

  StreamSubscription<Uri>? _subscription;

  DeepLinkService({
    required this.navigate,
    required this.push,
    required this.log,
    required this.links,
  });

  factory DeepLinkService.live({required AppRouter router, required Logger log}) {
    final appLinks = AppLinks();
    return DeepLinkService(
      navigate: (route) => router.navigate(route),
      push: (route) => router.push(route),
      log: log,
      links: appLinks.uriLinkStream,
    );
  }

  void start() {
    _subscription ??= links.listen(
      handle,
      onError: (Object error) => log.w('the deep link stream failed: $error'),
    );
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  /// Takes one link. A link the app does not own leaves the screen alone.
  void handle(Uri uri) {
    final link = parseTruthcoinLink(uri);
    if (link == null) {
      log.d('the app ignores the link $uri');
      return;
    }

    switch (link) {
      case MarketLink(:final marketId):
        log.i('a deep link opens the market $marketId');
        unawaited(_open(MarketDetailRoute(marketId: marketId)));
      case MarketListLink():
        log.i('a deep link opens the market list');
        unawaited(_open(const MarketExplorerRoute()));
    }
  }

  Future<void> _open(PageRouteInfo route) async {
    await navigate(const HomeRoute());
    await push(route);
  }
}
