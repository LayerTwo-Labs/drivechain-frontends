import 'dart:ui';

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

  setUp(() async {
    await GetIt.I.reset();
    final log = Logger(level: Level.warning);
    final store = MockStore();

    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<ClientSettings>(
      ClientSettings(store: store, log: log),
    );
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
        builder: (_) => const MaterialApp(home: Scaffold(body: SizedBox())),
      ),
    );
    await tester.pump();
    return tester.state(find.byType(SailApp));
  }

  testWidgets('loadTheme preserves system preference in settings', (tester) async {
    final settings = GetIt.I.get<ClientSettings>();
    await settings.setValue(ThemeSetting(newValue: SailThemeValues.system));

    final appState = await pumpApp(tester);
    await appState.loadTheme(SailThemeValues.system);

    final stored = await settings.getValue(ThemeSetting());
    expect(stored.value, SailThemeValues.system);
  });

  testWidgets('loadTheme resolves system theme for rendering without changing saved preference', (tester) async {
    final settings = GetIt.I.get<ClientSettings>();
    await settings.setValue(ThemeSetting(newValue: SailThemeValues.system));

    final appState = await pumpApp(tester);
    await appState.loadTheme(SailThemeValues.system);

    final brightness = PlatformDispatcher.instance.platformBrightness;
    final expectedRenderedTheme = brightness == Brightness.light ? SailThemeValues.light : SailThemeValues.dark;

    expect(appState.theme.type, expectedRenderedTheme);

    final stored = await settings.getValue(ThemeSetting());
    expect(stored.value, SailThemeValues.system);
  });
}
