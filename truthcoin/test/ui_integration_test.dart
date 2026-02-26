import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  group('UI Component Tests', () {
    testWidgets('SailCard renders with title and content', (tester) async {
      await tester.pumpSailPage(
        SailCard(
          title: 'Prediction Markets',
          subtitle: 'Oracle-based forecasting',
          child: SailText.primary15('Card Content'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Prediction Markets'), findsOneWidget);
      expect(find.text('Oracle-based forecasting'), findsOneWidget);
      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('SailColumn renders children vertically', (tester) async {
      await tester.pumpSailPage(
        SailColumn(
          spacing: SailStyleValues.padding16,
          children: [
            SailText.primary15('First'),
            SailText.primary15('Second'),
            SailText.primary15('Third'),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final firstOffset = tester.getTopLeft(find.text('First'));
      final secondOffset = tester.getTopLeft(find.text('Second'));
      expect(secondOffset.dy, greaterThan(firstOffset.dy));
    });

    testWidgets('SailRow renders children horizontally', (tester) async {
      await tester.pumpSailPage(
        SailRow(
          spacing: SailStyleValues.padding16,
          children: [
            SailText.primary15('Left'),
            SailText.primary15('Right'),
          ],
        ),
      );
      await tester.pumpAndSettle();

      final leftOffset = tester.getTopLeft(find.text('Left'));
      final rightOffset = tester.getTopLeft(find.text('Right'));
      expect(rightOffset.dx, greaterThan(leftOffset.dx));
    });
  });

  group('Button Tests', () {
    testWidgets('SailButton responds to tap', (tester) async {
      bool wasPressed = false;

      await tester.pumpSailPage(
        SailButton(
          label: 'Place Bet',
          onPressed: () async {
            wasPressed = true;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SailButton));
      await tester.pumpAndSettle();

      expect(wasPressed, isTrue);
    });

    testWidgets('SailButton loading state renders', (tester) async {
      await tester.pumpSailPage(
        SailButton(
          label: 'Processing...',
          loading: true,
          onPressed: () async {},
        ),
      );
      await tester.pump();

      expect(find.byType(SailButton), findsOneWidget);
    });

    testWidgets('Disabled SailButton does not trigger callback', (tester) async {
      bool wasPressed = false;

      await tester.pumpSailPage(
        SailButton(
          label: 'Disabled',
          disabled: true,
          onPressed: () async {
            wasPressed = true;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(SailButton));
      await tester.pumpAndSettle();

      expect(wasPressed, isFalse);
    });
  });

  group('TextField Tests', () {
    testWidgets('SailTextField accepts input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpSailPage(
        SailTextField(
          controller: controller,
          hintText: 'Enter market question',
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Will BTC reach 100k?');
      expect(controller.text, 'Will BTC reach 100k?');
    });
  });

  group('Theme Tests', () {
    testWidgets('Theme colors accessible from context', (tester) async {
      await tester.pumpSailPage(
        Builder(
          builder: (context) {
            final theme = SailTheme.of(context);
            return Container(
              color: theme.colors.background,
              child: SailText.primary15('Themed'),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Themed'), findsOneWidget);
    });
  });

  group('Dropdown Tests', () {
    testWidgets('SailDropdownButton renders with value', (tester) async {
      await tester.pumpSailPage(
        StatefulBuilder(
          builder: (context, setState) => SailDropdownButton<String>(
            value: 'yes',
            items: const [
              SailDropdownItem(value: 'yes', label: 'Yes'),
              SailDropdownItem(value: 'no', label: 'No'),
            ],
            onChanged: (value) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Yes'), findsOneWidget);
    });
  });

  group('Checkbox Tests', () {
    testWidgets('SailCheckbox renders', (tester) async {
      await tester.pumpSailPage(
        StatefulBuilder(
          builder: (context, setState) => SailCheckbox(
            value: false,
            onChanged: (value) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SailCheckbox), findsOneWidget);
    });
  });
}
