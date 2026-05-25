import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

Widget _wrap(Widget child) {
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
  group('SailToggleGroup', () {
    testWidgets('renders all items with labels', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SailToggleGroup<int>(
            items: const [
              SailToggleGroupItem(value: 1, label: 'one'),
              SailToggleGroupItem(value: 2, label: 'two'),
              SailToggleGroupItem(value: 3, label: 'three'),
            ],
            values: const [1],
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.text('one'), findsOneWidget);
      expect(find.text('two'), findsOneWidget);
      expect(find.text('three'), findsOneWidget);
    });

    testWidgets('singleChoice replaces selection', (tester) async {
      List<int>? captured;
      await tester.pumpWidget(
        _wrap(
          SailToggleGroup<int>(
            items: const [
              SailToggleGroupItem(value: 1, label: 'one'),
              SailToggleGroupItem(value: 2, label: 'two'),
            ],
            values: const [1],
            singleChoice: true,
            onChanged: (v) => captured = v,
          ),
        ),
      );
      await tester.tap(find.text('two'));
      expect(captured, [2]);
    });

    testWidgets('multi mode adds to selection', (tester) async {
      List<int>? captured;
      await tester.pumpWidget(
        _wrap(
          SailToggleGroup<int>(
            items: const [
              SailToggleGroupItem(value: 1, label: 'one'),
              SailToggleGroupItem(value: 2, label: 'two'),
            ],
            values: const [1],
            onChanged: (v) => captured = v,
          ),
        ),
      );
      await tester.tap(find.text('two'));
      expect(captured, containsAll([1, 2]));
    });

    testWidgets('multi mode removes from selection', (tester) async {
      List<int>? captured;
      await tester.pumpWidget(
        _wrap(
          SailToggleGroup<int>(
            items: const [
              SailToggleGroupItem(value: 1, label: 'one'),
              SailToggleGroupItem(value: 2, label: 'two'),
            ],
            values: const [1, 2],
            onChanged: (v) => captured = v,
          ),
        ),
      );
      await tester.tap(find.text('one'));
      expect(captured, [2]);
    });

    testWidgets('singleChoice ignores untoggle when allowEmpty=false', (tester) async {
      List<int>? captured;
      await tester.pumpWidget(
        _wrap(
          SailToggleGroup<int>(
            items: const [
              SailToggleGroupItem(value: 1, label: 'one'),
            ],
            values: const [1],
            singleChoice: true,
            onChanged: (v) => captured = v,
          ),
        ),
      );
      await tester.tap(find.text('one'));
      expect(captured, isNull);
    });
  });
}
