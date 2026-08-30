import 'package:bitwindow/providers/bitwindow_settings_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

import 'mocks/store_mock.dart';

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

  test('saving homepage state leaves paranoid mode and theme intact', () async {
    final settingsProvider = await SettingsProvider.create();
    await settingsProvider.updateParanoidMode(true);
    await settingsProvider.updateThemeStyle(SailThemeStyle.win95);

    final provider = await _loadedProvider();
    await provider.markHomepageAsConfigured();

    final global = await GetIt.I.get<BitwindowClientSettings>().getValue(BitwindowSettingValue());
    expect(global.value.paranoidMode, isTrue);
    expect(global.value.themeStyle, SailThemeStyle.win95.id);
  });

  test('updating paranoid mode leaves homepage state intact', () async {
    final provider = await _loadedProvider();
    await provider.markHomepageAsConfigured();

    final settingsProvider = await SettingsProvider.create();
    await settingsProvider.updateParanoidMode(true);

    final reloaded = await _loadedProvider();
    expect(reloaded.settings.hasConfiguredHomepage, isTrue);
  });
}
