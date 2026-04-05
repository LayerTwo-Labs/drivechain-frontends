import 'package:sail_ui/config/config_migration.dart';

/// Add uacomment to identify BitWindow nodes on the network.
class Migration004Uacomment extends StructuredBitcoinConfMigration {
  Migration004Uacomment() : super(4, _data);

  static const _data = {
    '': {'uacomment': 'BitWindow-0.2'},
  };
}
