import 'package:bitwindow/routing/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

import 'test_utils.dart';

/// Fake conf provider so the routing test controls the only input the
/// DataDirGuard cares about: the backend's verdict on whether a datadir is
/// needed. No real backend / network init.
class _FakeConf extends ChangeNotifier implements BitcoinConfProvider {
  _FakeConf({required this.mustSelectDatadir});

  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_MAINNET;

  @override
  bool mustSelectDatadir;

  @override
  Future<void> loadConfig({bool isFirst = false, bool userInitiated = false}) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  // Real router, mocked data layer, assert the destination — the bb pattern.
  // Regression for "switching to Mainnet doesn't give an option for a datadir":
  // entering the app on a network that requires a datadir but has none must
  // route to DataDirSetupPage (DataDirGuard), not silently continue.
  //
  // The mode gate runs first, so the mode is already picked here. A datadir
  // asked for ahead of it would be asked for in light mode too, which stores
  // no chain at all.
  testWidgets('no datadir for mainnet routes to the datadir setup page', (tester) async {
    await registerTestDependencies();
    if (GetIt.I.isRegistered<BitcoinConfProvider>()) {
      await GetIt.I.unregister<BitcoinConfProvider>();
    }
    GetIt.I.registerSingleton<BitcoinConfProvider>(_FakeConf(mustSelectDatadir: true));
    if (GetIt.I.isRegistered<NodeModeProvider>()) {
      await GetIt.I.unregister<NodeModeProvider>();
    }
    GetIt.I.registerSingleton<NodeModeProvider>(NodeModeProvider()..mode = wmpb.NodeMode.NODE_MODE_FULL);

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
