import 'package:collection/collection.dart';
import 'package:sail_ui/sail_ui.dart';

enum SailFontValues { sourceCodePro, inter }

class FontSetting extends SettingValue<SailFontValues> {
  FontSetting({super.newValue});

  @override
  String get key => 'font';

  @override
  SailFontValues defaultValue() => SailFontValues.inter;

  @override
  String toJson() {
    return value.name;
  }

  @override
  SailFontValues? fromJson(String jsonString) {
    return SailFontValues.values.firstWhereOrNull((element) => element.name == jsonString);
  }

  @override
  SettingValue<SailFontValues> withValue([SailFontValues? value]) {
    return FontSetting(newValue: value);
  }
}
