import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

/// 3D edge colors for raised/sunken bevels (Windows-95-style). `width` is the
/// thickness in logical pixels of each bevel band.
class SailBevel {
  final Color light;
  final Color dark;
  final double width;

  const SailBevel({required this.light, required this.dark, this.width = 2});

  /// Light top-left / dark bottom-right — the "popped out" win95 look.
  Border get raised => Border(
    top: BorderSide(color: light, width: width),
    left: BorderSide(color: light, width: width),
    bottom: BorderSide(color: dark, width: width),
    right: BorderSide(color: dark, width: width),
  );

  /// Inverted bevel — pressed buttons and sunken wells/fields.
  Border get sunken => Border(
    top: BorderSide(color: dark, width: width),
    left: BorderSide(color: dark, width: width),
    bottom: BorderSide(color: light, width: width),
    right: BorderSide(color: light, width: width),
  );
}

/// Per-theme visual chrome consumed by sail_ui components alongside [SailColor].
/// A bundle's chrome is what makes "the same SailButton" render rounded-and-flat
/// in the sail theme but raised-and-square in win95 — components read these
/// tokens instead of hardcoding radii and decorations.
class SailChrome {
  final BorderRadius radius;
  final BorderRadius radiusSmall;
  final BorderRadius radiusLarge;

  /// null = flat borders; non-null = draw 3D raised/sunken edges.
  final SailBevel? bevel;

  /// null = defer to the active [SailFontValues] font; non-null forces a family
  /// (e.g. win95 pixel font) regardless of the user's font setting.
  final String? fontFamily;

  final bool buttonsRaised;
  final bool fieldsSunken;

  /// Flat terminal aesthetic (eCash): outline-first controls, uppercase
  /// letter-spaced labels, amber accents. Mutually exclusive with [bevel].
  final bool terminalStyle;

  /// Surface decoration for cards/panels.
  final BoxDecoration Function(SailColor colors) panel;

  /// Decoration for a dialog/card title bar (navy gradient on win95).
  final BoxDecoration Function(SailColor colors) titleBar;

  /// null = theme default tooltip surface; non-null forces it (win95 cream).
  final Color? tooltipBackground;

  const SailChrome({
    required this.radius,
    required this.radiusSmall,
    required this.radiusLarge,
    required this.bevel,
    required this.fontFamily,
    required this.buttonsRaised,
    required this.fieldsSunken,
    required this.panel,
    required this.titleBar,
    this.tooltipBackground,
    this.terminalStyle = false,
  });

  bool get beveled => bevel != null;
}
