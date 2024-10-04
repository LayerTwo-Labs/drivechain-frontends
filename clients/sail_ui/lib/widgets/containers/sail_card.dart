import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SailRawCard extends StatelessWidget {
  final String? title;
  final VoidCallback? onPressed;
  final bool padding;
  final Widget child;
  final double? width;
  final Color? color;
  final BorderRadius? borderRadius;
  final ShadowSize shadowSize;

  const SailRawCard({
    super.key,
    this.title,
    this.onPressed,
    this.padding = false,
    required this.child,
    this.width = double.infinity,
    this.color,
    this.borderRadius,
    this.shadowSize = ShadowSize.regular,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailShadow(
      shadowSize: shadowSize,
      child: Material(
        borderRadius: borderRadius ?? SailStyleValues.borderRadiusRegular,
        color: color ?? (theme.colors.actionHeader),
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: width,
          child: padding
              ? Padding(
                  padding: const EdgeInsets.all(SailStyleValues.padding20),
                  child: child,
                )
              : child,
        ),
      ),
    );
  }
}
