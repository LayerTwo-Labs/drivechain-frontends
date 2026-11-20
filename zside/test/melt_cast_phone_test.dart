import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:zside/pages/tabs/zside/zside_melt_cast_page.dart';

Future<void> _pump(WidgetTester tester, {required bool phone}) async {
  SailStyleValues.phoneLayoutOverride = phone;
  addTearDown(() => SailStyleValues.phoneLayoutOverride = null);
  await tester.binding.setSurfaceSize(Size(phone ? 390 : 1200, 600));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: Scaffold(
          body: Column(
            children: [
              MeltButton(onPressed: () async {}),
              CastButton(onPressed: () async {}),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('a phone shows Melt and Cast as plain cards with a 16 px title at the left', (tester) async {
    await _pump(tester, phone: true);

    expect(tester.takeException(), isNull);
    for (final (title, line) in [
      ('Melt', 'Click here to Melt ALL of your transparent Coins'),
      ('Cast', 'Click here to Cast 95-100% of your z-value as 4 new Coins'),
    ]) {
      final text = tester.widget<Text>(find.text(title));
      expect(text.style!.fontSize, 16);
      expect(tester.getRect(find.text(title)).left, lessThan(60));
      expect(tester.widget<Text>(find.text(line)).style!.fontSize, 12);
      expect(tester.getRect(find.text(line)).left, closeTo(17, 1));
    }
    expect(
      find.byWidgetPredicate(
        (w) => w is Container && w.decoration is BoxDecoration && (w.decoration! as BoxDecoration).gradient != null,
      ),
      findsNothing,
    );
  });

  testWidgets('the desktop keeps the centered 24 px titles', (tester) async {
    await _pump(tester, phone: false);

    expect(tester.widget<Text>(find.text('Melt')).style!.fontSize, 24);
    expect(tester.getCenter(find.text('Click here to Melt ALL of your transparent Coins')).dx, closeTo(600, 1));
  });
}
