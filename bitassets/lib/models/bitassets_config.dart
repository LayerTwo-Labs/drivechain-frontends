import 'package:sail_ui/sail_ui.dart';

/// BitAssets configuration implemented using GenericAppConfig.
class BitassetsConfig extends GenericAppConfig {
  BitassetsConfig() : super(appName: 'BitAssets');

  BitassetsConfig.fromConfig(BitassetsConfig super.other) : super.fromConfig();

  static BitassetsConfig parse(String content) {
    final generic = GenericAppConfig.parse(content, appName: 'BitAssets');
    final config = BitassetsConfig();
    config.settings = generic.settings;
    return config;
  }
}
