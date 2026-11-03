import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

const _launcher = MethodChannel('plugins.flutter.io/url_launcher');

void main() {
  testWidgets('a link in an article opens its URL', (tester) async {
    final opened = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(_launcher, (call) async {
      if (call.method == 'launch') {
        opened.add((call.arguments as Map)['url'] as String);
      }
      return true;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(_launcher, null));

    await tester.binding.setSurfaceSize(const Size(1000, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        home: SailTheme(
          data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
          child: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showArticleDetails(
                  context,
                  Article(title: 'Drivechain', markdown: 'Read [the BIP](https://bip300.xyz).', filename: 'a.md'),
                  'Learn',
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tapOnText(find.textRange.ofSubstring('the BIP'));
    await tester.pump();

    expect(opened, ['https://bip300.xyz']);
  });
}
