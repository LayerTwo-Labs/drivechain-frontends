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

  // Button-specific colors
  final Color primaryButtonBackground;
  final Color primaryButtonText;
  final Color primaryButtonHover;

  final Color secondaryButtonBackground;
  final Color secondaryButtonText;
  final Color secondaryButtonHover;

  final Color destructiveButtonBackground;
  final Color destructiveButtonText;
  final Color destructiveButtonHover;

  final Color outlineButtonText;
  final Color outlineButtonBorder;
  final Color outlineButtonHover;

  final Color ghostButtonText;
  final Color ghostButtonHover;

  final Color linkButtonText;

  final Color activeNavText;
  final Color inactiveNavText;

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
    required this.primaryButtonBackground,
    required this.primaryButtonText,
    required this.primaryButtonHover,
    required this.secondaryButtonBackground,
    required this.secondaryButtonText,
    required this.secondaryButtonHover,
    required this.destructiveButtonBackground,
    required this.destructiveButtonText,
    required this.destructiveButtonHover,
    required this.outlineButtonText,
    required this.outlineButtonBorder,
    required this.outlineButtonHover,
    required this.ghostButtonText,
    required this.ghostButtonHover,
    required this.linkButtonText,
    required this.activeNavText,
    required this.inactiveNavText,
  });

  factory SailColor.lightTheme(Color primary) {
    return SailColor(
      background: SailColorScheme.whiteDark,
      backgroundSecondary: SailColorScheme.white,
      backgroundActionModal: SailColorScheme.greyMiddle,
      formField: SailColorScheme.whiteDark,
      formFieldBorder: SailColorScheme.greyMiddle,
      divider: Color(0xffE4E4E7),
      shadow: SailColorScheme.black.withValues(alpha: 0.21),
      text: SailColorScheme.black,
      textSecondary: Color(0xffA1A1AA),
      textTertiary: Color(0xff888890),
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
      primaryButtonBackground: primary,
      primaryButtonText: Color(0xffFAFAFA),
      primaryButtonHover: primary.withValues(alpha: 0.9),
      secondaryButtonBackground: Color(0xffF4F4F5),
      secondaryButtonText: Color(0xff18181B),
      secondaryButtonHover: Color(0xffF4F4F5).withValues(alpha: 0.9),
      destructiveButtonBackground: Color(0xffDC2626),
      destructiveButtonText: Color(0xffFAFAFA),
      destructiveButtonHover: Color(0xffDC2626).withValues(alpha: 0.9),
      outlineButtonText: Color(0xff09090B),
      outlineButtonBorder: Color(0xffE4E4E7),
      outlineButtonHover: Color(0xffF4F4F5),
      ghostButtonText: Color(0xff09090B),
      ghostButtonHover: Color(0xffF4F4F5),
      linkButtonText: Color(0xff18181B),
      activeNavText: Color(0xff09090B),
      inactiveNavText: Color(0xff71717A),
    );
  }
  factory SailColor.darkTheme(Color primary) {
    return SailColor(
      background: Color(0xff09090B),
      backgroundSecondary: Color(0xff27272A),
      backgroundActionModal: SailColorScheme.darkActionModalBackground,
      formField: SailColorScheme.blackLightest,
      formFieldBorder: SailColorScheme.greyDark,
      divider: Color(0xff27272A),
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
      primaryButtonBackground: primary,
      primaryButtonText: Color(0xff18181B),
      primaryButtonHover: primary.withValues(alpha: 0.9),
      secondaryButtonBackground: Color(0xff27272A),
      secondaryButtonText: Color(0xffFAFAFA),
      secondaryButtonHover: Color(0xff27272A).withValues(alpha: 0.9),
      destructiveButtonBackground: Color(0xff7F1D1D),
      destructiveButtonText: Color(0xffFEF2F2),
      destructiveButtonHover: Color(0xffDC2626).withValues(alpha: 0.9),
      outlineButtonText: Color(0xffFAFAFA),
      outlineButtonBorder: Color(0xff27272A),
      outlineButtonHover: Color(0xff27272A),
      ghostButtonText: Color(0xffFAFAFA),
      ghostButtonHover: Color(0xff27272A),
      linkButtonText: Color(0xffFAFAFA),
      activeNavText: Color(0xffFAFAFA),
      inactiveNavText: Color(0xffA1A1AA),
    );
  }
}
