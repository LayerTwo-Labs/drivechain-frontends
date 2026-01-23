import 'package:sail_ui/sail_ui.dart';

/// BitNames configuration implemented using GenericAppConfig.
class BitnamesConfig extends GenericAppConfig {
  BitnamesConfig() : super(appName: 'BitNames');

  BitnamesConfig.fromConfig(BitnamesConfig super.other) : super.fromConfig();

  static BitnamesConfig parse(String content) {
    final generic = GenericAppConfig.parse(content, appName: 'BitNames');
    final config = BitnamesConfig();
    config.settings = generic.settings;
    return config;
  }
}
