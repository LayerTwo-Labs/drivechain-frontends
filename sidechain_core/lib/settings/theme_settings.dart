import 'package:collection/collection.dart';
import 'package:sidechain_core/sidechain_core.dart';

/// Identifies a theme bundle. The enum name is the persisted string id.
enum SailThemeStyle { sail, win95, ecash }

extension SailThemeStyleStringer on SailThemeStyle {
  String get id => name;
}

enum SailThemeValues { light, dark, system }

extension NextTheme on SailThemeValues {
  SailThemeValues toggleTheme() {
    if (this == SailThemeValues.dark) {
      return SailThemeValues.light;
    } else if (this == SailThemeValues.light) {
      return SailThemeValues.system;
    } else {
      return SailThemeValues.dark;
    }
  }
}

extension ThemeStringer on SailThemeValues {
  String toReadable() {
    switch (this) {
      case SailThemeValues.dark:
        return 'dark';
      case SailThemeValues.light:
        return 'light';
      case SailThemeValues.system:
        return 'system';
    }
  }
}

class ThemeSetting extends SettingValue<SailThemeValues> {
  ThemeSetting({super.newValue});

  @override
  String get key => 'theme';

  @override
  SailThemeValues defaultValue() => SailThemeValues.system;

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
    return ThemeSetting(newValue: value);
  }
}
