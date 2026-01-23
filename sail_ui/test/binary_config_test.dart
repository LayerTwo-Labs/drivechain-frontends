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

/// Validates that binaries with network-specific downloads have proper
/// extractSubfolder entries to prevent binaries from overwriting each other.
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

  group('Binary configuration validation', () {
    test('unique network files must have extractSubfolder defined', () {
      final configs = <String, DownloadConfig>{
        'BitcoinCore': BitcoinCore().metadata.downloadConfig,
        'Enforcer': Enforcer().metadata.downloadConfig,
        'BitWindow': BitWindow().metadata.downloadConfig,
        'ZSide': ZSide().metadata.downloadConfig,
        'Thunder': Thunder().metadata.downloadConfig,
        'BitNames': BitNames().metadata.downloadConfig,
        'BitAssets': BitAssets().metadata.downloadConfig,
      };

      for (final entry in configs.entries) {
        final binaryName = entry.key;
        final config = entry.value;
        _validateConfig(binaryName, config);
      }
    });
  });
}

void _validateConfig(String binaryName, DownloadConfig config) {
  final files = config.files;
  final extractSubfolder = config.extractSubfolder;

  // Group networks by their file set
  final filesByValue = <String, List<BitcoinNetwork>>{};
  for (final entry in files.entries) {
    final network = entry.key;
    final osFiles = entry.value;
    final fileKey = osFiles.values.join('|');
    filesByValue.putIfAbsent(fileKey, () => []).add(network);
  }

  // Find the "default" file set (used by most networks)
  String? defaultFileKey;
  int maxCount = 0;
  for (final entry in filesByValue.entries) {
    if (entry.value.length > maxCount) {
      maxCount = entry.value.length;
      defaultFileKey = entry.key;
    }
  }

  // Find networks with unique files (not using the default)
  for (final entry in filesByValue.entries) {
    if (entry.key != defaultFileKey) {
      for (final network in entry.value) {
        final hasSubfolder = extractSubfolder?[network] != null;
        expect(
          hasSubfolder,
          isTrue,
          reason:
              '$binaryName has unique download files for ${network.name} '
              'but no extractSubfolder defined. This will cause binaries to '
              'overwrite each other. Add an extractSubfolder entry for ${network.name}.',
        );
      }
    }
  }
}
