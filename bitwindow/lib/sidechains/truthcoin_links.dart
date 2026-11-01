import 'dart:async';

import 'package:bitwindow/pages/sidechain_host_page.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:truthcoin/deeplink/deep_link_service.dart';
import 'package:truthcoin/deeplink/scheme_registration.dart';

const bitwindowSchemeHost = SchemeHost(
  desktopFile: 'bitwindow.desktop',
  name: 'BitWindow',
  comment: 'Drivechain wallet and sidechains',
  wmClass: 'bitwindow',
);

/// Opens truthcoin:// links in the Truthcoin view of BitWindow. With [claimScheme],
/// BitWindow also tells Windows and Linux that it opens the scheme.
DeepLinkService startTruthcoinLinks(Logger log, {required bool claimScheme}) {
  if (claimScheme) {
    unawaited(registerTruthcoinScheme(log, host: bitwindowSchemeHost));
  }
  return DeepLinkService.live(log: log, navigator: HostChainNavigator(Truthcoin()))..start();
}
