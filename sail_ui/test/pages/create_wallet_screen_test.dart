import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sidechain_core/gen/walletmanager/v1/walletmanager.pb.dart' as wmpb;

/// Only the "does a wallet already exist" probe is faked — everything else is
/// the real page, so the widget tree under test is the one that ships.
class _FakeWriter extends WalletWriterProvider {
  _FakeWriter() : super(bitwindowAppDir: Directory.systemTemp);

  @override
  Future<bool> hasExistingWallet() async => false;
}

Future<void> _pumpPage(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(1440, 1024));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: const SailCreateWalletPage(homeRoute: PageRouteInfo<void>('TestHome')),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    GetIt.I.registerSingleton<Logger>(Logger());
    GetIt.I.registerSingleton<WalletReaderProvider>(WalletReaderProvider(Directory.systemTemp));
    GetIt.I.registerSingleton<WalletWriterProvider>(_FakeWriter());
    // Full mode, so both wallet backends are on offer. Light mode runs no
    // local node, so it shows electrum alone and no cards at all.
    GetIt.I.registerSingleton<NodeModeProvider>(NodeModeProvider()..mode = wmpb.NodeMode.NODE_MODE_FULL);
  });

  tearDown(() async => GetIt.I.reset());

  // The setup screen scrolls, so its height is unbounded. A row of equal-height
  // actions has to bring its own intrinsic height or layout throws
  // "BoxConstraints forces an infinite height" and the screen never renders.
  testWidgets('the setup screen lays out both wallet actions', (tester) async {
    await _pumpPage(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Create a new wallet'), findsOneWidget);
    expect(find.text('Paste a seed phrase'), findsOneWidget);
  });

  // The paste button is the only way to reach the seed field, and the restore
  // screen scrolls too — so it carries the same unbounded-height hazard.
  testWidgets('paste opens a restore screen that lays out', (tester) async {
    await _pumpPage(tester);

    await tester.tap(find.text('Paste a seed phrase'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Paste your seed phrase'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'Paste your seed phrase — 12 or 24 words, separated by spaces'),
      findsOneWidget,
    );
  });

  // Electrum takes a passphrase like every other backend; the field used to be
  // disabled there, which made a typed value unclearable and every restore fail.
  testWidgets('the passphrase field stays usable on electrum', (tester) async {
    await _pumpPage(tester);
    await tester.tap(find.text('Paste a seed phrase'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Optional passphrase'), 'hunter2');
    await tester.tap(find.text('Electrum'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('hunter2'), findsOneWidget, reason: 'switching provider must not discard what was typed');
  });

  // Both actions are equally weighted, which is the point of the row.
  testWidgets('the two actions are the same height', (tester) async {
    await _pumpPage(tester);

    final generate = tester.getSize(
      find.ancestor(of: find.text('Create a new wallet'), matching: find.byType(TextButton)),
    );
    final paste = tester.getSize(
      find.ancestor(of: find.text('Paste a seed phrase'), matching: find.byType(TextButton)),
    );
    expect(generate.height, paste.height);
  });

  // Thunder, BitNames and BitAssets open this same page and register no node
  // mode of their own. Reading one would throw before a user without a wallet
  // could finish setup.
  testWidgets('the page lays out for an app that registers no node mode', (tester) async {
    GetIt.I.unregister<NodeModeProvider>();

    await _pumpPage(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Create a new wallet'), findsOneWidget);
  });
}
