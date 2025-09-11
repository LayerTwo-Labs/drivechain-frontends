import 'package:bitwindow/models/bitwindow_settings.dart';
import 'package:sail_ui/sail_ui.dart';

class BitwindowSettingsValue extends SettingValue<BitwindowSettings> {
  @override
  String get key => 'bitwindow_settings';

  BitwindowSettingsValue({super.newValue});

  @override
  BitwindowSettings defaultValue() => BitwindowSettings();

  @override
  BitwindowSettings? fromJson(String jsonString) {
    try {
      return BitwindowSettings.fromJson(jsonString);
    } catch (e) {
      return null;
    }
  }

  @override
  String toJson() {
    return value.toJson();
  }

  @override
  SettingValue<BitwindowSettings> withValue([BitwindowSettings? value]) {
    return BitwindowSettingsValue(newValue: value);
  }
}
