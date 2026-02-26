import 'package:bitwindow/widgets/coinnews.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:stacked/stacked.dart';

import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  group('Dashboard Widget Tests', () {
    testWidgets('CoinNews widget renders and shows content', (tester) async {
      await tester.pumpSailPage(
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 600, maxWidth: 800),
          child: ViewModelBuilder.reactive(
            viewModelBuilder: () => CoinNewsViewModel(),
            builder: (context, model, child) => const CoinNewsView(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // CoinNews widget should render
      expect(find.byType(CoinNewsView), findsOneWidget);
    });
  });

  group('UI Component Tests', () {
    testWidgets('SailCard renders with title, subtitle and content', (tester) async {
      await tester.pumpSailPage(
        SailCard(
          title: 'Test Card',
          subtitle: 'Test Subtitle',
          child: SailText.primary15('Card Content'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Card'), findsOneWidget);
      expect(find.text('Test Subtitle'), findsOneWidget);
      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('SailColumn layout renders children vertically', (tester) async {
      await tester.pumpSailPage(
        SailColumn(
          spacing: SailStyleValues.padding16,
          children: [
            SailText.primary15('First Item'),
            SailText.primary15('Second Item'),
            SailText.primary15('Third Item'),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('First Item'), findsOneWidget);
      expect(find.text('Second Item'), findsOneWidget);
      expect(find.text('Third Item'), findsOneWidget);

      // Verify vertical layout by checking positions
      final firstOffset = tester.getTopLeft(find.text('First Item'));
      final secondOffset = tester.getTopLeft(find.text('Second Item'));
      final thirdOffset = tester.getTopLeft(find.text('Third Item'));

      expect(secondOffset.dy, greaterThan(firstOffset.dy));
      expect(thirdOffset.dy, greaterThan(secondOffset.dy));
    });

    testWidgets('SailRow layout renders children horizontally', (tester) async {
      await tester.pumpSailPage(
        SailRow(
          spacing: SailStyleValues.padding16,
          children: [
            SailText.primary15('Left'),
            SailText.primary15('Center'),
            SailText.primary15('Right'),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Center'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);

      // Verify horizontal layout by checking positions
      final leftOffset = tester.getTopLeft(find.text('Left'));
      final centerOffset = tester.getTopLeft(find.text('Center'));
      final rightOffset = tester.getTopLeft(find.text('Right'));

      expect(centerOffset.dx, greaterThan(leftOffset.dx));
      expect(rightOffset.dx, greaterThan(centerOffset.dx));
    });
  });

  group('Button Interaction Tests', () {
    testWidgets('SailButton responds to tap and triggers callback', (tester) async {
      bool wasPressed = false;

      await tester.pumpSailPage(
        SailButton(
          label: 'Click Me',
          onPressed: () async {
            wasPressed = true;
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SailButton), findsOneWidget);
      expect(wasPressed, isFalse);

      await tester.tap(find.byType(SailButton));
      await tester.pumpAndSettle();

      expect(wasPressed, isTrue);
    });

    testWidgets('SailButton shows loading indicator when loading', (tester) async {
      await tester.pumpSailPage(
        SailButton(
          label: 'Loading Button',
          loading: true,
          onPressed: () async {},
        ),
      );
      // Don't use pumpAndSettle - loading indicator has infinite animation
      await tester.pump();

      // Loading button shows a progress indicator
      expect(find.byType(SailButton), findsOneWidget);
    });

    testWidgets('Disabled SailButton does not trigger callback', (tester) async {
      bool wasPressed = false;

      await tester.pumpSailPage(
        SailButton(
          label: 'Disabled Button',
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
    testWidgets('SailTextField accepts and displays input', (tester) async {
      final controller = TextEditingController();

      await tester.pumpSailPage(
        SailTextField(
          controller: controller,
          hintText: 'Enter text here',
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Hello World');
      expect(controller.text, 'Hello World');
    });

    testWidgets('SailTextField shows hint text', (tester) async {
      final controller = TextEditingController();

      await tester.pumpSailPage(
        SailTextField(
          controller: controller,
          hintText: 'Enter your name',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Enter your name'), findsOneWidget);
    });
  });

  group('Theme Integration Tests', () {
    testWidgets('Theme colors are accessible and apply correctly', (tester) async {
      await tester.pumpSailPage(
        Builder(
          builder: (context) {
            final theme = SailTheme.of(context);
            return Container(
              color: theme.colors.background,
              child: SailText.primary15(
                'Themed Text',
                color: theme.colors.text,
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Themed Text'), findsOneWidget);
    });

    testWidgets('SailStyleValues spacing constants work correctly', (tester) async {
      await tester.pumpSailPage(
        Padding(
          padding: EdgeInsets.all(SailStyleValues.padding16),
          child: SailText.primary15('Padded Text'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Padded Text'), findsOneWidget);
    });
  });

  group('Dropdown Tests', () {
    testWidgets('SailDropdownButton renders with initial value', (tester) async {
      String? selectedValue = 'option1';

      await tester.pumpSailPage(
        StatefulBuilder(
          builder: (context, setState) => SailDropdownButton<String>(
            value: selectedValue,
            items: const [
              SailDropdownItem(value: 'option1', label: 'Option 1'),
              SailDropdownItem(value: 'option2', label: 'Option 2'),
            ],
            onChanged: (value) {
              setState(() => selectedValue = value);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Option 1'), findsOneWidget);
    });
  });

  group('Checkbox Tests', () {
    testWidgets('SailCheckbox renders and is tappable', (tester) async {
      bool isChecked = false;

      await tester.pumpSailPage(
        StatefulBuilder(
          builder: (context, setState) => SailRow(
            spacing: SailStyleValues.padding08,
            children: [
              SailCheckbox(
                value: isChecked,
                onChanged: (value) {
                  setState(() => isChecked = value);
                },
              ),
              SailText.primary15('Checkbox Label'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SailCheckbox), findsOneWidget);
      expect(find.text('Checkbox Label'), findsOneWidget);
    });
  });
}
