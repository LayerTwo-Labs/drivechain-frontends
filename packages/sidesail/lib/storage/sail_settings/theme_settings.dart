import 'package:collection/collection.dart';
import 'package:sidesail/storage/client_settings.dart';

enum SailThemeValues { light, dark, platform }

extension NextTheme on SailThemeValues {
  SailThemeValues toggleTheme() {
    if (this == SailThemeValues.dark) {
      return SailThemeValues.light;
    } else if (this == SailThemeValues.light) {
      return SailThemeValues.dark;
    } else {
      return SailThemeValues.platform;
    }
  }
}

class ThemeSetting extends SettingValue<SailThemeValues> {
  ThemeSetting({super.newValue});

  @override
  String get key => 'theme';

  @override
  SailThemeValues defaultValue() => SailThemeValues.platform;

  @override
  String toJson() {
    return value.name;
  }

  @override
  SailThemeValues? fromJson(String jsonString) {
    return SailThemeValues.values.firstWhereOrNull(
      (element) => element.name == jsonString,
    );
  }

  @override
  SettingValue<SailThemeValues> withValue([SailThemeValues? value]) {
    return ThemeSetting(
      newValue: value,
    );
  }
}
