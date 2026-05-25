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
  group('SailCard', () {
    testWidgets('renders child', (tester) async {
      await tester.pumpWidget(
        _app(const SailCard(child: Text('hello'))),
      );
      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('renders title and subtitle when supplied', (tester) async {
      await tester.pumpWidget(
        _app(
          const SailCard(
            title: 'card title',
            subtitle: 'card subtitle',
            child: Text('body'),
          ),
        ),
      );
      expect(find.text('card title'), findsOneWidget);
      expect(find.text('card subtitle'), findsOneWidget);
      expect(find.text('body'), findsOneWidget);
    });

    testWidgets('does not depend on Material wrap for surface', (tester) async {
      await tester.pumpWidget(
        _app(const SailCard(child: Text('x'))),
      );
      // The refactor drops the Material wrap; ensure DecoratedBox is the
      // surface that paints the card background.
      expect(find.byType(DecoratedBox), findsWidgets);
      expect(find.byType(ClipRRect), findsWidgets);
    });

    testWidgets('respects custom color override', (tester) async {
      const customColor = Color(0xFFFF00FF);
      await tester.pumpWidget(
        _app(const SailCard(color: customColor, child: Text('c'))),
      );
      final decoratedBoxes = tester
          .widgetList<DecoratedBox>(find.byType(DecoratedBox))
          .where((d) => (d.decoration as BoxDecoration).color == customColor);
      expect(decoratedBoxes, isNotEmpty);
    });

    testWidgets('respects custom borderRadius override', (tester) async {
      const customRadius = BorderRadius.all(Radius.circular(42));
      await tester.pumpWidget(
        _app(
          const SailCard(borderRadius: customRadius, child: Text('c')),
        ),
      );
      final clipRRects = tester
          .widgetList<ClipRRect>(find.byType(ClipRRect))
          .where((c) => c.borderRadius == customRadius);
      expect(clipRRects, isNotEmpty);
    });
  });
}
