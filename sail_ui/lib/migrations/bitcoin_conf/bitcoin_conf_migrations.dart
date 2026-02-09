// Registry of bitcoin conf migrations. Each NNN_name.dart defines a class extending the migration interface.
// When adding a migration: create NNN_name.dart with a class (version in constructor), then add one line below.

import 'package:sail_ui/config/config_migration.dart';
import 'package:sail_ui/models/bitcoin_config.dart';

import '001_new_signet.dart';

List<ConfigMigration<BitcoinConfig>> get bitcoinConfMigrations => [
  Migration001NewSignet(),
];
