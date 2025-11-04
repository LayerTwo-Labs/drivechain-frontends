import 'package:sail_ui/settings/client_settings.dart';

class LastUsedWalletSetting extends SettingValue<String> {
  LastUsedWalletSetting({super.newValue});

  @override
  String get key => 'last_used_wallet_id';

  @override
  String defaultValue() => '';

  @override
  String toJson() {
    return value;
  }

  @override
  String? fromJson(String jsonString) {
    return jsonString.isEmpty ? null : jsonString;
  }

  @override
  SettingValue<String> withValue([String? value]) {
    return LastUsedWalletSetting(newValue: value);
  }
}
