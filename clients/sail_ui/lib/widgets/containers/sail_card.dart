import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SailRawCard extends StatelessWidget {
  final String? title;
  final Widget? header;
  final VoidCallback? onPressed;
  final bool padding;
  final bool bottomPadding;
  final Widget child;
  final double? width;
  final Color? color;
  final BorderRadius? borderRadius;
  final ShadowSize shadowSize;

  const SailRawCard({
    super.key,
    this.title,
    this.header,
    this.onPressed,
    this.padding = true,
    this.bottomPadding = true,
    required this.child,
    this.width = double.infinity,
    this.color,
    this.borderRadius,
    this.shadowSize = ShadowSize.small,
  }) : assert(!(header != null && title != null), 'Cannot set both title and header');

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailShadow(
      shadowSize: shadowSize,
      child: Material(
        borderRadius: borderRadius ?? SailStyleValues.borderRadiusButton,
        color: color ?? (theme.colors.backgroundSecondary),
        clipBehavior: Clip.hardEdge,
        child: SizedBox(
          width: width,
          child: Padding(
            padding: padding
                ? EdgeInsets.only(
                    top: SailStyleValues.padding16,
                    left: SailStyleValues.padding16,
                    right: SailStyleValues.padding16,
                    bottom: bottomPadding ? SailStyleValues.padding16 : 0,
                  )
                : EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (header != null) header!,
                if (title != null)
                  SailText.primary15(
                    title!,
                    bold: true,
                  ),
                if (title != null) const SailSpacing(SailStyleValues.padding16),
                Flexible(
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
