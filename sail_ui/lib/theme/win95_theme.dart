import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

// Windows-95 palette. Visuals lifted from the flutter95 recipe (not the
// package): grey surfaces, hard bevels, navy title bars/selection.
const _white = Color(0xffffffff);
const _grey = Color(0xffc0c0c0);
const _greyDark = Color(0xff808080);
const _greyDarker = Color(0xff404040);
const _navy = Color(0xff000080);
const _navyLight = Color(0xff1084d0);
const _black = Color(0xff000000);

const List<Color> _win95ChartPalette = [
  Color(0xff000080),
  Color(0xff008080),
  Color(0xff808000),
  Color(0xff800080),
  Color(0xff008000),
  Color(0xff800000),
  Color(0xff0000ff),
];

/// win95 ignores the accent color and the light/dark distinction — it has one
/// fixed palette.
SailColor win95Theme(Color accent) {
  return SailColor(
    background: _grey,
    backgroundSecondary: _grey,
    backgroundActionModal: _grey,
    popoverBackground: _grey,
    formField: _white,
    border: _greyDark,
    divider: _greyDark,
    shadow: _black.withValues(alpha: 0.25),
    text: _black,
    textSecondary: _greyDarker,
    textTertiary: _greyDark,
    textHint: _greyDark,
    iconHighlighted: _navy,
    icon: _black,
    primary: _navy,
    error: SailColorScheme.red,
    success: SailColorScheme.green,
    info: _navy,
    warning: SailColorScheme.orange,
    warningLight: SailColorScheme.orangeLight,
    chartPalette: _win95ChartPalette,
    orange: SailColorScheme.orange,
    orangeLight: SailColorScheme.orangeLight,
    actionHeader: _grey,
    chip: _grey,
    disabledBackground: _grey,
    primaryButtonBackground: _grey,
    primaryButtonText: _black,
    primaryButtonHover: _grey,
    secondaryButtonBackground: _grey,
    secondaryButtonText: _black,
    secondaryButtonHover: _grey,
    destructiveButtonBackground: _grey,
    destructiveButtonText: Color(0xff800000),
    destructiveButtonHover: _grey,
    outlineButtonText: _black,
    outlineButtonBorder: _greyDark,
    outlineButtonHover: _grey,
    ghostButtonText: _black,
    ghostButtonHover: _grey,
    linkButtonText: _navy,
    activeNavText: _black,
    inactiveNavText: _greyDarker,
    inactiveSubNavText: _greyDark,
    avatarBackground: _grey,
  );
}

const SailBevel _win95Bevel = SailBevel(light: _white, dark: _greyDark);

final SailChrome win95Chrome = SailChrome(
  radius: BorderRadius.zero,
  radiusSmall: BorderRadius.zero,
  radiusLarge: BorderRadius.zero,
  bevel: _win95Bevel,
  fontFamily: 'packages/sail_ui/VT323',
  buttonsRaised: true,
  fieldsSunken: true,
  panel: _win95Panel,
  titleBar: _win95TitleBar,
  tooltipBackground: Color(0xffffffe3),
);

BoxDecoration _win95Panel(SailColor colors) => BoxDecoration(
  color: _grey,
  border: _win95Bevel.raised,
);

BoxDecoration _win95TitleBar(SailColor colors) => const BoxDecoration(
  gradient: LinearGradient(colors: [_navy, _navyLight]),
);
