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
  group('SailSheet', () {
    testWidgets('opens via showSailSheet from right', (tester) async {
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
      unawaitedFuture(
        showSailSheet<void>(
          context: ctx,
          builder: (_) => SailText.primary12('sheet-body'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('sheet-body'), findsOneWidget);
    });

    testWidgets('renders for each side', (tester) async {
      for (final side in SailSheetSide.values) {
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
        unawaitedFuture(
          showSailSheet<void>(
            context: ctx,
            side: side,
            builder: (_) => SailText.primary12('body-${side.name}'),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('body-${side.name}'), findsOneWidget);
      }
    });

    testWidgets('barrier tap dismisses by default', (tester) async {
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
      unawaitedFuture(
        showSailSheet<void>(
          context: ctx,
          side: SailSheetSide.right,
          builder: (_) => SailText.primary12('dismissable'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('dismissable'), findsOneWidget);
      // tap on the far left (barrier area) — sheet slides from right
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.text('dismissable'), findsNothing);
    });

    testWidgets('barrierDismissible=false keeps sheet on barrier tap', (tester) async {
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
      unawaitedFuture(
        showSailSheet<void>(
          context: ctx,
          side: SailSheetSide.right,
          barrierDismissible: false,
          builder: (_) => SailText.primary12('sticky'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.text('sticky'), findsOneWidget);
    });
  });
}

void unawaitedFuture(Future<dynamic> f) {}
