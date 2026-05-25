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
  group('SailAlert', () {
    testWidgets('renders title and description', (tester) async {
      await tester.pumpWidget(
        _app(const SailAlert(title: 'Heads up', description: 'Details here')),
      );
      expect(find.text('Heads up'), findsOneWidget);
      expect(find.text('Details here'), findsOneWidget);
    });

    testWidgets('renders icon when provided', (tester) async {
      await tester.pumpWidget(
        _app(const SailAlert(title: 't', icon: Text('I'))),
      );
      expect(find.text('I'), findsOneWidget);
    });

    testWidgets('destructive variant uses error border color', (tester) async {
      await tester.pumpWidget(
        _app(
          const SailAlert(
            variant: SailAlertVariant.destructive,
            title: 'Boom',
          ),
        ),
      );
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SailAlert),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
    });

    testWidgets('success variant renders without errors', (tester) async {
      await tester.pumpWidget(
        _app(
          const SailAlert(
            variant: SailAlertVariant.success,
            title: 'Done',
          ),
        ),
      );
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('warning and info variants render', (tester) async {
      await tester.pumpWidget(
        _app(
          const Column(
            children: [
              SailAlert(variant: SailAlertVariant.warning, title: 'W'),
              SailAlert(variant: SailAlertVariant.info, title: 'I'),
            ],
          ),
        ),
      );
      expect(find.text('W'), findsOneWidget);
      expect(find.text('I'), findsOneWidget);
    });
  });
}
