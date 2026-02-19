import 'package:sail_ui/config/config_migration.dart';

/// New signet addnode/blocktime/challenge. Version matches filename (001 -> 1).
class Migration003NewSignetAgain extends StructuredBitcoinConfMigration {
  Migration003NewSignetAgain() : super(3, _data);

  // '' = global. 'main' = [main]. 'forknet' = [main]. 'signet'|'test'|'regtest' = that section.
  static const _data = {
    'signet': {
      'addnode': '172.105.148.135:38333',
      'signetblocktime': '600',
      'signetchallenge': 'a91484fa7c2460891fe5212cb08432e21a4207909aa987',
    },
  };
}
