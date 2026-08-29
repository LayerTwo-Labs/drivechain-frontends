import 'package:sail_ui/sail_ui.dart';

/// Bbc configuration implemented using GenericAppConfig.
class BbcConfig extends GenericAppConfig {
  BbcConfig() : super(appName: 'Big Block Covenant');

  BbcConfig.fromConfig(BbcConfig super.other) : super.fromConfig();

  static BbcConfig parse(String content) {
    final generic = GenericAppConfig.parse(content, appName: 'Big Block Covenant');
    final config = BbcConfig();
    config.settings = generic.settings;
    return config;
  }
}
