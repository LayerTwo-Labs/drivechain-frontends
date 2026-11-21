import 'package:bitwindow/widgets/replay_protection_dialog.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart';

import 'test_utils.dart';

UnspentOutput coin(String address, int sats) =>
    UnspentOutput(output: '$address:0', address: address, valueSats: Int64(sats));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadBundledFonts);

  setUp(() async {
    await GetIt.I.reset();
    await registerTestDependencies();
  });

  tearDown(() async {
    SailStyleValues.phoneLayoutOverride = null;
    await GetIt.I.reset();
  });

  Finder button(String label) => find.byWidgetPredicate((w) => w is SailButton && w.label == label);

  Future<ReplayChoice?> openDialog(WidgetTester tester, List<UnspentOutput> coins, {bool coinsKnown = true}) async {
    ReplayChoice? choice;
    await tester.pumpSailPage(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async => choice = await askReplayProtection(context, coins: coins, coinsKnown: coinsKnown),
          child: const Text('open'),
        ),
      ),
    );
    if (SailStyleValues.phoneLayoutOverride == true) {
      await tester.usePhoneSize();
    }
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

  testWidgets('an unread wallet raises the prompt without a coin list', (tester) async {
    await openDialog(tester, [], coinsKnown: false);

    expect(find.text('These coins exist on both chains'), findsOneWidget);
    expect(find.text('Coins on both chains'), findsNothing);
    expect(find.text('Enable replay protection'), findsWidgets);
  });

  testWidgets('the dialog hugs its content instead of filling the screen', (tester) async {
    await openDialog(tester, [coin('tb1qm4v000000000000000008xr2', 30000000)]);

    final card = tester.getSize(find.byType(SailCard).first);
    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    expect(card.height, lessThan(screen.height * 0.7));
  });

  testWidgets('on a phone Enable, Send without and Cancel stack in that order', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await openDialog(tester, [coin('tb1qm4v000000000000000008xr2', 30000000)]);

    final protect = tester.getRect(button('Enable replay protection'));
    final plain = tester.getRect(button('Send without protection'));
    final cancel = tester.getRect(button('Cancel'));
    expect(plain.top, greaterThan(protect.bottom - 1));
    expect(cancel.top, greaterThan(plain.bottom - 1));
    expect(plain.width, closeTo(protect.width, 1));
    expect(cancel.center.dx, closeTo(protect.center.dx, 1));
  });

  testWidgets('on a desktop the three answers share one row', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await openDialog(tester, [coin('tb1qm4v000000000000000008xr2', 30000000)]);

    final protect = tester.getRect(button('Enable replay protection'));
    final cancel = tester.getRect(button('Cancel'));
    expect(cancel.center.dy, closeTo(protect.center.dy, 1));
    expect(cancel.right, lessThan(protect.left));
  });
}
