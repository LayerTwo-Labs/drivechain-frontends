// Drives BitWindow on a phone through the hot paths against the regtest stack of
// scripts/phone-regtest.sh. Run it on a fresh install; see integration_test/phone_regtest/README.md.
import 'package:bitwindow/main.dart' as app;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'phone_regtest/regtest.dart';
import 'phone_regtest/ui.dart';

// The Sidechains overview keeps its desktop columns on a phone. Its phone layout waits for a design.
const _knownLayoutFaults = ['side-nav Sidechains'];

final _bcrt = RegExp(r'^bcrt1[0-9a-z]{20,}$');

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a phone wallet receives, sends and confirms on regtest', (tester) async {
    final regtest = RegtestControl.fromDefine();
    final ui = PhoneUi(tester, binding);
    final testHandler = FlutterError.onError;
    final testErrorWidget = ErrorWidget.builder;
    try {
      await _hotPaths(tester, ui, regtest);
    } catch (_) {
      await ui.shot('failure');
      rethrow;
    } finally {
      FlutterError.onError = testHandler;
      ErrorWidget.builder = testErrorWidget;
    }
    expect(
      ui.layoutErrors.where((e) => !_knownLayoutFaults.any(e.startsWith)),
      isEmpty,
      reason: 'layout overflows on a phone',
    );
  }, timeout: const Timeout(Duration(minutes: 30)));
}

Future<void> _hotPaths(WidgetTester tester, PhoneUi ui, RegtestControl regtest) async {
  app.main([]);
  await ui.waitFor(find.text('No wallet'), timeout: const Duration(minutes: 3), reason: 'the empty first start');
  await ui.settle(const Duration(seconds: 2));
  ui.watchLayoutErrors();

  ui.step('first-start');
  await ui.waitFor(find.text('All binaries connected'), timeout: const Duration(minutes: 4));
  await ui.shot('first-start');

  ui.step('create-wallet');
  await ui.tap(ui.topmost(find.text('No wallet')));
  await ui.tapText('Generate wallet');
  await ui.waitFor(find.text('Continue'));
  await ui.shot('entropy');
  await ui.tapText('Continue');
  await ui.tapText('Skip and create wallet');
  await ui.tapText('Create without backup');
  await ui.waitFor(find.text('wallet1'), timeout: const Duration(minutes: 2));
  await ui.shot('overview-with-wallet');

  ui.step('receive');
  await ui.navigate('Wallet');
  await ui.tapText('Receive');
  await ui.waitUntil(() => ui.fieldText(_bcrt).isNotEmpty, 'a receive address');
  final address = ui.fieldText(_bcrt);
  await ui.shot('receive');

  await regtest.send(address, '2');
  await ui.waitFor(find.textContaining('2.0000'), timeout: const Duration(minutes: 3), reason: 'the unconfirmed 2 BTC');
  await ui.shot('receive-unconfirmed');
  await regtest.mine(1);
  await ui.tapText('Overview');
  await ui.waitFor(find.text('Confirmed'), timeout: const Duration(minutes: 2), reason: 'a confirmed receive');
  await ui.shot('receive-confirmed');

  ui.step('send');
  final external = await regtest.newAddress();
  await ui.tapText('Send');
  await ui.enter(find.textContaining('Enter a single L1'), external);
  await ui.enter(find.text('0.00'), '0.5');
  await ui.settle(const Duration(seconds: 3));
  await ui.shot('send-form');
  await ui.tap(find.text('Create Transaction').last);
  await ui.waitFor(find.text('Broadcast'), reason: 'the transaction summary');
  await ui.shot('send-summary');
  await ui.waitFor(find.text('Broadcast'), reason: 'the transaction summary');
  await ui.settle(const Duration(seconds: 3));
  await ui.tapText('Broadcast');
  await ui.waitUntilAsync(() async => (await regtest.mempool()).length == 1, 'the broadcast in the mempool');
  await ui.shot('send-broadcast');
  await regtest.mine(1);
  await ui.tapText('Overview');
  await ui.waitUntil(
    () => find.text('Confirmed').evaluate().length >= 2,
    'two confirmed rows',
    timeout: const Duration(minutes: 2),
  );
  await ui.shot('send-confirmed');

  ui.step('utxos');
  await ui.tapText('UTXOs');
  await ui.settle(const Duration(seconds: 2));
  await ui.shot('utxos');

  ui.step('side-nav');
  await ui.openSideNav();
  await ui.shot('side-nav');
  for (final page in ['Sidechains', 'Learn', 'Console', 'Chat', 'Overview']) {
    ui.step('side-nav $page');
    await ui.tapText(page);
    await ui.settle(const Duration(seconds: 2));
    await ui.shot('page-${page.toLowerCase()}');
    if (page != 'Overview') {
      await ui.openSideNav();
    }
  }

  ui.step('bump-fee');
  await ui.navigate('Wallet');
  await ui.tapText('Send');
  await ui.tap(ui.topmost(find.text('Create Transaction')));
  await ui.enter(find.textContaining('Enter a single L1'), await regtest.newAddress());
  await ui.enter(find.text('0.00'), '0.1');
  await ui.settle(const Duration(seconds: 3));
  await ui.tap(find.text('Create Transaction').last);
  await ui.waitFor(find.text('Broadcast'), reason: 'the transaction summary');
  await ui.settle(const Duration(seconds: 3));
  await ui.tapText('Broadcast');
  await ui.waitUntilAsync(() async => (await regtest.mempool()).length == 1, 'the second broadcast in the mempool');
  final sent = await regtest.mempool();
  await ui.tapText('Overview');
  await ui.waitFor(find.text('Unconfirmed'), timeout: const Duration(minutes: 2));
  await ui.longPressUntil(find.text('Unconfirmed'), find.text('Bump fee'));
  await ui.shot('history-row-menu');
  await ui.tapText('Bump fee');
  await ui.waitFor(find.text('Bump the fee'));
  await ui.shot('bump-fee');
  await ui.tapText('Replace transaction');
  await ui.waitUntilAsync(
    () async => (await regtest.mempool()).single != sent.single,
    'the replacement in the mempool',
  );
  await ui.waitUntil(() => find.text('Bump the fee').evaluate().isEmpty, 'the bump fee sheet to close');

  await regtest.mine(1);
  await ui.waitUntil(
    () => find.text('Confirmed').evaluate().length >= 3,
    'the bumped send to confirm',
    timeout: const Duration(minutes: 2),
  );
  await ui.shot('bump-fee-confirmed');
}
