import 'package:flutter/material.dart';
import 'package:sail_ui/theme/theme.dart';

class SailBorder extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsets? padding;

  const SailBorder({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colors.formFieldBorder, width: 0.5),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
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
