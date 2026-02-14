import 'package:sail_ui/config/config_migration.dart';

/// Revert to old signet addnode/blocktime/challenge. Version matches filename (002 -> 2).
class Migration002RevertSignet extends StructuredBitcoinConfMigration {
  Migration002RevertSignet() : super(2, _data);

  // '' = global. 'main' = [main]. 'forknet' = [main]. 'signet'|'test'|'regtest' = that section.
  static const _data = {
    'signet': {
      'addnode': '172.105.148.135:38333',
      'signetblocktime': '60',
      'signetchallenge': '00141551188e5153533b4fdd555449e640d9cc129456',
      'acceptnonstdtxn': '1',
    },
  };
}
