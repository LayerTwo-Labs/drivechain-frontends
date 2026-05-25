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
  group('SailSkeleton', () {
    testWidgets('renders child when disabled', (tester) async {
      await tester.pumpWidget(
        _app(
          const SailSkeleton(
            description: 'loading thing',
            enabled: false,
            child: Text('payload'),
          ),
        ),
      );
      expect(find.text('payload'), findsOneWidget);
    });

    testWidgets('wraps content with SailSkeletonizer', (tester) async {
      await tester.pumpWidget(
        _app(
          const SailSkeleton(
            description: 'wait',
            child: Text('p'),
          ),
        ),
      );
      expect(find.byType(SailSkeletonizer), findsOneWidget);
    });

    testWidgets('toggles enabled flag without crash', (tester) async {
      await tester.pumpWidget(
        _app(
          const SailSkeleton(
            description: 'd',
            enabled: false,
            child: Text('child'),
          ),
        ),
      );
      await tester.pumpWidget(
        _app(
          const SailSkeleton(
            description: 'd',
            enabled: true,
            child: Text('child'),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SailSkeleton), findsOneWidget);
    });
  });
}
