import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SailThemeData with Diagnosticable {
  final String name;
  final SailColor colors;
  final bool dense;

  const SailThemeData({
    required this.name,
    required this.colors,
    required this.dense,
  });

  bool isLightMode() => name == 'light';

  factory SailThemeData.lightTheme(Color primary, bool dense) {
    return SailThemeData(
      name: 'light',
      dense: dense,
      colors: SailColor.lightTheme(primary),
    );
  }

  factory SailThemeData.darkTheme(Color primary, bool dense) {
    return SailThemeData(
      name: 'dark',
      dense: dense,
      colors: SailColor.darkTheme(primary),
    );
  }
}
