import 'dart:io';

import 'package:bitwindow/pages/message_signer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

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
}
