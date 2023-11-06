import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SailThemeData with Diagnosticable {
  final String name;
  final SailColor colors;

  const SailThemeData({
    required this.name,
    required this.colors,
  });

  bool isLightMode() => name == 'light';

  factory SailThemeData.lightTheme(Color primary) {
    return SailThemeData(
      name: 'light',
      colors: SailColor.lightTheme(primary),
    );
  }

  factory SailThemeData.darkTheme(Color primary) {
    return SailThemeData(
      name: 'dark',
      colors: SailColor.darkTheme(primary),
    );
  }
}
