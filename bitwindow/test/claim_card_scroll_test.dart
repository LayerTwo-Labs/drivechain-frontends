import 'dart:io';

import 'package:bitwindow/providers/fork_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/widgets/fork_mode_banner.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart' as bwpb;
import 'package:sidechain_core/sidechain_core.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The card sits above the wallet tabs and takes its natural height, so a
  // wallet with many coins used to run past the window.
  testWidgets('the claim card scrolls instead of overflowing', (tester) async {
    await registerTestDependencies();

    final fork = ForkProvider();
    fork.hasFundsToClaim = true;
    fork.claims = [
      WalletClaim(
        walletId: 'w1',
        walletName: 'bitkey',
        claimableSats: 4000,
        utxos: List.generate(
          40,
          (i) => bwpb.UnspentOutput(output: 'coin$i:0', valueSats: Int64(100), height: 900000 + i),
        ),
      ),
    ];

    if (!GetIt.I.isRegistered<ForkProvider>()) {
      GetIt.I.registerSingleton<ForkProvider>(fork);
    }
    if (!GetIt.I.isRegistered<WalletReaderProvider>()) {
      GetIt.I.registerSingleton<WalletReaderProvider>(WalletReaderProvider(Directory.systemTemp));
    }
    if (!GetIt.I.isRegistered<TransactionProvider>()) {
      GetIt.I.registerSingleton<TransactionProvider>(TransactionProvider());
    }

    await tester.pumpSailPage(
      Column(
        children: [
          const ForkModeBanner(),
          Expanded(child: Container()),
        ],
      ),
    );

    expect(tester.takeException(), isNull, reason: '40 coins must not overflow the card');
    expect(find.byType(SingleChildScrollView), findsWidgets);
  });
}
