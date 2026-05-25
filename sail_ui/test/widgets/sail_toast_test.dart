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
  group('showSailToast', () {
    testWidgets('renders message after enqueue', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      showSailToast(
        ctx,
        'hello toast',
        duration: const Duration(milliseconds: 200),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('hello toast'), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 250));
    });

    testWidgets('auto-dismisses after duration', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      showSailToast(
        ctx,
        'temporary',
        duration: const Duration(milliseconds: 100),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('temporary'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('temporary'), findsNothing);
    });

    testWidgets('stacks multiple toasts', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      showSailToast(ctx, 'first');
      showSailToast(ctx, 'second');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('first'), findsOneWidget);
      expect(find.text('second'), findsOneWidget);
      // Drain timers before ending the test.
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(milliseconds: 250));
    });

    testWidgets('action label and dismiss glyph render', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      showSailToast(
        ctx,
        'with action',
        action: SailToastAction(label: 'undo', onPressed: () {}),
        duration: const Duration(milliseconds: 200),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('undo'), findsOneWidget);
      expect(find.text(String.fromCharCode(0x00D7)), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 250));
    });

    testWidgets('variants render', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      for (final v in SailToastVariant.values) {
        showSailToast(
          ctx,
          'v-${v.name}',
          variant: v,
          duration: const Duration(milliseconds: 100),
        );
      }
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      for (final v in SailToastVariant.values) {
        expect(find.text('v-${v.name}'), findsOneWidget);
      }
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 250));
    });
  });
}
