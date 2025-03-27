import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SailColor {
  final Color background;
  final Color backgroundSecondary;
  final Color backgroundActionModal;
  final Color popoverBackground;

  final Color formField;
  final Color formFieldBorder;
  final Color divider;
  final Color shadow;
  final Color text;
  final Color textSecondary;
  final Color textTertiary;
  final Color textHint;
  final Color primary;
  final Color icon;
  final Color iconHighlighted;
  final Color error;
  final Color success;
  final Color info;
  final Color orange;
  final Color orangeLight;
  final Color disabledBackground;

  final Color actionHeader;
  final Color chip;

  SailColor({
    required this.background,
    required this.backgroundSecondary,
    required this.backgroundActionModal,
    required this.popoverBackground,
    required this.formField,
    required this.formFieldBorder,
    required this.divider,
    required this.shadow,
    required this.text,
    required this.textSecondary,
    required this.textTertiary,
    required this.textHint,
    required this.primary,
    required this.iconHighlighted,
    required this.icon,
    required this.error,
    required this.success,
    required this.info,
    required this.orange,
    required this.orangeLight,
    required this.actionHeader,
    required this.chip,
    required this.disabledBackground,
  });

  factory SailColor.lightTheme(Color primary) {
    return SailColor(
      background: SailColorScheme.whiteDark,
      backgroundSecondary: SailColorScheme.white,
      backgroundActionModal: SailColorScheme.greyMiddle,
      formField: SailColorScheme.whiteDark,
      formFieldBorder: SailColorScheme.greyMiddle,
      divider: SailColorScheme.greyLight,
      shadow: SailColorScheme.black.withValues(alpha: 0.21),
      text: SailColorScheme.black,
      textSecondary: SailColorScheme.blackLighter,
      textTertiary: SailColorScheme.blackLightest,
      textHint: SailColorScheme.greyMiddle,
      iconHighlighted: primary,
      icon: SailColorScheme.greyDark,
      primary: primary,
      error: SailColorScheme.red,
      success: SailColorScheme.green,
      info: SailColorScheme.blue,
      orange: SailColorScheme.orange,
      orangeLight: SailColorScheme.orangeLight,
      actionHeader: SailColorScheme.whiteDark,
      chip: SailColorScheme.greyMiddle.withValues(alpha: 0.21),
      popoverBackground: SailColorScheme.white,
      disabledBackground: SailColorScheme.greyLight.withValues(alpha: 0.1),
    );
  }
  factory SailColor.darkTheme(Color primary) {
    return SailColor(
      background: SailColorScheme.black,
      backgroundSecondary: SailColorScheme.blackKindaLight,
      backgroundActionModal: SailColorScheme.darkActionModalBackground,
      formField: SailColorScheme.blackLightest,
      formFieldBorder: SailColorScheme.greyDark,
      divider: SailColorScheme.greyDark,
      shadow: SailColorScheme.black.withValues(alpha: 0.5),
      text: SailColorScheme.white,
      textSecondary: SailColorScheme.greyMiddle,
      textTertiary: SailColorScheme.greyDark,
      textHint: SailColorScheme.darkTextHint,
      iconHighlighted: primary,
      icon: SailColorScheme.white.withValues(alpha: 0.8),
      primary: primary,
      error: SailColorScheme.red,
      success: SailColorScheme.green,
      info: SailColorScheme.blue,
      orange: SailColorScheme.orange,
      orangeLight: SailColorScheme.orangeLight,
      actionHeader: SailColorScheme.blackLightest,
      chip: SailColorScheme.greyDark,
      popoverBackground: SailColorScheme.blackLighter,
      disabledBackground: SailColorScheme.greyDark.withValues(alpha: 0.2),
    );
  }
}
