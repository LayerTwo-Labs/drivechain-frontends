import 'package:sail_ui/sail_ui.dart';

/// CoinShift configuration implemented using GenericAppConfig.
class CoinShiftConfig extends GenericAppConfig {
  CoinShiftConfig() : super(appName: 'CoinShift');

  CoinShiftConfig.fromConfig(CoinShiftConfig super.other) : super.fromConfig();

  static CoinShiftConfig parse(String content) {
    final generic = GenericAppConfig.parse(content, appName: 'CoinShift');
    final config = CoinShiftConfig();
    config.settings = generic.settings;
    return config;
  }
}
