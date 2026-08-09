import 'package:sidechain_core/sidechain_core.dart';

class UseTestSidechainsSetting extends SettingValue<bool> {
  UseTestSidechainsSetting({super.newValue});

  @override
  String get key => 'use_test_sidechains';

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
    return UseTestSidechainsSetting(newValue: value);
  }
}
