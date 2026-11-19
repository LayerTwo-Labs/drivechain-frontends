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

void main() {
  setUp(_register);
  tearDown(() => GetIt.I.reset());

  test('the sidechain window setting is off by default', () async {
    expect(BitwindowSettings().openSidechainsInWindow, isFalse);
    expect(BitwindowSettings.fromJson('{"paranoidMode":true}').openSidechainsInWindow, isFalse);

    final settingsProvider = await SettingsProvider.create();
    expect(settingsProvider.bitwindowSettings.openSidechainsInWindow, isFalse);
  });

  test('the sidechain window setting round-trips and keeps the other settings', () async {
    final settingsProvider = await SettingsProvider.create();
    await settingsProvider.updateParanoidMode(true);
    await settingsProvider.updateOpenSidechainsInWindow(true);

    final global = await GetIt.I.get<BitwindowClientSettings>().getValue(BitwindowSettingValue());
    expect(global.value.openSidechainsInWindow, isTrue);
    expect(global.value.paranoidMode, isTrue);
    expect(BitwindowSettings.fromJson(global.value.toJson()).openSidechainsInWindow, isTrue);

    final reloaded = await SettingsProvider.create();
    expect(reloaded.bitwindowSettings.openSidechainsInWindow, isTrue);
  });
}
