import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

/// Identifies a theme bundle. The enum name is the persisted string id.
/// Adding a theme = one new value + one new [SailThemeBundle] entry below.
enum SailThemeStyle { sail, win95, ecash }

extension SailThemeStyleStringer on SailThemeStyle {
  String get id => name;
}

/// A complete, declarative theme: palette (per brightness) + chrome tokens.
/// Brightness (light/dark/system via [SailThemeValues]) stays orthogonal;
/// bundles that don't support dark mode resolve to their single [light] palette.
class SailThemeBundle {
  final SailThemeStyle style;
  final String displayName;
  final SailColor Function(Color accent) light;
  final SailColor Function(Color accent) dark;
  final bool supportsDarkMode;
  final SailChrome chrome;

  const SailThemeBundle({
    required this.style,
    required this.displayName,
    required this.light,
    required this.dark,
    required this.supportsDarkMode,
    required this.chrome,
  });

  String get id => style.id;

  SailColor palette(Color accent, {required bool isLight}) {
    if (!supportsDarkMode) return light(accent);
    return isLight ? light(accent) : dark(accent);
  }
}

/// The default theme — reproduces today's look exactly (rounded, flat).
final SailThemeBundle _sailBundle = SailThemeBundle(
  style: SailThemeStyle.sail,
  displayName: 'Sail',
  light: SailColor.lightTheme,
  dark: SailColor.darkTheme,
  supportsDarkMode: true,
  chrome: SailChrome(
    radius: SailStyleValues.borderRadius,
    radiusSmall: SailStyleValues.borderRadiusSmall,
    radiusLarge: SailStyleValues.borderRadiusLarge,
    bevel: null,
    fontFamily: null,
    buttonsRaised: false,
    fieldsSunken: false,
    panel: _sailPanel,
    titleBar: _sailTitleBar,
  ),
);

BoxDecoration _sailPanel(SailColor colors) => BoxDecoration(
  color: colors.background,
  borderRadius: SailStyleValues.borderRadiusLarge,
  border: Border.all(color: colors.border, width: 1.0),
);

BoxDecoration _sailTitleBar(SailColor colors) => BoxDecoration(
  color: colors.backgroundSecondary,
);

final SailThemeBundle _win95Bundle = SailThemeBundle(
  style: SailThemeStyle.win95,
  displayName: 'Windows 95',
  light: win95Theme,
  dark: win95Theme,
  supportsDarkMode: false,
  chrome: win95Chrome,
);

/// eCash — Sail's rounded/flat chrome, but fully monospace to match ecash.com.
final SailThemeBundle _ecashBundle = SailThemeBundle(
  style: SailThemeStyle.ecash,
  displayName: 'eCash',
  light: ecashLightTheme,
  dark: ecashDarkTheme,
  supportsDarkMode: true,
  chrome: SailChrome(
    radius: const BorderRadius.all(Radius.circular(4)),
    radiusSmall: const BorderRadius.all(Radius.circular(3)),
    radiusLarge: const BorderRadius.all(Radius.circular(8)),
    bevel: null,
    fontFamily: 'IBMPlexMono',
    buttonsRaised: false,
    fieldsSunken: false,
    panel: ecashPanel,
    titleBar: ecashTitleBar,
    tooltipBackground: ecashTooltipBackground,
    terminalStyle: true,
  ),
);

/// All registered theme bundles, keyed by style.
final Map<SailThemeStyle, SailThemeBundle> sailThemeBundles = {
  SailThemeStyle.sail: _sailBundle,
  SailThemeStyle.win95: _win95Bundle,
  SailThemeStyle.ecash: _ecashBundle,
};

SailThemeBundle sailBundleFor(SailThemeStyle style) => sailThemeBundles[style] ?? _sailBundle;

SailThemeBundle sailBundleForId(String? id) =>
    sailThemeBundles.values.firstWhere((b) => b.id == id, orElse: () => _sailBundle);
