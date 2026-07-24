import 'package:sail_ui/sail_ui.dart';

class MiningBannerDismissedSetting extends SettingValue<bool> {
  MiningBannerDismissedSetting({super.newValue});

  @override
  String get key => 'mining_banner_dismissed';

  @override
  bool defaultValue() => false;

  @override
  String toJson() => value.toString();

  @override
  bool? fromJson(String jsonString) => jsonString == 'true';

  @override
  SettingValue<bool> withValue([bool? value]) => MiningBannerDismissedSetting(newValue: value);
}
