import 'dart:io';

import 'package:bitwindow/pages/merchants/chain_merchants_dialog.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

void main() {
  tearDown(() {
    SailStyleValues.phoneLayoutOverride = null;
    return GetIt.I.reset();
  });

  testWidgets('on a phone each merchant is a link above a grey description', (tester) async {
    String? url;
    openUrlProcessRunner = (executable, arguments) async {
      url = arguments.last;
      return ProcessResult(1, 0, '', '');
    };
    addTearDown(() => openUrlProcessRunner = Process.run);
    SailStyleValues.phoneLayoutOverride = true;
    await loadBundledFonts();
    await tester.pumpSailPage(const ChainMerchantsDialog());
    await tester.binding.setSurfaceSize(const Size(390, 800));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(SailTable), findsNothing);
    final name = tester.getRect(find.text('BitRefill'));
    final description = tester.getRect(find.text('Buy gift cards and mobile top-ups with Bitcoin'));
    expect(description.top, greaterThanOrEqualTo(name.bottom));
    expect(description.left, closeTo(name.left, 1));
    final nameStyle = tester.widget<Text>(find.text('BitRefill')).style!;
    expect(nameStyle.color, SailTheme.of(tester.element(find.text('BitRefill'))).colors.primary);
    expect(nameStyle.decoration, TextDecoration.underline);
    expect(tester.getRect(find.text('Shopify via BTCPay')).top, greaterThan(description.bottom));

    await tester.tap(find.text('BitRefill'));
    await tester.pump();
    expect(url, 'https://bitrefill.com');
  });

  testWidgets('on desktop the merchants stay a table', (tester) async {
    await tester.pumpSailPage(const ChainMerchantsDialog());
    await tester.pumpAndSettle();

    expect(find.byType(SailTable), findsOneWidget);
  });
}
