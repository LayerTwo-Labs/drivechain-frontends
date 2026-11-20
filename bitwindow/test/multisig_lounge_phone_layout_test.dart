import 'package:bitwindow/pages/wallet/wallet_multisig_lounge.dart';
import 'package:bitwindow/providers/hd_wallet_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

class _FakeHd extends ChangeNotifier implements HDWalletProvider {
  @override
  bool get isInitialized => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _pump(WidgetTester tester, {required bool phone}) async {
  SailStyleValues.phoneLayoutOverride = phone;
  await tester.pumpSailPage(const MultisigLoungeTab());
  await tester.binding.setSurfaceSize(phone ? const Size(390, 1400) : const Size(1200, 1000));
  await tester.pump();
  await tester.pump();
}

void main() {
  setUpAll(loadBundledFonts);

  setUp(() async {
    await GetIt.I.reset();
    await registerTestDependencies();
    GetIt.I.registerSingleton<HDWalletProvider>(_FakeHd());
  });

  tearDown(() async {
    SailStyleValues.phoneLayoutOverride = null;
    await GetIt.I.reset();
  });

  testWidgets('on a phone the group tools are a two by two grid', (tester) async {
    await _pump(tester, phone: true);

    expect(tester.takeException(), isNull);
    final create = tester.getRect(find.widgetWithText(SailButton, 'Create New Group'));
    final fund = tester.getRect(find.widgetWithText(SailButton, 'Fund Group'));
    final import = tester.getRect(find.widgetWithText(SailButton, 'Import from TXID'));
    final key = tester.getRect(find.widgetWithText(SailButton, 'Get Key'));
    expect(fund.center.dy, closeTo(create.center.dy, 1));
    expect(fund.left, greaterThan(create.right));
    expect(import.top, greaterThan(create.bottom));
    expect(import.left, closeTo(create.left, 1));
    expect(key.left, closeTo(fund.left, 1));
    expect(create.width, closeTo(fund.width, 1));
  });

  testWidgets('on a phone Create Transaction spans the card and the other two share a row', (tester) async {
    await _pump(tester, phone: true);

    final card = tester.getRect(find.ancestor(of: find.text('Transaction Tools'), matching: find.byType(SailCard)));
    final create = tester.getRect(find.widgetWithText(SailButton, 'Create Transaction'));
    final psbt = tester.getRect(find.widgetWithText(SailButton, 'Import PSBT'));
    final combine = tester.getRect(find.widgetWithText(SailButton, 'Combine & Broadcast'));
    expect(create.width, closeTo(card.width - 32 - 2, 2));
    expect(psbt.top, greaterThan(create.bottom));
    expect(combine.center.dy, closeTo(psbt.center.dy, 1));
    expect(combine.right, closeTo(create.right, 1));
  });

  testWidgets('on a phone the cards stack: groups, group tools, transactions, transaction tools', (tester) async {
    await _pump(tester, phone: true);

    final order = [
      'Multisig Groups',
      'Group Tools',
      'Multisig Transactions',
      'Transaction Tools',
    ].map((t) => tester.getRect(find.text(t)).top).toList();
    expect(order, orderedEquals([...order]..sort()));
    expect(tester.getRect(find.text('Group Tools')).left, tester.getRect(find.text('Multisig Groups')).left);
  });

  testWidgets('the desktop keeps the tools beside the tables', (tester) async {
    await _pump(tester, phone: false);

    final groups = tester.getRect(find.text('Multisig Groups'));
    final tools = tester.getRect(find.text('Group Tools'));
    expect(tools.left, greaterThan(groups.right));
  });
}
