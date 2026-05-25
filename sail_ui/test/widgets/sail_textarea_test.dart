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
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  group('SailTextarea', () {
    testWidgets('renders with placeholder', (tester) async {
      await tester.pumpWidget(
        _app(const SailTextarea(placeholder: 'tell me')),
      );
      expect(find.byType(SailTextarea), findsOneWidget);
      expect(find.text('tell me'), findsOneWidget);
    });

    testWidgets('emits onChanged when typing', (tester) async {
      String? captured;
      await tester.pumpWidget(
        _app(
          SailTextarea(
            placeholder: 'hi',
            onChanged: (v) => captured = v,
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'hello');
      expect(captured, 'hello');
    });

    testWidgets('uses provided controller', (tester) async {
      final controller = TextEditingController(text: 'seed');
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        _app(SailTextarea(controller: controller, placeholder: 'p')),
      );
      expect(find.text('seed'), findsOneWidget);
      controller.text = 'updated';
      await tester.pump();
      expect(find.text('updated'), findsOneWidget);
    });

    testWidgets('respects minLines for multiline rendering', (tester) async {
      await tester.pumpWidget(
        _app(const SailTextarea(placeholder: 'multi', minLines: 5)),
      );
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.minLines, 5);
    });

    testWidgets('shows label when provided', (tester) async {
      await tester.pumpWidget(
        _app(const SailTextarea(placeholder: 'p', label: 'Bio')),
      );
      expect(find.text('Bio'), findsOneWidget);
    });
  });
}
