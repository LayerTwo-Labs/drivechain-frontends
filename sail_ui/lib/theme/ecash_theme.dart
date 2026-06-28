import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

// Exact tokens from ecash.com/assets/index-CXBK_JTU.css. See tasks/ecash-design-tokens.md.
const Color ecashAmber = Color(0xffE8A84A);
const Color ecashError = Color(0xffF77070);

// Light ([data-theme=light])
const Color _lBg0 = Color(0xffF7F7F4);
const Color _lBg1 = Color(0xffEEEEEB);
const Color _lBorder0 = Color(0xffDADAD6);
const Color _lBorder2 = Color(0xffD0D0CC);
const Color _lText0 = Color(0xff09090B);
const Color _lText1 = Color(0xff3F3F46);
const Color _lText2 = Color(0xff52525B);

// Dark (:root)
const Color _dBg0 = Color(0xff0A0A0C);
const Color _dBg1 = Color(0xff0D0D0F);
const Color _dBorder0 = Color(0xff1F1F23);
const Color _dBorder2 = Color(0xff27272A);
const Color _dText0 = Color(0xffFAFAFA);
const Color _dText1 = Color(0xffA1A1AA);
const Color _dText2 = Color(0xff71717A);

const List<Color> _ecashChartPalette = [
  ecashAmber,
  Color(0xff0D9488),
  Color(0xff4F46E5),
  Color(0xff5400AA),
  Color(0xff2AB517),
  Color(0xffF7931E),
  ecashError,
];

/// Terminal-card panel: surface fill, hairline border, tight radius.
BoxDecoration ecashPanel(SailColor colors) => BoxDecoration(
  color: colors.backgroundSecondary,
  borderRadius: SailStyleValues.borderRadiusLarge,
  border: Border.all(color: colors.border, width: 1.0),
);

/// Header strip with the amber underline used for active nav on ecash.com.
BoxDecoration ecashTitleBar(SailColor colors) => BoxDecoration(
  color: colors.background,
  border: const Border(bottom: BorderSide(color: ecashAmber, width: 1.5)),
);

/// Tooltips read as terminal popups — dark ink regardless of brightness.
const Color ecashTooltipBackground = _dBg1;

/// eCash light theme — warm cream surfaces, amber accent, near-black ink.
SailColor ecashLightTheme(Color accent) => SailColor(
  background: _lBg0,
  backgroundSecondary: _lBg1,
  backgroundActionModal: _lBg1,
  popoverBackground: _lBg1,
  formField: _lBg0,
  border: _lBorder0,
  divider: _lBorder0,
  shadow: SailColorScheme.black.withValues(alpha: 0.06),
  text: _lText0,
  textSecondary: _lText1,
  textTertiary: _lText2,
  textHint: _lText2,
  iconHighlighted: ecashAmber,
  icon: _lText1,
  primary: ecashAmber,
  error: ecashError,
  success: SailColorScheme.green,
  info: ecashAmber,
  warning: SailColorScheme.orange,
  warningLight: SailColorScheme.orangeLight,
  chartPalette: _ecashChartPalette,
  orange: SailColorScheme.orange,
  orangeLight: SailColorScheme.orangeLight,
  actionHeader: _lBg1,
  chip: _lBorder0.withValues(alpha: 0.6),
  disabledBackground: _lBorder0.withValues(alpha: 0.4),
  primaryButtonBackground: ecashAmber,
  primaryButtonText: _lBg0,
  primaryButtonHover: ecashAmber.withValues(alpha: 0.9),
  secondaryButtonBackground: _lBg1,
  secondaryButtonText: _lText0,
  secondaryButtonHover: _lBg1.withValues(alpha: 0.9),
  destructiveButtonBackground: ecashError,
  destructiveButtonText: _lBg0,
  destructiveButtonHover: ecashError.withValues(alpha: 0.9),
  outlineButtonText: _lText1,
  outlineButtonBorder: _lBorder2,
  outlineButtonHover: _lBg1,
  ghostButtonText: _lText1,
  ghostButtonHover: _lBg1,
  linkButtonText: ecashAmber,
  activeNavText: ecashAmber,
  inactiveNavText: _lText2,
  inactiveSubNavText: _lText2,
  avatarBackground: _lBg1,
);

/// eCash dark theme — near-black terminal surfaces, amber accent.
SailColor ecashDarkTheme(Color accent) => SailColor(
  background: _dBg0,
  backgroundSecondary: _dBg1,
  backgroundActionModal: _dBg1,
  popoverBackground: _dBg1,
  formField: _dBg0,
  border: _dBorder0,
  divider: _dBorder0,
  shadow: SailColorScheme.black.withValues(alpha: 0.5),
  text: _dText0,
  textSecondary: _dText1,
  textTertiary: _dText2,
  textHint: _dText2,
  iconHighlighted: ecashAmber,
  icon: _dText1,
  primary: ecashAmber,
  error: ecashError,
  success: SailColorScheme.green,
  info: ecashAmber,
  warning: SailColorScheme.orange,
  warningLight: SailColorScheme.orangeLight,
  chartPalette: _ecashChartPalette,
  orange: SailColorScheme.orange,
  orangeLight: SailColorScheme.orangeLight,
  actionHeader: _dBg1,
  chip: _dBorder0,
  disabledBackground: _dBorder0.withValues(alpha: 0.4),
  primaryButtonBackground: ecashAmber,
  primaryButtonText: _dBg0,
  primaryButtonHover: ecashAmber.withValues(alpha: 0.9),
  secondaryButtonBackground: _dBg1,
  secondaryButtonText: _dText0,
  secondaryButtonHover: _dBg1.withValues(alpha: 0.9),
  destructiveButtonBackground: ecashError,
  destructiveButtonText: _dBg0,
  destructiveButtonHover: ecashError.withValues(alpha: 0.9),
  outlineButtonText: _dText1,
  outlineButtonBorder: _dBorder2,
  outlineButtonHover: _dBg1,
  ghostButtonText: _dText1,
  ghostButtonHover: _dBg1,
  linkButtonText: ecashAmber,
  activeNavText: ecashAmber,
  inactiveNavText: _dText2,
  inactiveSubNavText: _dText2,
  avatarBackground: _dBg1,
);
