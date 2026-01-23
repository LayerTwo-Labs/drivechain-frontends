import 'package:sail_ui/sail_ui.dart';

/// Thunder configuration implemented using GenericAppConfig.
class ThunderConfig extends GenericAppConfig {
  ThunderConfig() : super(appName: 'Thunder');

  ThunderConfig.fromConfig(ThunderConfig super.other) : super.fromConfig();

  static ThunderConfig parse(String content) {
    final generic = GenericAppConfig.parse(content, appName: 'Thunder');
    final config = ThunderConfig();
    config.settings = generic.settings;
    return config;
  }
}
