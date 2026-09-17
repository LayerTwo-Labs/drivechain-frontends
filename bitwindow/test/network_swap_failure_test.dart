import 'package:bitwindow/pages/settings/network_swap_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

class _RefusingConf extends ChangeNotifier implements BitcoinConfProvider {
  @override
  BitcoinNetwork network = BitcoinNetwork.BITCOIN_NETWORK_ECASH;

  @override
  Future<void> updateNetwork(BitcoinNetwork newNetwork, {String dataDir = '', String networkId = ''}) async {
    throw Exception('could not update network: Connection refused');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  // bitwindowd owns UpdateNetwork, so a daemon that is down refuses the call and
  // the switch never runs. A completed step under the error told the user the
  // rewind landed.
  testWidgets('a refused switch leaves the step open', (tester) async {
    await registerTestDependencies();
    if (GetIt.I.isRegistered<BitcoinConfProvider>()) {
      await GetIt.I.unregister<BitcoinConfProvider>();
    }
    GetIt.I.registerSingleton<BitcoinConfProvider>(_RefusingConf());

    await tester.pumpWidget(
      SailApp(
        dense: false,
        accentColor: SailColorScheme.orange,
        log: GetIt.I.get<Logger>(),
        builder: (context) => const MaterialApp(
          home: NetworkSwapPage(
            fromNetwork: BitcoinNetwork.BITCOIN_NETWORK_ECASH,
            toNetwork: BitcoinNetwork.BITCOIN_NETWORK_ECASH,
            networkId: 'betanet',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Switch to ').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final tile = tester.widget<ProgressStepTile>(find.byType(ProgressStepTile));
    expect(tile.isCompleted, isFalse);
    expect(tile.duration, isNull);
    expect(tile.isActive, isFalse);
    expect(find.textContaining('Connection refused'), findsOneWidget);
    expect(find.text('Cancel'), findsWidgets);
  });
}
