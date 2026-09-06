import 'package:bitwindow/models/settings.dart';
import 'package:bitwindow/providers/bitwindow_settings_provider.dart';
import 'package:bitwindow/settings/bitwindow_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/store_mock.dart';

/// main.dart backs both settings objects with one store, so a shared key
/// makes the two settings clobber each other.
void _register() {
  final store = MockStore();
  final log = Logger();
  GetIt.I.registerLazySingleton<Logger>(() => log);
  GetIt.I.registerLazySingleton<ClientSettings>(() => ClientSettings(store: store, log: log));
  GetIt.I.registerLazySingleton<BitwindowClientSettings>(() => BitwindowClientSettings(store: store, log: log));
}

Future<BitwindowSettingsProvider> _loadedProvider() async {
  final provider = BitwindowSettingsProvider();
  while (provider.isLoading) {
    await Future<void>.delayed(Duration.zero);
  }
  return provider;
}

void main() {
  setUp(_register);
  tearDown(() => GetIt.I.reset());

  test('saving homepage state leaves paranoid mode intact', () async {
    final settingsProvider = await SettingsProvider.create();
    await settingsProvider.updateParanoidMode(true);

    final provider = await _loadedProvider();
    await provider.markHomepageAsConfigured();

    final global = await GetIt.I.get<BitwindowClientSettings>().getValue(BitwindowSettingValue());
    expect(global.value.paranoidMode, isTrue);

    final homepage = await GetIt.I.get<ClientSettings>().getValue(BitwindowSettingsValue());
    expect(homepage.value.hasConfiguredHomepage, isTrue);
  });

  test('updating paranoid mode leaves homepage state intact', () async {
    final provider = await _loadedProvider();
    await provider.markHomepageAsConfigured();

    final settingsProvider = await SettingsProvider.create();
    await settingsProvider.updateParanoidMode(true);

    final reloaded = await _loadedProvider();
    expect(reloaded.settings.hasConfiguredHomepage, isTrue);
  });

  test('homepage state stored under the old key is migrated', () async {
    final store = GetIt.I.get<ClientSettings>().store;
    await store.setString(
      'bitwindow_settings',
      Settings(configureHomeButtonPressCount: 3, hasConfiguredHomepage: true).toJson(),
    );

    final provider = await _loadedProvider();
    expect(provider.settings.hasConfiguredHomepage, isTrue);
    expect(provider.settings.configureHomeButtonPressCount, 3);
  });

  test('a global settings blob under the old key is not migrated or dropped', () async {
    final store = GetIt.I.get<ClientSettings>().store;
    await store.setString('bitwindow_settings', BitwindowSettings(paranoidMode: true).toJson());

    final provider = await _loadedProvider();
    expect(provider.settings.hasConfiguredHomepage, isFalse);

    final global = await GetIt.I.get<BitwindowClientSettings>().getValue(BitwindowSettingValue());
    expect(global.value.paranoidMode, isTrue);
  });
}
