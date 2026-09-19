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

const _items = <SailComboboxItem<String>>[
  SailComboboxItem(value: 'apple', label: 'Apple'),
  SailComboboxItem(value: 'banana', label: 'Banana'),
  SailComboboxItem(value: 'cherry', label: 'Cherry'),
];

void main() {
  group('SailCombobox', () {
    testWidgets('shows placeholder when no value', (tester) async {
      await tester.pumpWidget(
        _app(
          SailCombobox<String>(
            items: _items,
            onChanged: (_) {},
            placeholder: 'Pick fruit',
          ),
        ),
      );
      expect(find.text('Pick fruit'), findsOneWidget);
    });

    testWidgets('shows selected label when value set', (tester) async {
      await tester.pumpWidget(
        _app(
          SailCombobox<String>(
            items: _items,
            value: 'banana',
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.text('Banana'), findsOneWidget);
    });

    testWidgets('opens panel on tap and lists items', (tester) async {
      await tester.pumpWidget(
        _app(
          SailCombobox<String>(items: _items, onChanged: (_) {}),
        ),
      );
      await tester.tap(find.byType(SailCombobox<String>));
      await tester.pumpAndSettle();
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Cherry'), findsOneWidget);
    });

    testWidgets('selecting an item fires onChanged', (tester) async {
      String? picked;
      await tester.pumpWidget(
        _app(
          SailCombobox<String>(
            items: _items,
            onChanged: (v) => picked = v,
          ),
        ),
      );
      await tester.tap(find.byType(SailCombobox<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cherry'));
      await tester.pumpAndSettle();
      expect(picked, 'cherry');
    });

    testWidgets('shows no-results text when filter matches nothing', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          SailCombobox<String>(
            items: _items,
            onChanged: (_) {},
            noResultsText: 'nothing here',
          ),
        ),
      );
      await tester.tap(find.byType(SailCombobox<String>));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).first, 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('nothing here'), findsOneWidget);
    });

    group('with sections', () {
      const targets = <SailComboboxItem<String>>[
        SailComboboxItem(value: 'solo', label: 'Solo, your node', section: 'Your node', trailing: ['No fee']),
        SailComboboxItem(
          value: 'bip300',
          label: 'bip300 pool',
          section: 'Pools',
          trailing: ['16.5 TH/s', '1% fee'],
          searchValue: 'bip300 pool pool.beta.bip300.xyz',
        ),
        SailComboboxItem(
          value: 'avon',
          label: 'avonpool pool',
          section: 'Pools',
          searchValue: 'avonpool pool.alpha.xyz',
        ),
        SailComboboxItem(value: 'custom', label: 'Custom pool', section: 'Other'),
      ];

      testWidgets('the trigger shows the trailing figures after the label', (tester) async {
        await tester.pumpWidget(
          _app(SailCombobox<String>(items: targets, value: 'bip300', onChanged: (_) {})),
        );
        expect(find.text('bip300 pool  ·  16.5 TH/s  ·  1% fee'), findsOneWidget);
      });

      testWidgets('each section heading shows one time', (tester) async {
        await tester.pumpWidget(
          _app(
            SailCombobox<String>(
              items: targets,
              value: 'custom',
              width: 480,
              searchPlaceholder: 'Search pools',
              onChanged: (_) {},
            ),
          ),
        );
        await tester.tap(find.byType(SailCombobox<String>));
        await tester.pumpAndSettle();
        expect(find.text('Search pools'), findsOneWidget);
        expect(find.text('Your node'), findsOneWidget);
        expect(find.text('Pools'), findsOneWidget);
        expect(find.text('Other'), findsOneWidget);
        expect(find.text('16.5 TH/s'), findsOneWidget);
        expect(find.text('1% fee'), findsOneWidget);
      });

      testWidgets('a search on the host keeps the matching pool and its heading', (tester) async {
        await tester.pumpWidget(
          _app(SailCombobox<String>(items: targets, width: 480, onChanged: (_) {})),
        );
        await tester.tap(find.byType(SailCombobox<String>));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(EditableText).first, 'beta');
        await tester.pumpAndSettle();
        expect(find.text('bip300 pool'), findsOneWidget);
        expect(find.text('Pools'), findsOneWidget);
        expect(find.text('avonpool pool'), findsNothing);
        expect(find.text('Your node'), findsNothing);
      });
    });
  });
}
