import 'dart:io';

import 'package:bitwindow/providers/fork_provider.dart';
import 'package:bitwindow/providers/transactions_provider.dart';
import 'package:bitwindow/widgets/fork_mode_banner.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sidechain_core/gen/wallet/v1/wallet.pb.dart' as bwpb;
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

void _registerClaimProviders() {
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
    final reader = WalletReaderProvider(Directory.systemTemp);
    reader.activeWalletId = 'w1';
    GetIt.I.registerSingleton<WalletReaderProvider>(reader);
  }
  if (!GetIt.I.isRegistered<TransactionProvider>()) {
    GetIt.I.registerSingleton<TransactionProvider>(TransactionProvider());
  }
}

void main() {
  _walletSwitchTests();

  TestWidgetsFlutterBinding.ensureInitialized();

  // The card sits above the wallet tabs and takes its natural height, so a
  // wallet with many coins used to run past the window.
  testWidgets('the claim card scrolls instead of overflowing', (tester) async {
    await registerTestDependencies();

    _registerClaimProviders();

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

  // The wallet page hands the card a bound that keeps room for the tabs. The
  // card fits whatever it gets, down to a height far below its natural one.
  testWidgets('the claim card fits the height its page allows', (tester) async {
    await registerTestDependencies();
    _registerClaimProviders();

    await tester.binding.setSurfaceSize(const Size(900, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      SailApp(
        dense: false,
        builder: (context) => MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 150),
                  child: const ForkModeBanner(),
                ),
                Expanded(child: Container()),
              ],
            ),
          ),
        ),
        initMethod: (_) async => (),
        accentColor: SailColorScheme.black,
        log: GetIt.I.get<Logger>(),
      ),
      duration: const Duration(seconds: 10),
    );
    await tester.pump();

    expect(tester.takeException(), isNull, reason: 'the card must fit a 150 pixel bound');
  });

  // main.dart lets the window go down to 400 pixels tall, which leaves the card
  // far less room than a full-size window.
  testWidgets('the claim card fits the shortest window', (tester) async {
    await registerTestDependencies();
    _registerClaimProviders();

    await tester.binding.setSurfaceSize(const Size(900, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      SailApp(
        dense: false,
        builder: (context) => MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const ForkModeBanner(),
                Expanded(child: Container()),
              ],
            ),
          ),
        ),
        initMethod: (_) async => (),
        accentColor: SailColorScheme.black,
        log: GetIt.I.get<Logger>(),
      ),
      duration: const Duration(seconds: 10),
    );
    await tester.pump();

    expect(tester.takeException(), isNull, reason: 'the card must fit a 400 pixel tall window');
  });
}

void _walletSwitchTests() {
  // The card spends the wallet it holds, so it carries that wallet's key. A
  // switch then builds a new card instead of keeping the old one.
  testWidgets('the card is keyed by the wallet it acts for', (tester) async {
    await registerTestDependencies();
    _registerClaimProviders();

    await tester.pumpSailPage(
      Column(
        children: [
          const ForkModeBanner(),
          Expanded(child: Container()),
        ],
      ),
    );

    final card = tester.widget(find.byType(SailCard).first);
    expect(find.byKey(const ValueKey('w1')), findsOneWidget);
    expect(card, isNotNull);
  });
}
