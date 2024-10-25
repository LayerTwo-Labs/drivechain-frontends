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
      divider: SailColorScheme.greyLight.withOpacity(0.2),
      shadow: SailColorScheme.black.withOpacity(0.21),
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
      chip: SailColorScheme.greyMiddle.withOpacity(0.21),
      popoverBackground: SailColorScheme.white,
      disabledBackground: SailColorScheme.greyLight.withOpacity(0.1),
    );
  }
  factory SailColor.darkTheme(Color primary) {
    return SailColor(
      background: SailColorScheme.darkBackground,
      backgroundSecondary: SailColorScheme.blackLight,
      backgroundActionModal: SailColorScheme.darkActionModalBackground,
      actionHeader: SailColorScheme.darkActionHeader,
      formField: SailColorScheme.whiteDark,
      formFieldBorder: SailColorScheme.darkInputBorder,
      divider: SailColorScheme.darkDivider,
      shadow: SailColorScheme.greyLight.withOpacity(0.18),
      text: SailColorScheme.whiteLight,
      textSecondary: SailColorScheme.darkTextTertiary,
      textTertiary: SailColorScheme.darkTextTertiary,
      textHint: SailColorScheme.darkTextHint,
      primary: primary,
      iconHighlighted: primary,
      icon: SailColorScheme.greyMiddle,
      error: SailColorScheme.red,
      success: SailColorScheme.green,
      info: SailColorScheme.blue,
      orange: SailColorScheme.orange,
      orangeLight: SailColorScheme.orangeLight,
      chip: SailColorScheme.darkChip,
      popoverBackground: SailColorScheme.darkBackground,
      disabledBackground: SailColorScheme.whiteDark,
    );
  }
}
