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
  group('SailAvatar', () {
    testWidgets('renders empty with no inputs', (tester) async {
      await tester.pumpWidget(_app(const SailAvatar()));
      expect(find.byType(SailAvatar), findsOneWidget);
    });

    testWidgets('renders initials from one-word name', (tester) async {
      await tester.pumpWidget(_app(const SailAvatar(initials: 'alice')));
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('renders two initials from two-word name', (tester) async {
      await tester.pumpWidget(_app(const SailAvatar(initials: 'alice bob')));
      expect(find.text('AB'), findsOneWidget);
    });

    testWidgets('renders custom fallback widget', (tester) async {
      await tester.pumpWidget(
        _app(const SailAvatar(fallback: Text('FB'))),
      );
      expect(find.text('FB'), findsOneWidget);
    });

    testWidgets('respects size parameter', (tester) async {
      await tester.pumpWidget(
        _app(const SailAvatar(initials: 'X', size: 64)),
      );
      final box = tester.getSize(find.byType(SailAvatar));
      expect(box.width, 64);
      expect(box.height, 64);
    });
  });
}
