import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sidechain_core/settings/client_settings.dart';
import 'package:sidechain_core/settings/hash_plaintext_settings.dart';
import 'package:sidechain_core/settings/secure_store.dart';

class _Store implements KeyValueStore {
  final Map<String, String> values = {};

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> setString(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<void> update(String key, String Function(String? current) change) async {
    await setString(key, change(await getString(key)));
  }
}

void main() {
  late _Store appStore;
  late _Store bitwindowStore;

  setUp(() {
    final log = Logger();
    appStore = _Store();
    bitwindowStore = _Store();
    GetIt.I.registerSingleton<Logger>(log);
    GetIt.I.registerSingleton<ClientSettings>(ClientSettings(store: appStore, log: log));
    GetIt.I.registerSingleton<BitwindowClientSettings>(BitwindowClientSettings(store: bitwindowStore, log: log));
  });

  tearDown(GetIt.I.reset);

  // A name one app deciphers must show in the others, so the mapping lives in
  // the one store that every app opens.
  test('a saved name lands in the bitwindow store', () async {
    await HashNameMappingSetting().saveMapping('ecash');

    expect(bitwindowStore.values.keys, contains(HashNameMappingSetting().key));
    expect(appStore.values, isEmpty);
  });

  test('a name saved by one app reads back through the shared store', () async {
    await HashNameMappingSetting().saveMapping('ecash');

    final read = await HashNameMappingSetting.settings.getValue(HashNameMappingSetting());

    expect(read.value.values.map((mapping) => mapping.name), ['ecash']);
  });

  // Two apps read the whole map, add one name, and write it back. The merge
  // runs under the store's lock, so neither drops the other one's name.
  test('two saves at the same time keep both names', () async {
    final dir = await Directory.systemTemp.createTemp('shared-names-');
    addTearDown(() => dir.delete(recursive: true));
    await GetIt.I.unregister<BitwindowClientSettings>();
    GetIt.I.registerSingleton<BitwindowClientSettings>(
      BitwindowClientSettings(store: FileStorage.fromDirectory(dir), log: GetIt.I.get<Logger>()),
    );

    await Future.wait([
      HashNameMappingSetting().saveMapping('alpha'),
      HashNameMappingSetting().saveMapping('beta'),
    ]);

    final read = await HashNameMappingSetting.settings.getValue(HashNameMappingSetting());

    expect(read.value.values.map((mapping) => mapping.name).toSet(), {'alpha', 'beta'});
  });

  test('a name in the app store alone stays unknown', () async {
    await GetIt.I.get<ClientSettings>().setValue(
      HashNameMappingSetting(newValue: {'a' * 64: HashMapping(name: 'stale')}),
    );

    final read = await HashNameMappingSetting.settings.getValue(HashNameMappingSetting());

    expect(read.value, isEmpty);
  });
}
