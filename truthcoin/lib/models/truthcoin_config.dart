import 'package:sail_ui/sail_ui.dart';

/// Truthcoin configuration implemented using GenericAppConfig.
class TruthcoinConfig extends GenericAppConfig {
  TruthcoinConfig() : super(appName: 'Truthcoin');

  TruthcoinConfig.fromConfig(TruthcoinConfig super.other) : super.fromConfig();

  static TruthcoinConfig parse(String content) {
    final generic = GenericAppConfig.parse(content, appName: 'Truthcoin');
    final config = TruthcoinConfig();
    config.settings = generic.settings;
    return config;
  }
}
