import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

class MockStore implements KeyValueStore {
  final Map<String, String> _db = {};

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
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FontScaleSetting', () {
    test('key and default', () {
      final setting = FontScaleSetting();
      expect(setting.key, 'font_scale');
      expect(setting.value, 1.0);
    });

    test('round trips through json', () {
      final setting = FontScaleSetting(newValue: 1.25);
      expect(setting.toJson(), '1.25');
      expect(setting.fromJson('1.25'), 1.25);
    });

    test('snaps an off-step json value onto a known scale', () {
      expect(FontScaleSetting().fromJson('1.23'), 1.25);
      expect(FontScaleSetting().fromJson('0.81'), 0.8);
    });

    test('returns null on unparseable json so the default applies', () {
      expect(FontScaleSetting().fromJson('not-a-number'), isNull);
      expect(FontScaleSetting().withValue().value, 1.0);
    });

    test('never exceeds the 2.0 clamp SailText applies', () {
      expect(sailFontScales.last, 2.0);
      expect(nearestSailFontScale(9.0), 2.0);
    });
  });

  group('font scale persistence', () {
    setUp(() async {
      await GetIt.I.reset();
      final log = Logger(level: Level.warning);
      final store = MockStore();

      GetIt.I.registerSingleton<Logger>(log);
      GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: store, log: log));
      GetIt.I.registerSingleton<BitwindowClientSettings>(BitwindowClientSettings(store: store, log: log));
    });

    tearDown(() async {
      await GetIt.I.reset();
    });

    Future<SailAppState> pumpApp(WidgetTester tester) async {
      await tester.pumpWidget(
        SailApp(
          dense: false,
          accentColor: SailColorScheme.orange,
          log: GetIt.I.get<Logger>(),
          builder: (_) => MaterialApp(home: Scaffold(body: SailText.primary13('hello'))),
        ),
      );
      await tester.pumpAndSettle();
      return tester.state(find.byType(SailApp));
    }

    // Resolve from the rendered text's own context so we read the scaler the
    // app actually applies, not the test binding's ambient one.
    TextScaler scalerAtText(WidgetTester tester) {
      return MediaQuery.textScalerOf(tester.element(find.text('hello')));
    }

    testWidgets('a saved scale is restored on launch and reaches the text scaler', (tester) async {
      await GetIt.I.get<ClientSettings>().setValue(FontScaleSetting(newValue: 1.5));

      await pumpApp(tester);

      expect(scalerAtText(tester).scale(10), 15);
    });

    testWidgets('defaults to unscaled when nothing is saved', (tester) async {
      await pumpApp(tester);

      expect(scalerAtText(tester).scale(10), 10);
    });

    testWidgets('loadFontScale persists the new scale', (tester) async {
      final appState = await pumpApp(tester);

      await appState.loadFontScale(1.25);

      final stored = await GetIt.I.get<ClientSettings>().getValue(FontScaleSetting());
      expect(stored.value, 1.25);
    });

    testWidgets('an off-step scale is snapped before it is stored', (tester) async {
      final appState = await pumpApp(tester);

      await appState.loadFontScale(1.13);

      final stored = await GetIt.I.get<ClientSettings>().getValue(FontScaleSetting());
      expect(stored.value, 1.1);
    });
  });

  group('FontSizeSlider', () {
    setUp(() async {
      await GetIt.I.reset();
      final log = Logger(level: Level.warning);
      final store = MockStore();

      GetIt.I.registerSingleton<Logger>(log);
      GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: store, log: log));
      GetIt.I.registerSingleton<BitwindowClientSettings>(BitwindowClientSettings(store: store, log: log));
      GetIt.I.registerSingleton<SettingsProvider>(await SettingsProvider.create());
    });

    tearDown(() async {
      await GetIt.I.reset();
    });

    testWidgets('dragging to the far end persists the largest scale and rescales text', (tester) async {
      final provider = GetIt.I.get<SettingsProvider>();

      await tester.pumpWidget(
        SailApp(
          dense: false,
          accentColor: SailColorScheme.orange,
          log: GetIt.I.get<Logger>(),
          builder: (_) => MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  FontSizeSlider(settingsProvider: provider),
                  SailText.primary13('hello'),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('100%'), findsOneWidget);

      final box = tester.getRect(find.byType(SailSlider));
      await tester.tapAt(Offset(box.right - 1, box.center.dy));
      await tester.pumpAndSettle();

      expect(provider.fontScale, sailFontScales.last);
      expect(find.text('200%'), findsOneWidget);
      expect(MediaQuery.textScalerOf(tester.element(find.text('hello'))).scale(10), 20);

      final stored = await GetIt.I.get<ClientSettings>().getValue(FontScaleSetting());
      expect(stored.value, sailFontScales.last);
    });
  });

  group('SettingsProvider.updateFontScale', () {
    setUp(() async {
      await GetIt.I.reset();
      final log = Logger(level: Level.warning);
      final store = MockStore();

      GetIt.I.registerSingleton<Logger>(log);
      GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: store, log: log));
      GetIt.I.registerSingleton<BitwindowClientSettings>(BitwindowClientSettings(store: store, log: log));
    });

    tearDown(() async {
      await GetIt.I.reset();
    });

    test('persists and notifies, and reloads on next create', () async {
      final provider = await SettingsProvider.create();
      expect(provider.fontScale, 1.0);

      var notified = 0;
      provider.addListener(() => notified++);

      await provider.updateFontScale(1.75);
      expect(provider.fontScale, 1.75);
      expect(notified, greaterThan(0));

      final reloaded = await SettingsProvider.create();
      expect(reloaded.fontScale, 1.75);
    });
  });
}
