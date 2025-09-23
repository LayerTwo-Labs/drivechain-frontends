import 'package:sail_ui/sail_ui.dart';

class MainnetToggleSetting extends SettingValue<bool> {
  MainnetToggleSetting({super.newValue});

  @override
  String get key => 'mainnet_toggle';

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
    return MainnetToggleSetting(newValue: value);
  }
}
