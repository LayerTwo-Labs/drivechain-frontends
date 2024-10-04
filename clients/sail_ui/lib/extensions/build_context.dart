import 'package:flutter/material.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/theme/theme_data.dart';

extension BuildContextX on BuildContext {
  SailThemeData get sailTheme => SailTheme.of(this);
  TargetPlatform get platform => Theme.of(this).platform;
  bool get isWindows => platform == TargetPlatform.windows;
  bool get isMacOS => platform == TargetPlatform.macOS;
  bool get isLinux => platform == TargetPlatform.linux;
  bool get isFuchsia => platform == TargetPlatform.fuchsia;
  bool get isLightMode => SailTheme.of(this).isLightMode();
  bool get isDarkMode => !isLightMode;
}
