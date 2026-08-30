import 'package:bitwindow/models/settings.dart';
import 'package:sail_ui/sail_ui.dart';

/// Local homepage/UI state. Distinct from sidechain_core's [BitwindowSettingValue],
/// which owns the global 'bitwindow_settings' blob over the same store.
class BitwindowSettingsValue extends SettingValue<Settings> {
  @override
  String get key => 'bitwindow_homepage_settings';

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
