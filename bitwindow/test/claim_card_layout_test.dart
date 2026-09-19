import 'dart:io';

import 'package:bitwindow/providers/fork_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/widgets/fork_mode_banner.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart' as bwpb;
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

import 'test_utils.dart';

final _fork = ForkProvider()..hasFundsToClaim = true;

WalletClaim _claim({int coins = 1, wmpb.MultisigInfo? multisig}) => WalletClaim(
  walletId: 'w1',
  walletName: 'Main wallet',
  claimableSats: coins * 50000,
  multisig: multisig,
  utxos: List.generate(
    coins,
    (i) => bwpb.UnspentOutput(output: 'coin$i:0', valueSats: Int64(50000), height: 963650 + i),
  ),
);

Future<void> _pumpCard(WidgetTester tester, WalletClaim claim) async {
  await registerTestDependencies();
  _fork.claims = [claim];
  if (!GetIt.I.isRegistered<ForkProvider>()) {
    GetIt.I.registerSingleton<ForkProvider>(_fork);
  }
  if (!GetIt.I.isRegistered<WalletReaderProvider>()) {
    GetIt.I.registerSingleton<WalletReaderProvider>(WalletReaderProvider(Directory.systemTemp)..activeWalletId = 'w1');
  }
  if (!GetIt.I.isRegistered<TransactionProvider>()) {
    GetIt.I.registerSingleton<TransactionProvider>(TransactionProvider());
  }
  await tester.pumpSailPage(
    Column(
      children: [
        ForkModeBanner(key: UniqueKey()),
        Expanded(child: Container()),
      ],
    ),
  );
}

void main() {
  testWidgets('the card shows the coins, the output and the total', (tester) async {
    await _pumpCard(tester, _claim());

    expect(tester.takeException(), isNull);
    expect(find.text('Main wallet'), findsOneWidget);
    expect(find.text('1 coin'), findsOneWidget);
    expect(find.text('Coins to split'), findsOneWidget);
    expect(find.text('Transaction outputs'), findsOneWidget);
    expect(find.text('To Main wallet'), findsOneWidget);
    expect(find.text('A fresh address'), findsOneWidget);
    expect(find.text('${ForkProvider.sweepFeeRateSatPerVbyte} sat/vB, from the output'), findsOneWidget);
    expect(find.text('Total to split'), findsOneWidget);
    expect(find.text('Signatures'), findsNothing);
  });

  testWidgets('the card fits the narrowest window', (tester) async {
    await _pumpCard(tester, _claim());
    await tester.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('the checkbox keeps clear of the amount', (tester) async {
    await _pumpCard(tester, _claim());

    final checkbox = tester.getRect(find.byType(SailCheckbox));
    final amount = tester.getRect(find.text('Amount'));
    expect(checkbox.right, lessThan(amount.left));
  });

  testWidgets('a multisig claim shows its policy and the signatures', (tester) async {
    await _pumpCard(tester, _claim(coins: 2, multisig: wmpb.MultisigInfo(m: 2, n: 3)));

    expect(tester.takeException(), isNull);
    expect(find.text('2 coins · 2-of-3 multisig'), findsOneWidget);
    expect(find.text('A fresh address · 2-of-3 multisig'), findsOneWidget);
    expect(find.text('2 of 3 keys'), findsOneWidget);
  });
}
