import 'package:flutter/foundation.dart';
import 'package:sail_ui/sail_ui.dart';

class SailThemeData with Diagnosticable {
  final String name;
  final SailColor colors;

  const SailThemeData({
    required this.name,
    required this.colors,
  });

  bool isLightMode() => name == 'light';

  factory SailThemeData.lightTheme() {
    return SailThemeData(
      name: 'light',
      colors: SailColor.lightTheme(),
    );
  }

  factory SailThemeData.darkTheme() {
    return SailThemeData(
      name: 'dark',
      colors: SailColor.darkTheme(),
    );
  }
}
