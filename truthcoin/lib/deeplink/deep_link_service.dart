import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:auto_route/auto_route.dart';
import 'package:logger/logger.dart';
import 'package:truthcoin/deeplink/truthcoin_link.dart';
import 'package:truthcoin/routing/open_market.dart';
import 'package:truthcoin/routing/router.dart';

/// Opens the page a truthcoin:// link names. The desktop app owns every write,
/// so the web page hands a market over with such a link.
class DeepLinkService {
  /// Opens a page of the Markets tab, inside the guarded home shell. A cold
  /// launch runs the network, wallet and password guards once there, so the
  /// market page never opens a second unlock prompt.
  final Future<void> Function(PageRouteInfo route) open;
  final Logger log;
  final Stream<Uri> links;

  StreamSubscription<Uri>? _subscription;

  DeepLinkService({
    required this.open,
    required this.log,
    required this.links,
  });

  factory DeepLinkService.live({required Logger log}) {
    return DeepLinkService(
      open: openMarketsRoute,
      log: log,
      links: AppLinks().uriLinkStream,
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
        unawaited(open(MarketDetailRoute(marketId: marketId)));
      case MarketListLink():
        log.i('a deep link opens the market list');
        unawaited(open(const MarketExplorerRoute()));
    }
  }
}
