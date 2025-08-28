import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SailThemeData with Diagnosticable {
  final SailThemeValues type;
  final SailColor colors;
  final bool dense;

  const SailThemeData({required this.type, required this.colors, required this.dense});

  bool isLightMode() => type == SailThemeValues.light;

  factory SailThemeData.lightTheme(Color primary, bool dense) {
    return SailThemeData(type: SailThemeValues.light, dense: dense, colors: SailColor.lightTheme(primary));
  }

  factory SailThemeData.darkTheme(Color primary, bool dense) {
    return SailThemeData(type: SailThemeValues.dark, dense: dense, colors: SailColor.darkTheme(primary));
  }
}
