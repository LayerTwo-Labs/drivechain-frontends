import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the font manifest holds one copy of each family, from sail_ui', () async {
    final manifest = jsonDecode(await rootBundle.loadString('FontManifest.json')) as List<dynamic>;
    final families = {
      for (final entry in manifest.cast<Map<String, dynamic>>())
        entry['family'] as String: [
          for (final font in (entry['fonts'] as List<dynamic>).cast<Map<String, dynamic>>()) font['asset'] as String,
        ],
    };

    expect(families.keys, containsAll([SailFonts.inter, SailFonts.mono]));
    expect(families.keys, isNot(contains('Inter')));
    expect(families.keys, isNot(contains('IBMPlexMono')));
    for (final asset in [...families[SailFonts.inter]!, ...families[SailFonts.mono]!]) {
      expect(asset, startsWith('packages/sail_ui/assets/fonts/'));
      expect((await rootBundle.load(asset)).lengthInBytes, greaterThan(0));
    }
  });

  testWidgets('text resolves the sail_ui families', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SailTheme(
          data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
          child: Column(
            children: [
              SailText.primary13('regular'),
              SailText.primary13('mono', monospace: true),
            ],
          ),
        ),
      ),
    );

    expect(tester.widget<Text>(find.text('regular')).style!.fontFamily, SailFonts.inter);
    expect(tester.widget<Text>(find.text('mono')).style!.fontFamily, SailFonts.mono);
  });
}
