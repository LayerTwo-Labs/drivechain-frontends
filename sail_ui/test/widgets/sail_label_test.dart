import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Widget _app(Widget child) {
  return MaterialApp(
    home: SailTheme(
      data: SailThemeData.lightTheme(
        SailColorScheme.orange,
        true,
        SailFontValues.inter,
      ),
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  group('SailLabel', () {
    testWidgets('renders text', (tester) async {
      await tester.pumpWidget(_app(const SailLabel(text: 'Email')));
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('appends asterisk when required', (tester) async {
      await tester.pumpWidget(
        _app(const SailLabel(text: 'Password', required: true)),
      );
      final richText = tester.widget<RichText>(
        find.descendant(of: find.byType(SailLabel), matching: find.byType(RichText)),
      );
      final plain = richText.text.toPlainText();
      expect(plain, 'Password *');
    });

    testWidgets('omits asterisk when not required', (tester) async {
      await tester.pumpWidget(_app(const SailLabel(text: 'Name')));
      final richText = tester.widget<RichText>(
        find.descendant(of: find.byType(SailLabel), matching: find.byType(RichText)),
      );
      expect(richText.text.toPlainText(), 'Name');
    });

    testWidgets('honors custom style override', (tester) async {
      const customStyle = TextStyle(fontSize: 22);
      await tester.pumpWidget(
        _app(const SailLabel(text: 'Big', style: customStyle)),
      );
      final richText = tester.widget<RichText>(
        find.descendant(of: find.byType(SailLabel), matching: find.byType(RichText)),
      );
      // Walk the TextSpan tree and find the leaf span carrying our text.
      TextSpan? located;
      void walk(InlineSpan span) {
        if (span is TextSpan) {
          if (span.text == 'Big') {
            located = span;
            return;
          }
          if (span.children != null) {
            for (final c in span.children!) {
              walk(c);
              if (located != null) return;
            }
          }
        }
      }

      walk(richText.text);
      expect(located, isNotNull);
      expect(located!.style?.fontSize, 22);
    });
  });
}
