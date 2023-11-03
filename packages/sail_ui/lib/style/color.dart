import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SailColor {
  final Color background;
  final Color backgroundSecondary;
  final Color backgroundActionModal;

  final Color formField;
  final Color formFieldBorder;
  final Color divider;
  final Color shadow;
  final Color text;
  final Color textSecondary;
  final Color textTertiary;
  final Color textHint;
  final Color orange;
  final Color icon;
  final Color iconHighlighted;
  final Color error;
  final Color success;

  final Color actionHeader;
  final Color chip;

  SailColor({
    required this.background,
    required this.backgroundSecondary,
    required this.backgroundActionModal,
    required this.formField,
    required this.formFieldBorder,
    required this.divider,
    required this.shadow,
    required this.text,
    required this.textSecondary,
    required this.textTertiary,
    required this.textHint,
    required this.orange,
    required this.iconHighlighted,
    required this.icon,
    required this.error,
    required this.success,
    required this.actionHeader,
    required this.chip,
  });

  factory SailColor.lightTheme() {
    return SailColor(
      background: SailColorScheme.white,
      backgroundSecondary: SailColorScheme.whiteDark,
      backgroundActionModal: SailColorScheme.greyMiddle,
      formField: SailColorScheme.whiteDark,
      formFieldBorder: SailColorScheme.greyMiddle,
      divider: SailColorScheme.greyLight,
      shadow: SailColorScheme.black.withOpacity(0.18),
      text: SailColorScheme.black,
      textSecondary: SailColorScheme.greyDark,
      textTertiary: SailColorScheme.greyMiddle,
      textHint: SailColorScheme.greyMiddle,
      iconHighlighted: SailColorScheme.orange,
      icon: SailColorScheme.greyMiddle,
      orange: SailColorScheme.orange,
      error: SailColorScheme.red,
      success: SailColorScheme.green,
      actionHeader: SailColorScheme.whiteDark,
      chip: SailColorScheme.greyMiddle,
    );
  }
  factory SailColor.darkTheme() {
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
      textSecondary: SailColorScheme.darkTextSecondary,
      textTertiary: SailColorScheme.darkTextTertiary,
      textHint: SailColorScheme.darkTextHint,
      orange: SailColorScheme.orange,
      iconHighlighted: SailColorScheme.orange,
      icon: SailColorScheme.greyMiddle,
      error: SailColorScheme.red,
      success: SailColorScheme.green,
      chip: SailColorScheme.darkChip,
    );
  }
}
