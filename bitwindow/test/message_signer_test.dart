import 'dart:io';

import 'package:bitwindow/pages/message_signer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/api_mock.dart';
import 'test_utils.dart';

Future<void> _pumpSigner(WidgetTester tester, Size windowSize) async {
  await registerTestDependencies();
  if (!GetIt.I.isRegistered<WalletReaderProvider>()) {
    GetIt.I.registerSingleton<WalletReaderProvider>(WalletReaderProvider(Directory.systemTemp)..activeWalletId = 'w1');
  }
  await tester.pumpSailPage(const MessageSigner());
  await tester.binding.setSurfaceSize(windowSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('the signer fills its window and has no dialog', (tester) async {
    await _pumpSigner(tester, const Size(800, 574));

    expect(tester.takeException(), isNull);
    expect(find.byType(Dialog), findsNothing);
    expect(find.byType(SailModal), findsNothing);
    expect(tester.getSize(find.byType(MessageSigner)), tester.getSize(find.byType(Scaffold)));
  });

  testWidgets('the signer has no close button to empty its window', (tester) async {
    await _pumpSigner(tester, const Size(800, 574));

    final closeButtons = find.byWidgetPredicate((w) => w is SailButton && w.icon == SailSVGAsset.iconClose);
    expect(closeButtons, findsNothing);
  });

  testWidgets('the sign tab signs in a small window', (tester) async {
    await _pumpSigner(tester, const Size(600, 374));

    expect(tester.takeException(), isNull);
    final signButton = find.widgetWithText(SailButton, 'Sign Message').last;
    await tester.ensureVisible(signButton);
    await tester.tap(signButton);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('mock_signature'), findsOneWidget);
  });

  for (final (name, valid, result) in [
    ('a valid', true, 'Message verified'),
    ('an invalid', false, 'Invalid signature'),
  ]) {
    testWidgets('$name result shows next to the verify button', (tester) async {
      await _pumpSigner(tester, const Size(800, 574));
      final api = GetIt.I.get<BitwindowRPC>().wallet as MockWalletAPI;
      api.verifyResult = valid;
      addTearDown(() => api.verifyResult = true);
      await tester.tap(find.text('Verify Message').first);
      await tester.pumpAndSettle();

      final button = find.widgetWithText(SailButton, 'Verify Message').last;
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pumpAndSettle();

      _expectNextTo(tester, find.text(result), button);
    });
  }

  testWidgets('a verify error shows next to the verify button', (tester) async {
    await _pumpSigner(tester, const Size(800, 574));
    GetIt.I.get<WalletReaderProvider>().activeWalletId = null;
    addTearDown(() => GetIt.I.get<WalletReaderProvider>().activeWalletId = 'w1');
    await tester.tap(find.text('Verify Message').first);
    await tester.pumpAndSettle();

    final button = find.widgetWithText(SailButton, 'Verify Message').last;
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();

    _expectNextTo(tester, find.textContaining('No active wallet'), button);
  });

  testWidgets('the verify help text ends with a full sentence', (tester) async {
    await _pumpSigner(tester, const Size(800, 574));
    await tester.tap(find.text('Verify Message').first);
    await tester.pumpAndSettle();

    expect(find.textContaining('cannot prove sendership of any transaction!'), findsOneWidget);
  });
}

void _expectNextTo(WidgetTester tester, Finder finder, Finder button) {
  expect(finder, findsOneWidget);
  final rect = tester.getRect(finder);
  final buttonRect = tester.getRect(button);
  expect(rect.left, greaterThan(buttonRect.right));
  expect(rect.left, lessThan(buttonRect.right + 48));
  expect(rect.center.dy, closeTo(buttonRect.center.dy, buttonRect.height / 2));
}
