import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Widget _wrap(Widget child) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: SailTheme(
      data: SailThemeData.lightTheme(
        SailColorScheme.orange,
        true,
        SailFontValues.inter,
      ),
      child: Center(child: child),
    ),
  );
}

List<SailAccordionItem> _items() => [
  SailAccordionItem(
    id: 'a',
    header: SailText.primary12('header A'),
    body: SailText.primary12('body A'),
  ),
  SailAccordionItem(
    id: 'b',
    header: SailText.primary12('header B'),
    body: SailText.primary12('body B'),
  ),
];

void main() {
  group('SailAccordion', () {
    testWidgets('renders all headers', (tester) async {
      await tester.pumpWidget(_wrap(SailAccordion(items: _items())));
      expect(find.text('header A'), findsOneWidget);
      expect(find.text('header B'), findsOneWidget);
    });

    testWidgets('single mode: opening b closes a', (tester) async {
      List<String>? captured;
      await tester.pumpWidget(
        _wrap(
          SailAccordion(
            items: _items(),
            initialOpen: const ['a'],
            collapsible: false,
            onChanged: (v) => captured = v,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('header B'));
      await tester.pumpAndSettle();
      expect(captured, ['b']);
    });

    testWidgets('multiple mode: both can be open', (tester) async {
      List<String>? captured;
      await tester.pumpWidget(
        _wrap(
          SailAccordion(
            items: _items(),
            type: SailAccordionType.multiple,
            initialOpen: const ['a'],
            onChanged: (v) => captured = v,
          ),
        ),
      );
      await tester.tap(find.text('header B'));
      await tester.pumpAndSettle();
      expect(captured!.toSet(), {'a', 'b'});
    });

    testWidgets('single + collapsible allows closing', (tester) async {
      List<String>? captured;
      await tester.pumpWidget(
        _wrap(
          SailAccordion(
            items: _items(),
            initialOpen: const ['a'],
            onChanged: (v) => captured = v,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('header A'));
      await tester.pumpAndSettle();
      expect(captured, isEmpty);
    });

    testWidgets('initial open shows body', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SailAccordion(
            items: _items(),
            initialOpen: const ['a'],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('body A'), findsOneWidget);
    });
  });
}
