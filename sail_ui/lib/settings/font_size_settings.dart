import 'package:sail_ui/sail_ui.dart';

/// Selectable text scales, smallest to largest. Capped at 2.0 because
/// [SailText] clamps the scaler there.
const sailFontScales = <double>[0.8, 0.9, 1.0, 1.1, 1.25, 1.5, 1.75, 2.0];

class FontScaleSetting extends SettingValue<double> {
  FontScaleSetting({super.newValue});

  @override
  String get key => 'font_scale';

  @override
  double defaultValue() => 1.0;

  @override
  String toJson() {
    return value.toString();
  }

  @override
  double? fromJson(String jsonString) {
    final parsed = double.tryParse(jsonString);
    if (parsed == null) {
      return null;
    }
    return nearestSailFontScale(parsed);
  }

  @override
  SettingValue<double> withValue([double? value]) {
    return FontScaleSetting(newValue: value == null ? null : nearestSailFontScale(value));
  }
}

/// Snaps an arbitrary scale onto [sailFontScales]. The slider emits raw
/// floats, so every value is rounded to a known step before it is stored.
double nearestSailFontScale(double value) {
  return sailFontScales.reduce(
    (a, b) => (a - value).abs() <= (b - value).abs() ? a : b,
  );
}
