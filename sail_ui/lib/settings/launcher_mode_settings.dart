import 'package:sail_ui/sail_ui.dart';

extension LauncherModeStringer on bool {
  String toReadable() {
    switch (this) {
      case true:
        return 'Enabled';
      case false:
        return 'Disabled';
    }
  }
}

class LauncherModeSetting extends SettingValue<bool> {
  LauncherModeSetting({super.newValue});

  @override
  String get key => 'launcher_mode';

  @override
  bool defaultValue() => true;

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
    return LauncherModeSetting(
      newValue: value,
    );
  }
}
