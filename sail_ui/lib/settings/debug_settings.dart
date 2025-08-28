import 'package:sail_ui/sail_ui.dart';

extension DebugModeStringer on bool {
  String toReadable() {
    switch (this) {
      case true:
        return 'Enabled';
      case false:
        return 'Disabled';
    }
  }
}

class DebugModeSetting extends SettingValue<bool> {
  DebugModeSetting({super.newValue});

  @override
  String get key => 'debug_mode';

  @override
  bool defaultValue() => false;

  @override
  String toJson() {
    return value.toString();
  }

  @override
  bool? fromJson(String jsonString) {
    return jsonString == 'true';
  }

  @override
  SettingValue<bool> withValue([bool? value]) {
    return DebugModeSetting(newValue: value);
  }
}
