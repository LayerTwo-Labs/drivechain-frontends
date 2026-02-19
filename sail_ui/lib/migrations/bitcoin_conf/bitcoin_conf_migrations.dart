// Registry of bitcoin conf migrations. Each NNN_name.dart defines a class extending the migration interface.
// When adding a migration: create NNN_name.dart with a class (version in constructor), import it, and add to the list.
// Version is computed automatically from the highest migration version - no manual bump needed.

import 'dart:math';

import 'package:sail_ui/config/config_migration.dart';
import 'package:sail_ui/migrations/bitcoin_conf/001_new_signet.dart';
import 'package:sail_ui/migrations/bitcoin_conf/002_revert_signet.dart';
import 'package:sail_ui/migrations/bitcoin_conf/003_new_signet_again.dart';
import 'package:sail_ui/models/bitcoin_config.dart';

List<ConfigMigration<BitcoinConfig>> get bitcoinConfMigrations => [
  Migration001NewSignet(),
  Migration002RevertSignet(),
  Migration003NewSignetAgain(),
];

/// Current config version, derived from the highest migration version.
int get bitcoinConfMigrationsVersion => bitcoinConfMigrations.map((m) => m.version).reduce(max);
