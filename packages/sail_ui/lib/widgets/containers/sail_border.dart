import 'package:flutter/material.dart';
import 'package:sail_ui/theme/theme.dart';

class SailBorder extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final BoxBorder? border;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;

  const SailBorder({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.border,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: border ?? Border.all(color: theme.colors.formFieldBorder, width: 1),
        borderRadius: borderRadius ?? const BorderRadius.all(Radius.circular(4)),
      ),
      child: Container(
        color: backgroundColor,
        child: Padding(
          padding: padding != null ? padding! : const EdgeInsets.all(0),
          child: child,
        ),
      ),
    );
  }
}
