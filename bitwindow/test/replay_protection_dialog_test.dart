import 'package:bitwindow/widgets/replay_protection_dialog.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

import 'test_utils.dart';

UnspentOutput coin(String address, int sats) =>
    UnspentOutput(output: '$address:0', address: address, valueSats: Int64(sats));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  setUp(() async {
    await GetIt.I.reset();
    await registerTestDependencies();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  Future<ReplayChoice?> openDialog(WidgetTester tester, List<UnspentOutput> coins) async {
    ReplayChoice? choice;
    await tester.pumpSailPage(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async => choice = await askReplayProtection(context, coins: coins),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return choice;
  }

  testWidgets('the dialog names every coin that exists on both chains', (tester) async {
    await openDialog(tester, [
      coin('tb1qm4v000000000000000008xr2', 30000000),
      coin('tb1qk9d000000000000000003ptu', 10000000),
    ]);

    expect(find.text('These coins exist on both chains'), findsOneWidget);
    expect(find.text('tb1qm4…8xr2'), findsOneWidget);
    expect(find.text('tb1qk9…3ptu'), findsOneWidget);
  });

  testWidgets('one coin reads in the singular', (tester) async {
    await openDialog(tester, [coin('tb1qm4v000000000000000008xr2', 30000000)]);

    expect(find.text('This coin exists on both chains'), findsOneWidget);
  });

  testWidgets('the protected send is the primary action', (tester) async {
    await openDialog(tester, [coin('tb1qm4v000000000000000008xr2', 30000000)]);

    expect(find.text('Cancel'), findsWidgets);
    expect(find.text('Send without protection'), findsWidgets);
    expect(find.text('Enable replay protection'), findsWidgets);
  });
}
