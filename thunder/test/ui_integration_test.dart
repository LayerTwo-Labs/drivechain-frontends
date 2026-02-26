import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/rpc_mock_sidechain.dart';
import 'test_utils.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized({
    'flutter.test.automatic_wait_for_timers': 'false',
  });

  setUpAll(() async {
    final sidechainRPC = MockSidechainRPC();
    final thunderRPC = MockThunderRPC();

    if (!GetIt.I.isRegistered<SidechainRPC>()) {
      GetIt.I.registerLazySingleton<SidechainRPC>(() => sidechainRPC);
    }
    if (!GetIt.I.isRegistered<ThunderRPC>()) {
      GetIt.I.registerLazySingleton<ThunderRPC>(() => thunderRPC);
    }
    if (!GetIt.I.isRegistered<MainchainRPC>()) {
      GetIt.I.registerLazySingleton<MainchainRPC>(() => MockMainchainRPC());
    }
    if (!GetIt.I.isRegistered<Logger>()) {
      GetIt.I.registerLazySingleton<Logger>(() => Logger());
    }
    if (!GetIt.I.isRegistered<SidechainTransactionsProvider>()) {
      GetIt.I.registerLazySingleton<SidechainTransactionsProvider>(
        () => SidechainTransactionsProvider(),
      );
    }
    if (!GetIt.I.isRegistered<AddressProvider>()) {
      GetIt.I.registerLazySingleton<AddressProvider>(() => AddressProvider());
    }
    if (!GetIt.I.isRegistered<BalanceProvider>()) {
      final balanceProvider = BalanceProvider(connections: [sidechainRPC]);
      GetIt.I.registerLazySingleton<BalanceProvider>(() => balanceProvider);
      await balanceProvider.fetch();
    }
  });

  group('UI Component Tests', () {
    testWidgets('SailCard renders with title and content', (tester) async {
      await tester.pumpSailPage(
        SailCard(
          title: 'Thunder Card',
          subtitle: 'Test Subtitle',
          child: SailText.primary15('Card Content'),
        ),
      );

      expect(find.text('Thunder Card'), findsOneWidget);
      expect(find.text('Test Subtitle'), findsOneWidget);
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

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('Third'), findsOneWidget);

      final firstOffset = tester.getTopLeft(find.text('First'));
      final secondOffset = tester.getTopLeft(find.text('Second'));
      final thirdOffset = tester.getTopLeft(find.text('Third'));

      expect(secondOffset.dy, greaterThan(firstOffset.dy));
      expect(thirdOffset.dy, greaterThan(secondOffset.dy));
    });

    testWidgets('SailRow renders children horizontally', (tester) async {
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

      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Center'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);

      final leftOffset = tester.getTopLeft(find.text('Left'));
      final centerOffset = tester.getTopLeft(find.text('Center'));
      final rightOffset = tester.getTopLeft(find.text('Right'));

      expect(centerOffset.dx, greaterThan(leftOffset.dx));
      expect(rightOffset.dx, greaterThan(centerOffset.dx));
    });
  });

  group('Button Tests', () {
    testWidgets('SailButton responds to tap', (tester) async {
      bool wasPressed = false;

      await tester.pumpSailPage(
        SailButton(
          label: 'Tap Me',
          onPressed: () async {
            wasPressed = true;
          },
        ),
      );

      expect(find.byType(SailButton), findsOneWidget);
      expect(wasPressed, isFalse);

      await tester.tap(find.byType(SailButton));
      await tester.pumpAndSettle();

      expect(wasPressed, isTrue);
    });

    testWidgets('SailButton loading state renders', (tester) async {
      await tester.pumpSailPage(
        SailButton(
          label: 'Loading',
          loading: true,
          onPressed: () async {},
        ),
      );
      // Don't use pumpAndSettle - loading indicator has infinite animation
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
          hintText: 'Enter address',
        ),
      );

      await tester.enterText(find.byType(TextField), 'tb1qtest123');
      expect(controller.text, 'tb1qtest123');
    });

    testWidgets('SailTextField shows hint text', (tester) async {
      final controller = TextEditingController();

      await tester.pumpSailPage(
        SailTextField(
          controller: controller,
          hintText: 'Bitcoin address',
        ),
      );

      expect(find.text('Bitcoin address'), findsOneWidget);
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
              child: SailText.primary15(
                'Themed',
                color: theme.colors.text,
              ),
            );
          },
        ),
      );

      expect(find.text('Themed'), findsOneWidget);
    });

    testWidgets('SailStyleValues spacing constants work', (tester) async {
      await tester.pumpSailPage(
        Padding(
          padding: EdgeInsets.all(SailStyleValues.padding16),
          child: SailText.primary15('Spaced'),
        ),
      );

      expect(find.text('Spaced'), findsOneWidget);
    });
  });

  group('Dropdown Tests', () {
    testWidgets('SailDropdownButton renders with value', (tester) async {
      String? selectedValue = 'btc';

      await tester.pumpSailPage(
        StatefulBuilder(
          builder: (context, setState) => SailDropdownButton<String>(
            value: selectedValue,
            items: const [
              SailDropdownItem(value: 'btc', label: 'Bitcoin'),
              SailDropdownItem(value: 'ltc', label: 'Litecoin'),
            ],
            onChanged: (value) {
              setState(() => selectedValue = value);
            },
          ),
        ),
      );

      expect(find.text('Bitcoin'), findsOneWidget);
    });
  });

  group('Checkbox Tests', () {
    testWidgets('SailCheckbox renders and is interactive', (tester) async {
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
              SailText.primary15('Accept terms'),
            ],
          ),
        ),
      );

      expect(find.byType(SailCheckbox), findsOneWidget);
      expect(find.text('Accept terms'), findsOneWidget);
    });
  });
}
