import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import 'package:sail_ui/sail_ui.dart';

const _configFileName = 'chains_config.json';
const _assetsPrefix = 'packages/sail_ui/assets';

/// Provides binary/sidechain configuration loaded from a JSON file on disk.
///
/// Data flows in one direction: file → listeners.
/// When the app needs to update values (e.g. hashes after download),
/// it writes to the file, and the file watcher picks up the change.
///
/// ## Migration system
///
/// Migration files live in `assets/migrations/` as numbered JSON files:
/// `001_chains_config.json`, `002_chains_config.json`, etc. The highest number
/// is the current config and must mirror the bundled `chains_config.json`
/// (same `version`, same content).
///
/// On startup, if the on-disk config version is behind the latest migration,
/// the latest config is adopted wholesale. Bump `version` and add a matching
/// migration file whenever the bundled config changes. Paranoid mode skips
/// this so manual edits survive.
class ChainsConfigProvider extends ChangeNotifier {
  final log = Logger(level: Level.info);
  final File configFile;
  StreamSubscription<FileSystemEvent>? _fileWatcher;
  Timer? _debounceTimer;
  Map<String, dynamic> _rawConfig = {};

  ChainsConfigProvider._({required this.configFile});

  /// Create the provider: seed config if missing, run migrations,
  /// load the JSON, and start the file watcher.
  static Future<ChainsConfigProvider> create({
    required Directory appDir,
    bool paranoidMode = false,
  }) async {
    final configFile = File(path.join(appDir.path, _configFileName));

    // Copy seed config from bundled assets if the file doesn't exist yet
    if (!configFile.existsSync()) {
      try {
        final seedData = await rootBundle.loadString(
          '$_assetsPrefix/$_configFileName',
        );
        await configFile.writeAsString(seedData);
      } catch (e) {
        // If asset loading fails (e.g. in tests), create a minimal config
        Logger(
          level: Level.warning,
        ).w('Failed to copy seed config from assets: $e');
        await configFile.writeAsString('{"version": 1, "binaries": {}}');
      }
    }

    // Run migrations before loading (skip in paranoid mode)
    if (!paranoidMode) {
      await _runMigrations(configFile);
    } else {
      Logger(
        level: Level.info,
      ).i('Paranoid mode: skipping chains_config.json migrations');
    }

    final provider = ChainsConfigProvider._(configFile: configFile);
    await provider._loadConfig();
    provider._setupFileWatcher();
    return provider;
  }

  // ---------------------------------------------------------------------------
  // Migration system
  // ---------------------------------------------------------------------------

  /// Discover available migration numbers from bundled assets.
  /// Returns sorted list of migration numbers (e.g. [1, 2, 3]).
  static Future<List<int>> _discoverMigrations() async {
    final migrations = <int>[];

    // Probe for migration files sequentially until one is missing
    for (var i = 1; i <= 999; i++) {
      final name = '${i.toString().padLeft(3, '0')}_chains_config.json';
      try {
        await rootBundle.loadString('$_assetsPrefix/migrations/$name');
        migrations.add(i);
      } catch (_) {
        break; // No more migrations
      }
    }

    return migrations;
  }

  /// Load a migration file by number.
  static Future<Map<String, dynamic>> _loadMigration(int number) async {
    final name = '${number.toString().padLeft(3, '0')}_chains_config.json';
    final data = await rootBundle.loadString('$_assetsPrefix/migrations/$name');
    return json.decode(data) as Map<String, dynamic>;
  }

  /// Run pending migrations on the user's config file.
  ///
  /// Pre-1.0, chains_config.json is app-owned: when the bundled config is
  /// newer than the on-disk one, we adopt it wholesale. Anyone who wants to
  /// keep manual edits enables paranoid mode, which skips this entirely (see
  /// [create]). The previous "replace only if it matches a baseline" scheme
  /// could never fire once the asset changed without a matching version bump,
  /// which left installs frozen on stale config.
  static Future<void> _runMigrations(File configFile) async {
    final log = Logger(level: Level.info);

    try {
      final contents = await configFile.readAsString();
      final userConfig = json.decode(contents) as Map<String, dynamic>;
      final currentVersion = userConfig['version'] as int? ?? 0;

      final available = await _discoverMigrations();
      if (available.isEmpty) return;

      final latestVersion = available.last;
      if (currentVersion >= latestVersion) return;

      log.i('Config version $currentVersion → $latestVersion: adopting latest config');

      final latest = await _loadMigration(latestVersion);
      final encoder = const JsonEncoder.withIndent('  ');
      await configFile.writeAsString(encoder.convert(latest));
    } catch (e) {
      log.w('Migration failed (config unchanged): $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Raw config map for a specific binary key (e.g. "thunder").
  Map<String, dynamic>? getConfig(String binaryKey) {
    final binaries = _rawConfig['binaries'] as Map<String, dynamic>?;
    return binaries?[binaryKey] as Map<String, dynamic>?;
  }

  /// Build all Binary instances from the current JSON config.
  List<Binary> buildBinaries() {
    final binaries = _rawConfig['binaries'] as Map<String, dynamic>? ?? {};
    final result = <Binary>[];
    for (final entry in binaries.entries) {
      try {
        result.add(
          binaryFromJson(entry.key, entry.value as Map<String, dynamic>),
        );
      } catch (e) {
        log.e('Failed to parse binary "${entry.key}" from config: $e');
      }
    }
    return result;
  }

  /// Build a single Binary by its JSON key (e.g. "thunder").
  Binary? buildBinary(String key) {
    final config = getConfig(key);
    if (config == null) return null;
    try {
      return binaryFromJson(key, config);
    } catch (e) {
      log.e('Failed to parse binary "$key" from config: $e');
      return null;
    }
  }

  /// Build a single Binary by its BinaryType.
  Binary? buildBinaryByType(BinaryType type) {
    return buildBinary(binaryTypeToJsonKey(type));
  }

  /// Write hash and size data for a binary back to the config file.
  /// The file watcher will pick up the change and notify listeners.
  Future<void> updateHashes(
    String binaryKey,
    String os,
    String sha256,
    int size,
  ) async {
    final binaries = _rawConfig['binaries'] as Map<String, dynamic>? ?? {};
    final binaryConfig = binaries[binaryKey] as Map<String, dynamic>?;
    if (binaryConfig == null) return;

    final hashes = (binaryConfig['hashes'] as Map<String, dynamic>?) ?? {};
    hashes[os] = {'sha256': sha256, 'size': size};
    binaryConfig['hashes'] = hashes;

    await _writeConfig();
  }

  /// Update a specific field for a binary in the config file.
  Future<void> updateBinaryField(
    String binaryKey,
    String field,
    dynamic value,
  ) async {
    final binaries = _rawConfig['binaries'] as Map<String, dynamic>? ?? {};
    final binaryConfig = binaries[binaryKey] as Map<String, dynamic>?;
    if (binaryConfig == null) return;

    binaryConfig[field] = value;
    await _writeConfig();
  }

  // ---------------------------------------------------------------------------
  // Internal
  // ---------------------------------------------------------------------------

  Future<void> _loadConfig() async {
    try {
      final contents = await configFile.readAsString();
      _rawConfig = json.decode(contents) as Map<String, dynamic>;
    } catch (e) {
      log.e('Failed to load chains config: $e');
      _rawConfig = {'version': 1, 'binaries': {}};
    }
  }

  Future<void> _writeConfig() async {
    final encoder = const JsonEncoder.withIndent('  ');
    await configFile.writeAsString(encoder.convert(_rawConfig));
    // File watcher will pick up the change and call notifyListeners()
  }

  void _setupFileWatcher() {
    try {
      _fileWatcher = configFile.parent
          .watch(events: FileSystemEvent.modify | FileSystemEvent.create)
          .where((event) => path.basename(event.path) == _configFileName)
          .listen((event) {
            _debounceTimer?.cancel();
            _debounceTimer = Timer(const Duration(milliseconds: 300), () {
              _reloadConfig();
            });
          });
    } catch (e) {
      log.w('Failed to setup file watcher for chains config: $e');
    }
  }

  Future<void> _reloadConfig() async {
    try {
      final contents = await configFile.readAsString();
      final newConfig = json.decode(contents) as Map<String, dynamic>;
      if (!mapEquals(_rawConfig, newConfig)) {
        _rawConfig = newConfig;
        notifyListeners();
      }
    } catch (e) {
      log.e('Failed to reload chains config: $e');
      // Keep old config on parse error (user might be mid-edit)
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _fileWatcher?.cancel();
    super.dispose();
  }
}
