import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

const Color _accent = Color(0xffF7931E);
const Color _negative = Color(0xffFF0000);
const Color _positive = Color(0xff2AB517);
const Color _info = Color(0xff0D7FFF);
const Color _purple = Color(0xff9F6EF0);
const Color _icon = Color(0xffC1C1C1);

const List<Color> _bitwindowV2ChartPalette = [
  _accent,
  _positive,
  _info,
  _purple,
  _negative,
];

// Light
const Color _lCanvas = Color(0xffF3F1EC);
const Color _lSurface = Color(0xffFFFFFF);
const Color _lSunken = Color(0xffEBE9E1);
const Color _lChip = Color(0xffF5F5F5);
const Color _lDisabled = Color(0xffC1C1C1);
const Color _lText = Color(0xff000000);
const Color _lTextSecondary = Color(0xff61605E);
const Color _lTextTertiary = Color(0xffA1A1AA);
const Color _lTextHint = Color(0xff8D8D8D);
const Color _lAccentSubtle = Color(0xffFFEFDD);

// Dark
const Color _dCanvas = Color(0xff000000);
const Color _dSurface = Color(0xff1A1A1A);
const Color _dSheetCard = Color(0xff262626);
const Color _dSunken = Color(0xff3C3B3B);
const Color _dChip = Color(0xff171717);
const Color _dText = Color(0xffFFFFFF);
const Color _dTextSecondary = Color(0xffA1A1AA);
const Color _dTextTertiary = Color(0xff71717A);
const Color _dTextHint = Color(0xff828282);
const Color _dAccentSubtle = Color(0xff311D06);
const Color _dDestructiveText = Color(0xffFD7979);

/// Card surface: raised fill, hairline border, large radius.
BoxDecoration bitwindowV2Panel(SailColor colors) => BoxDecoration(
  color: colors.backgroundSecondary,
  borderRadius: const BorderRadius.all(Radius.circular(20)),
  border: Border.all(color: colors.border, width: 1.0),
);

BoxDecoration bitwindowV2TitleBar(SailColor colors) => BoxDecoration(color: colors.backgroundSecondary);

SailColor bitwindowV2LightTheme(Color accent) => SailColor(
  background: _lCanvas,
  backgroundSecondary: _lSurface,
  backgroundActionModal: _lSurface,
  popoverBackground: _lSurface,
  formField: _lSunken,
  border: _lSunken,
  divider: _lSunken,
  shadow: const Color.from(alpha: 0.18, red: 0, green: 0, blue: 0),
  text: _lText,
  textSecondary: _lTextSecondary,
  textTertiary: _lTextTertiary,
  textHint: _lTextHint,
  iconHighlighted: _accent,
  icon: _icon,
  primary: _accent,
  error: _negative,
  success: _positive,
  info: _info,
  warning: _accent,
  warningLight: _lAccentSubtle,
  chartPalette: _bitwindowV2ChartPalette,
  orange: _accent,
  orangeLight: _lAccentSubtle,
  actionHeader: _lSurface,
  chip: _lChip,
  disabledBackground: _lDisabled,
  primaryButtonBackground: _accent,
  primaryButtonText: _lSurface,
  primaryButtonHover: _accent.withValues(alpha: 0.9),
  secondaryButtonBackground: _lSunken,
  secondaryButtonText: _lText,
  secondaryButtonHover: _lSunken.withValues(alpha: 0.9),
  destructiveButtonBackground: _lSunken,
  destructiveButtonText: _negative,
  destructiveButtonHover: _lSunken.withValues(alpha: 0.9),
  outlineButtonText: _lText,
  outlineButtonBorder: _lSunken,
  outlineButtonHover: _lCanvas,
  ghostButtonText: _lText,
  ghostButtonHover: _lCanvas,
  linkButtonText: _lText,
  activeNavText: _lText,
  inactiveNavText: _lTextSecondary,
  inactiveSubNavText: _lTextSecondary,
  avatarBackground: _lSunken,
);

SailColor bitwindowV2DarkTheme(Color accent) => SailColor(
  background: _dCanvas,
  backgroundSecondary: _dSurface,
  backgroundActionModal: _dSheetCard,
  popoverBackground: _dSheetCard,
  formField: _dSunken,
  border: _dSunken,
  divider: _dSunken,
  shadow: const Color.from(
    alpha: 0.18,
    red: 224 / 255,
    green: 224 / 255,
    blue: 224 / 255,
  ),
  text: _dText,
  textSecondary: _dTextSecondary,
  textTertiary: _dTextTertiary,
  textHint: _dTextHint,
  iconHighlighted: _accent,
  icon: _icon,
  primary: _accent,
  error: _negative,
  success: _positive,
  info: _info,
  warning: _accent,
  warningLight: _dAccentSubtle,
  chartPalette: _bitwindowV2ChartPalette,
  orange: _accent,
  orangeLight: _dAccentSubtle,
  actionHeader: _dSurface,
  chip: _dChip,
  disabledBackground: _dSunken,
  primaryButtonBackground: _accent,
  primaryButtonText: _dCanvas,
  primaryButtonHover: _accent.withValues(alpha: 0.9),
  secondaryButtonBackground: _dSunken,
  secondaryButtonText: _dText,
  secondaryButtonHover: _dSunken.withValues(alpha: 0.9),
  destructiveButtonBackground: _dSunken,
  destructiveButtonText: _dDestructiveText,
  destructiveButtonHover: _dSunken.withValues(alpha: 0.9),
  outlineButtonText: _dText,
  outlineButtonBorder: _dSunken,
  outlineButtonHover: _dSheetCard,
  ghostButtonText: _dText,
  ghostButtonHover: _dSheetCard,
  linkButtonText: _dText,
  activeNavText: _dText,
  inactiveNavText: _dTextSecondary,
  inactiveSubNavText: _dTextSecondary,
  avatarBackground: _dSunken,
);

const SailChrome bitwindowV2Chrome = SailChrome(
  radius: BorderRadius.all(Radius.circular(12)),
  radiusSmall: BorderRadius.all(Radius.circular(8)),
  radiusLarge: BorderRadius.all(Radius.circular(20)),
  bevel: null,
  fontFamily: null,
  buttonsRaised: false,
  fieldsSunken: false,
  panel: bitwindowV2Panel,
  titleBar: bitwindowV2TitleBar,
  flatControls: true,
);
