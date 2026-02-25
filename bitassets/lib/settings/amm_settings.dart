import 'package:sail_ui/sail_ui.dart';

class SlippageToleranceSetting extends SettingValue<double> {
  SlippageToleranceSetting({super.newValue});

  @override
  String get key => 'amm_slippage_tolerance';

  @override
  double defaultValue() => 0.5;

  @override
  double? fromJson(String jsonString) {
    try {
      return double.parse(jsonString);
    } catch (_) {
      return null;
    }
  }

  @override
  String toJson() {
    return value.toString();
  }

  @override
  SettingValue<double> withValue([double? value]) {
    return SlippageToleranceSetting(newValue: value);
  }
}
