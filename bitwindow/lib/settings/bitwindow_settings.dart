import 'package:bitwindow/models/settings.dart';
import 'package:sail_ui/sail_ui.dart';

class BitwindowSettingsValue extends SettingValue<Settings> {
  @override
  String get key => 'bitwindow_settings';

  BitwindowSettingsValue({super.newValue});

  @override
  Settings defaultValue() => Settings();

  @override
  Settings? fromJson(String jsonString) {
    try {
      return Settings.fromJson(jsonString);
    } catch (e) {
      return null;
    }
  }

  @override
  String toJson() {
    return value.toJson();
  }

  @override
  SettingValue<Settings> withValue([Settings? value]) {
    return BitwindowSettingsValue(newValue: value);
  }
}
