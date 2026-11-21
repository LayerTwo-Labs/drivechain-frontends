import 'package:bitwindow/pages/overview_page.dart';
import 'package:bitwindow/providers/news_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() => SailStyleValues.phoneLayoutOverride = null);

  Future<void> pumpTab(WidgetTester tester, String tab, double width) async {
    await loadBundledFonts();
    await registerTestDependencies();
    GetIt.I.get<NewsProvider>().topics = [
      Topic(topic: 'a1a1a1a1', name: 'US Weekly', confirmed: true),
      Topic(topic: 'd3d3d3d3', name: 'Drivechain Dev', confirmed: false, txid: 'ab' * 32),
    ];
    await tester.pumpSailPage(SizedBox(width: width, child: const ManageNewsSubscriptionsView()));
    await tester.tap(find.text(tab));
    await tester.pumpAndSettle();
  }

  testWidgets('on a phone the subscribe field hint drops the Enter URL words', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await pumpTab(tester, 'Subscribe', 358);

    expect(find.text('e.g. 7{a1a1a1a1}US Weekly'), findsOneWidget);
    expect(find.text('Enter URL e.g. 7{a1a1a1a1}US Weekly'), findsNothing);
  });

  testWidgets('on the desktop the subscribe field hint keeps the Enter URL words', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await pumpTab(tester, 'Subscribe', 700);

    expect(find.text('Enter URL e.g. 7{a1a1a1a1}US Weekly'), findsOneWidget);
  });

  testWidgets('on a phone a pending topic says Tap to view tx on one regular line', (tester) async {
    SailStyleValues.phoneLayoutOverride = true;
    await pumpTab(tester, 'Create Topic', 358);
    await tester.scrollUntilVisible(find.text('Tap to view tx'), 100, scrollable: find.byType(Scrollable).last);

    expect(find.text('double-click to view tx'), findsNothing);
    final hint = tester.widget<Text>(find.text('Tap to view tx'));
    expect(hint.style!.fontStyle, isNot(FontStyle.italic));
    expect(tester.getSize(find.text('Tap to view tx')).height, lessThan(20));
    final tappable = tester.widget<SailTappable>(
      find.ancestor(of: find.text('Tap to view tx'), matching: find.byType(SailTappable)).first,
    );
    expect(tappable.onTap, isNotNull);
    expect(tappable.onDoubleTap, isNull);
  });

  testWidgets('on the desktop a pending topic keeps the double-click hint', (tester) async {
    SailStyleValues.phoneLayoutOverride = false;
    await pumpTab(tester, 'Create Topic', 700);

    expect(find.text('double-click to view tx'), findsOneWidget);
  });
}
