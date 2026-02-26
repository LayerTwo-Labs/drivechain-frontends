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
          title: 'Bitnames Registry',
          subtitle: 'Decentralized naming system',
          child: SailText.primary15('Card Content'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bitnames Registry'), findsOneWidget);
      expect(find.text('Decentralized naming system'), findsOneWidget);
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
          label: 'Register Name',
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
          label: 'Registering...',
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
          hintText: 'Enter name to register',
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'myname');
      expect(controller.text, 'myname');
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
            value: 'available',
            items: const [
              SailDropdownItem(value: 'available', label: 'Available'),
              SailDropdownItem(value: 'registered', label: 'Registered'),
            ],
            onChanged: (value) {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Available'), findsOneWidget);
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
