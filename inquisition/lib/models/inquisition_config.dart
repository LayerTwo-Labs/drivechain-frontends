import 'package:sail_ui/sail_ui.dart';

/// Inquisition configuration implemented using GenericAppConfig.
class InquisitionConfig extends GenericAppConfig {
  InquisitionConfig() : super(appName: 'Inquisition');

  InquisitionConfig.fromConfig(InquisitionConfig super.other) : super.fromConfig();

  static InquisitionConfig parse(String content) {
    final generic = GenericAppConfig.parse(content, appName: 'Inquisition');
    final config = InquisitionConfig();
    config.settings = generic.settings;
    return config;
  }
}
