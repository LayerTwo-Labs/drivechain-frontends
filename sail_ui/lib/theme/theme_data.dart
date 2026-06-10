import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SailThemeData with Diagnosticable {
  final SailThemeValues type;
  final SailColor colors;
  final bool dense;
  final SailFontValues font;
  final SailThemeStyle style;
  final SailChrome chrome;

  const SailThemeData({
    required this.type,
    required this.colors,
    required this.dense,
    required this.font,
    required this.style,
    required this.chrome,
  });

  bool isLightMode() => type == SailThemeValues.light;

  factory SailThemeData.lightTheme(
    Color primary,
    bool dense,
    SailFontValues font, [
    SailThemeStyle style = SailThemeStyle.sail,
  ]) {
    final bundle = sailBundleFor(style);
    return SailThemeData(
      type: SailThemeValues.light,
      dense: dense,
      colors: bundle.palette(primary, isLight: true),
      font: font,
      style: style,
      chrome: bundle.chrome,
    );
  }

  factory SailThemeData.darkTheme(
    Color primary,
    bool dense,
    SailFontValues font, [
    SailThemeStyle style = SailThemeStyle.sail,
  ]) {
    final bundle = sailBundleFor(style);
    return SailThemeData(
      type: SailThemeValues.dark,
      dense: dense,
      colors: bundle.palette(primary, isLight: false),
      font: font,
      style: style,
      chrome: bundle.chrome,
    );
  }
}
