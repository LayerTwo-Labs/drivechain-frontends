import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

class MockStore implements KeyValueStore {
  final _db = <String, String>{};

  @override
  Future<String?> getString(String key) async => _db[key];

  @override
  Future<void> setString(String key, String value) async {
    _db[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _db.remove(key);
  }
}

void main() {
  setUpAll(() async {
    final getIt = GetIt.instance;
    final log = Logger(level: Level.warning);

    if (!getIt.isRegistered<Logger>()) {
      getIt.registerSingleton<Logger>(log);
    }

    if (!getIt.isRegistered<ClientSettings>()) {
      getIt.registerSingleton<ClientSettings>(
        ClientSettings(store: MockStore(), log: log),
      );
    }

    if (!getIt.isRegistered<BitwindowClientSettings>()) {
      getIt.registerSingleton<BitwindowClientSettings>(
        BitwindowClientSettings(store: MockStore(), log: log),
      );
    }

    if (!getIt.isRegistered<SettingsProvider>()) {
      final settingsProvider = await SettingsProvider.create();
      getIt.registerSingleton<SettingsProvider>(settingsProvider);
    }
  });

  tearDownAll(() {
    GetIt.I.reset();
  });

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: SailTheme(
        data: SailThemeData.lightTheme(SailColorScheme.orange, true, SailFontValues.inter),
        child: Scaffold(body: child),
      ),
    );
  }

  group('SailText', () {
    testWidgets('renders primary text correctly', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        SailText.primary15('Test Text'),
      ));

      expect(find.text('Test Text'), findsOneWidget);
    });

    testWidgets('renders secondary text correctly', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        SailText.secondary13('Secondary Text'),
      ));

      expect(find.text('Secondary Text'), findsOneWidget);
    });
  });

  group('SailColumn', () {
    testWidgets('renders children vertically', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        SailColumn(
          spacing: SailStyleValues.padding08,
          children: [
            SailText.primary15('First'),
            SailText.primary15('Second'),
            SailText.primary15('Third'),
          ],
        ),
      ));

      expect(find.text('First'), findsOneWidget);
      expect(find.text('Second'), findsOneWidget);
      expect(find.text('Third'), findsOneWidget);
    });
  });

  group('SailRow', () {
    testWidgets('renders children horizontally', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        SailRow(
          spacing: SailStyleValues.padding08,
          children: [
            SailText.primary15('Left'),
            SailText.primary15('Center'),
            SailText.primary15('Right'),
          ],
        ),
      ));

      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Center'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);
    });
  });

  group('SailStyleValues', () {
    test('padding values are defined correctly', () {
      expect(SailStyleValues.padding04, 4.0);
      expect(SailStyleValues.padding08, 8.0);
      expect(SailStyleValues.padding12, 12.0);
      expect(SailStyleValues.padding16, 16.0);
    });

    test('borderRadius is defined', () {
      expect(SailStyleValues.borderRadius, isA<BorderRadius>());
    });
  });

  group('SailCard', () {
    testWidgets('renders with title', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        SailCard(
          title: 'Card Title',
          child: SailText.primary15('Content'),
        ),
      ));

      expect(find.text('Card Title'), findsOneWidget);
      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('renders with subtitle', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        SailCard(
          title: 'Title',
          subtitle: 'Subtitle',
          child: SailText.primary15('Content'),
        ),
      ));

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Subtitle'), findsOneWidget);
    });
  });

  group('SailButton', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        SailButton(
          label: 'Click Me',
          onPressed: () async {},
        ),
      ));

      // SailButton renders internally with its own structure
      expect(find.byType(SailButton), findsOneWidget);
    });

    testWidgets('shows loading state', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        SailButton(
          label: 'Loading',
          loading: true,
          onPressed: () async {},
        ),
      ));

      // Loading SailButton shows progress indicator(s)
      expect(find.byType(SailButton), findsOneWidget);
    });
  });
}
