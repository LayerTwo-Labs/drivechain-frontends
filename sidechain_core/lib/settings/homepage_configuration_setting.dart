import 'package:sidechain_core/models/homepage_configuration.dart';
import 'package:sidechain_core/settings/client_settings.dart';

class HomepageConfigurationSetting extends SettingValue<HomepageConfiguration> {
  @override
  String get key => 'homepage_configuration';

  HomepageConfigurationSetting({super.newValue});

  @override
  HomepageConfiguration defaultValue() => HomepageConfiguration(widgets: []);

  @override
  HomepageConfiguration? fromJson(String jsonString) {
    try {
      return HomepageConfiguration.fromJson(jsonString);
    } catch (e) {
      return null;
    }
  }

  @override
  String toJson() {
    return value.toJson();
  }

  @override
  SettingValue<HomepageConfiguration> withValue([
    HomepageConfiguration? value,
  ]) {
    return HomepageConfigurationSetting(newValue: value);
  }
}
