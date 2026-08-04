import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  group('SailEditableText', () {
    Future<List<String>> pump(WidgetTester tester, {String value = 'Key 1'}) async {
      final committed = <String>[];
      await tester.pumpSailPage(
        Center(
          child: SailEditableText(
            value: value,
            onSubmitted: committed.add,
          ),
        ),
      );
      await tester.pumpAndSettle();
      return committed;
    }

    testWidgets('renders the value and does not resize when editing starts', (tester) async {
      await pump(tester);
      final before = tester.getSize(find.byType(TextField));

      await tester.tap(find.byType(SailTappable));
      await tester.pumpAndSettle();

      expect(tester.getSize(find.byType(TextField)), before);
    });

    testWidgets('the pencil commits a typed name on enter', (tester) async {
      final committed = await pump(tester);

      await tester.tap(find.byType(SailTappable));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Bob cold');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(committed, ['Bob cold']);
    });

    testWidgets('losing focus commits', (tester) async {
      final committed = await pump(tester);

      await tester.tap(find.byType(SailTappable));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Alice ledger');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      expect(committed, ['Alice ledger']);
    });

    testWidgets('an empty name reverts and commits nothing', (tester) async {
      final committed = await pump(tester);

      await tester.tap(find.byType(SailTappable));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '   ');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(committed, isEmpty);
      expect(find.text('Key 1'), findsOneWidget);
    });

    testWidgets('typing does nothing until the pencil is tapped', (tester) async {
      final committed = await pump(tester);

      await tester.tap(find.byType(TextField), warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(committed, isEmpty);
    });
  });
}
