import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

/// Fake conf provider so the routing test controls the only input the
/// DataDirGuard cares about: which network is active and whether it already
/// has a datadir. No real backend / network init.
class _FakeConf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_MAINNET;

  @override
  bool networkRequiresDataDir(BitcoinNetwork n) =>
      n == BitcoinNetwork.BITCOIN_NETWORK_MAINNET ||
      n == BitcoinNetwork.BITCOIN_NETWORK_FORKNET ||
      n == BitcoinNetwork.BITCOIN_NETWORK_DRYNET;

  @override
  bool hasDataDirFor(BitcoinNetwork n) => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  // Real router, mocked data layer, assert the destination — the bb pattern.
  // Regression for "switching to Mainnet doesn't give an option for a datadir":
  // entering the app on a network that requires a datadir but has none must
  // route to DataDirSetupPage (DataDirGuard), not silently continue.
  testWidgets('no datadir for mainnet routes to the datadir setup page', (tester) async {
    await registerTestDependencies();
    if (GetIt.I.isRegistered<BitcoinConfProvider>()) {
      await GetIt.I.unregister<BitcoinConfProvider>();
    }
    GetIt.I.registerSingleton<BitcoinConfProvider>(_FakeConf());

    final router = AppRouter();
    await tester.pumpWidget(
      SailApp(
        dense: false,
        builder: (context) => MaterialApp.router(routerConfig: router.config()),
        initMethod: (_) async => (),
        accentColor: SailColorScheme.black,
        log: GetIt.I.get<Logger>(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(DataDirSetupPage), findsOneWidget);
  });
}
