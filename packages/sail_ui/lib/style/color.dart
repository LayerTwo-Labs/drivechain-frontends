import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SailColor {
  final Color background;
  final Color backgroundSecondary;
  final Color formField;
  final Color formFieldBorder;
  final Color card;
  final Color divider;
  final Color shadow;
  final Color highlightedCard;
  final Color highlightedCardText;
  final Color text;
  final Color textLowerContrast;
  final Color textSecondary;
  final Color textTertiary;
  final Color label;
  final Color sectionTitle;
  final Color orange;
  final Color disabledPrimaryButton;
  final Color primaryButtonText;
  final Color icon;
  final Color iconHighlighted;
  final Color iconTab;
  final Color lowContrastText;
  final Color highlightedPillBackground;
  final Color highlightedPillText;
  final Color chipCard;
  final Color blue;
  final Color error;
  final Color green;

  SailColor({
    required this.background,
    required this.backgroundSecondary,
    required this.formField,
    required this.formFieldBorder,
    required this.card,
    required this.divider,
    required this.shadow,
    required this.highlightedCard,
    required this.highlightedCardText,
    required this.text,
    required this.textLowerContrast,
    required this.textSecondary,
    required this.textTertiary,
    required this.label,
    required this.sectionTitle,
    required this.orange,
    required this.disabledPrimaryButton,
    required this.primaryButtonText,
    required this.iconHighlighted,
    required this.iconTab,
    required this.lowContrastText,
    required this.icon,
    required this.highlightedPillBackground,
    required this.highlightedPillText,
    required this.chipCard,
    required this.blue,
    required this.error,
    required this.green,
  });

  factory SailColor.lightTheme() {
    return SailColor(
      background: SailColorScheme.white,
      backgroundSecondary: SailColorScheme.whiteDark,
      formField: SailColorScheme.whiteDark,
      formFieldBorder: SailColorScheme.greyMiddle,
      divider: SailColorScheme.greyLight,
      shadow: SailColorScheme.black.withOpacity(0.18),
      card: SailColorScheme.white,
      highlightedCard: SailColorScheme.black,
      highlightedCardText: SailColorScheme.white,
      text: SailColorScheme.black,
      textLowerContrast: SailColorScheme.greyDark,
      textSecondary: SailColorScheme.greyDark,
      textTertiary: SailColorScheme.greyMiddle,
      label: SailColorScheme.greyDark,
      sectionTitle: const Color.fromARGB(255, 102, 102, 102),
      disabledPrimaryButton: SailColorScheme.orange.withOpacity(0.5),
      primaryButtonText: SailColorScheme.white,
      iconHighlighted: SailColorScheme.orange,
      iconTab: SailColorScheme.greyMiddle,
      lowContrastText: const Color.fromARGB(255, 141, 141, 141),
      icon: SailColorScheme.greyMiddle,
      highlightedPillBackground: SailColorScheme.superLightGreen,
      highlightedPillText: SailColorScheme.mediumDarkGreen,
      chipCard: SailColorScheme.whiteDark,
      orange: SailColorScheme.orange,
      blue: SailColorScheme.blue,
      error: SailColorScheme.pink,
      green: SailColorScheme.green,
    );
  }
  factory SailColor.darkTheme() {
    return SailColor(
      background: SailColorScheme.black,
      backgroundSecondary: SailColorScheme.blackLight,
      formField: SailColorScheme.whiteDark,
      formFieldBorder: SailColorScheme.blackLight,
      card: SailColorScheme.black,
      divider: SailColorScheme.greyLight,
      shadow: SailColorScheme.greyLight.withOpacity(0.18),
      highlightedCard: SailColorScheme.white,
      highlightedCardText: SailColorScheme.black,
      text: SailColorScheme.white,
      textLowerContrast: SailColorScheme.white,
      textSecondary: SailColorScheme.white,
      textTertiary: SailColorScheme.greyMiddle,
      label: SailColorScheme.greyDark,
      sectionTitle: SailColorScheme.white,
      orange: SailColorScheme.orange,
      disabledPrimaryButton: SailColorScheme.orange.withOpacity(0.4),
      primaryButtonText: SailColorScheme.black,
      lowContrastText: const Color.fromARGB(255, 130, 130, 130),
      iconHighlighted: SailColorScheme.orange,
      iconTab: SailColorScheme.greyDark,
      icon: SailColorScheme.greyMiddle,
      highlightedPillBackground: SailColorScheme.mediumGreen,
      highlightedPillText: SailColorScheme.black,
      chipCard: const Color.fromARGB(255, 23, 23, 23),
      blue: SailColorScheme.blue,
      error: SailColorScheme.pink,
      green: SailColorScheme.green,
    );
  }
}
