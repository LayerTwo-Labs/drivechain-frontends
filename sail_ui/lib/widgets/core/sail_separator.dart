import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// Thin horizontal or vertical divider line, themed to [SailColor.divider].
/// Equivalent of shadcn/ui's `Separator`. Self-contained — doesn't import
/// from `package:flutter/material.dart`, so it's safe to use as a building
/// block for the rest of the Material-removal effort.
class SailSeparator extends StatelessWidget {
  /// Axis the separator runs along. Horizontal = a thin row, the default.
  final Axis axis;

  /// Stroke thickness in logical pixels.
  final double thickness;

  /// Optional override for the line color. Defaults to the theme's divider.
  final Color? color;

  /// Optional padding around the separator. Useful inside menus / dropdowns.
  final EdgeInsetsGeometry? padding;

  const SailSeparator({
    super.key,
    this.axis = Axis.horizontal,
    this.thickness = 1.0,
    this.color,
    this.padding,
  });

  /// Convenience: a vertical separator. Same as `SailSeparator(axis: Axis.vertical)`.
  const SailSeparator.vertical({super.key, this.thickness = 1.0, this.color, this.padding}) : axis = Axis.vertical;

  @override
  Widget build(BuildContext context) {
    final lineColor = color ?? SailTheme.of(context).colors.divider;
    final line = axis == Axis.horizontal
        ? SizedBox(
            height: thickness,
            child: ColoredBox(color: lineColor),
          )
        : SizedBox(
            width: thickness,
            child: ColoredBox(color: lineColor),
          );
    if (padding == null) return line;
    return Padding(padding: padding!, child: line);
  }
}
