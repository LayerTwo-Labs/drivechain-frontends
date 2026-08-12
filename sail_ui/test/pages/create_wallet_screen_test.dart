import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

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
}
