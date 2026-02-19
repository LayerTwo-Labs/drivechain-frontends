// Config migration system for BitWindow config files (bitwindow-bitcoin.conf, bitwindow-enforcer.conf).
// When parameters change, add a new migration with the next version number.
// On load, migrations with version > stored version run in order, then version is updated.
// Bitcoin conf migrations live in migrations/bitcoin_conf/NNN_name.dart; version from filename (001 -> 1).
// Registry: migrations/bitcoin_conf/bitcoin_conf_migrations.dart
library;

import 'package:sail_ui/models/bitcoin_config.dart';

/// Comment prefix for forknet config version. Stored in bitwindow-forknet.conf.
const String kForknetConfVersionCommentPrefix = '# bitwindow-forknet-conf-version=';

/// Comment prefix for mainnet config version. Stored in bitwindow-mainnet.conf.
const String kMainnetConfVersionCommentPrefix = '# bitwindow-mainnet-conf-version=';

/// A single migration step: runs when config version < [version].
abstract class ConfigMigration<T> {
  int get version;
  void apply(T config);
}

/// Section name -> key->value. Use '' for global (no [section]).
/// Network sections: 'main', 'forknet' (writes to [main]), 'signet', 'test', 'regtest'.
typedef BitcoinConfMigrationData = Map<String, Map<String, String>>;

/// [main] section name in config file. 'forknet' in migration data is applied to [main].
const String _kMainSection = 'main';

/// Structured bitcoin conf migration: applies [changes] (section -> key -> value). Overwrites or adds.
/// Section 'forknet' is applied to [main] ONLY if [isForknet] is true.
/// Use [applyForknetToConfig] to migrate bitwindow-forknet.conf separately.
class StructuredBitcoinConfMigration implements ConfigMigration<BitcoinConfig> {
  StructuredBitcoinConfMigration(this.version, this.changes);
  @override
  final int version;
  final BitcoinConfMigrationData changes;

  /// Apply migration. If [isForknet] is true, 'forknet' data applies to [main].
  /// If false, 'mainnet' data applies to [main].
  /// The other is skipped (migrated via separate config file).
  void applyWithNetwork(BitcoinConfig config, {required bool isForknet}) {
    for (final sectionEntry in changes.entries) {
      var section = sectionEntry.key.isEmpty ? null : sectionEntry.key;
      if (section == 'forknet') {
        if (!isForknet) continue; // Skip forknet data if not on forknet
        section = _kMainSection;
      } else if (section == 'mainnet') {
        if (isForknet) continue; // Skip mainnet data if on forknet
        section = _kMainSection;
      }
      for (final kv in sectionEntry.value.entries) {
        config.setSetting(kv.key, kv.value, section: section);
      }
    }
  }

  @override
  void apply(BitcoinConfig config) {
    // Default: apply all including forknet (legacy behavior, assumes forknet)
    applyWithNetwork(config, isForknet: true);
  }

  /// Get forknet-specific changes (for migrating bitwindow-forknet.conf).
  Map<String, String>? get forknetChanges => changes['forknet'];

  /// Get mainnet-specific changes (for migrating bitwindow-mainnet.conf).
  Map<String, String>? get mainnetChanges => changes['mainnet'];
}

/// Runs all migrations where migration.version > stored version.
/// When no version line is present in the file, getVersion returns 0 (legacy),
/// so every migration runs (migrate from scratch).
/// Sets config version to [currentVersion]. Returns true if any migration ran.
bool runConfigMigrations<T>(
  T config,
  int currentVersion,
  int Function(T) getVersion,
  void Function(T, int) setVersion,
  List<ConfigMigration<T>> migrations,
) {
  final stored = getVersion(config);
  // stored == 0 means no version line (legacy); run all migrations
  final toRun = migrations.where((m) => m.version > stored).toList()..sort((a, b) => a.version.compareTo(b.version));
  for (final m in toRun) {
    m.apply(config);
  }
  setVersion(config, currentVersion);
  return toRun.isNotEmpty;
}

/// Run bitcoin conf migrations with network awareness.
/// If [isForknet], forknet data applies to [main]. Otherwise skipped.
bool runBitcoinConfMigrations(
  BitcoinConfig config,
  int currentVersion,
  List<ConfigMigration<BitcoinConfig>> migrations, {
  required bool isForknet,
}) {
  final stored = config.configVersion;
  final toRun = migrations.where((m) => m.version > stored).toList()..sort((a, b) => a.version.compareTo(b.version));
  for (final m in toRun) {
    if (m is StructuredBitcoinConfMigration) {
      m.applyWithNetwork(config, isForknet: isForknet);
    } else {
      m.apply(config);
    }
  }
  config.configVersion = currentVersion;
  return toRun.isNotEmpty;
}

/// Run forknet migrations on a ForknetConfig (bitwindow-forknet.conf).
/// Extracts 'forknet' data from each migration and applies to the config.
bool runForknetConfMigrations(
  ForknetConfig config,
  int currentVersion,
  List<ConfigMigration<BitcoinConfig>> migrations,
) {
  final stored = config.version;
  final toRun = migrations.where((m) => m.version > stored).toList()..sort((a, b) => a.version.compareTo(b.version));
  for (final m in toRun) {
    if (m is StructuredBitcoinConfMigration) {
      final forknetData = m.forknetChanges;
      if (forknetData != null) {
        for (final entry in forknetData.entries) {
          config.settings[entry.key] = entry.value;
        }
      }
    }
  }
  config.version = currentVersion;
  return toRun.isNotEmpty;
}

/// Run mainnet migrations on a MainnetConfig (bitwindow-mainnet.conf).
/// Extracts 'mainnet' data from each migration and applies to the config.
bool runMainnetConfMigrations(
  MainnetConfig config,
  int currentVersion,
  List<ConfigMigration<BitcoinConfig>> migrations,
) {
  final stored = config.version;
  final toRun = migrations.where((m) => m.version > stored).toList()..sort((a, b) => a.version.compareTo(b.version));
  for (final m in toRun) {
    if (m is StructuredBitcoinConfMigration) {
      final mainnetData = m.mainnetChanges;
      if (mainnetData != null) {
        for (final entry in mainnetData.entries) {
          config.settings[entry.key] = entry.value;
        }
      }
    }
  }
  config.version = currentVersion;
  return toRun.isNotEmpty;
}

/// Forknet config: simple key-value pairs stored in bitwindow-forknet.conf.
/// Includes version for migration tracking.
class ForknetConfig {
  Map<String, String> settings = {};
  int version = 0;

  ForknetConfig();

  /// Parse forknet config file content.
  static ForknetConfig parse(String content) {
    final config = ForknetConfig();
    for (final line in content.split('\n')) {
      final trimmed = line.trim();

      // Parse version comment
      if (trimmed.startsWith(kForknetConfVersionCommentPrefix)) {
        final v = int.tryParse(trimmed.substring(kForknetConfVersionCommentPrefix.length).trim());
        if (v != null && v >= 0) config.version = v;
        continue;
      }

      // Skip empty lines and other comments
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

      // Parse key=value
      final equals = trimmed.indexOf('=');
      if (equals > 0) {
        final key = trimmed.substring(0, equals).trim();
        final value = trimmed.substring(equals + 1).trim();
        config.settings[key] = value;
      }
    }
    return config;
  }

  /// Serialize to file content.
  String serialize() {
    final buffer = StringBuffer();
    buffer.writeln('$kForknetConfVersionCommentPrefix$version');
    buffer.writeln('# Saved [main] section for forknet');
    for (final entry in settings.entries) {
      buffer.writeln('${entry.key}=${entry.value}');
    }
    return buffer.toString();
  }
}

/// Mainnet config: simple key-value pairs stored in bitwindow-mainnet.conf.
/// Includes version for migration tracking.
class MainnetConfig {
  Map<String, String> settings = {};
  int version = 0;

  MainnetConfig();

  /// Parse mainnet config file content.
  static MainnetConfig parse(String content) {
    final config = MainnetConfig();
    for (final line in content.split('\n')) {
      final trimmed = line.trim();

      // Parse version comment
      if (trimmed.startsWith(kMainnetConfVersionCommentPrefix)) {
        final v = int.tryParse(trimmed.substring(kMainnetConfVersionCommentPrefix.length).trim());
        if (v != null && v >= 0) config.version = v;
        continue;
      }

      // Skip empty lines and other comments
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

      // Parse key=value
      final equals = trimmed.indexOf('=');
      if (equals > 0) {
        final key = trimmed.substring(0, equals).trim();
        final value = trimmed.substring(equals + 1).trim();
        config.settings[key] = value;
      }
    }
    return config;
  }

  /// Serialize to file content.
  String serialize() {
    final buffer = StringBuffer();
    buffer.writeln('$kMainnetConfVersionCommentPrefix$version');
    buffer.writeln('# Saved [main] section for mainnet');
    for (final entry in settings.entries) {
      buffer.writeln('${entry.key}=${entry.value}');
    }
    return buffer.toString();
  }
}
