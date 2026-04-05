import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

enum ShadowSize { regular, none }

class SailShadow extends StatelessWidget {
  final Widget child;
  final ShadowSize shadowSize;

  const SailShadow({
    super.key,
    required this.child,
    this.shadowSize = ShadowSize.regular,
  });

  @override
  Widget build(BuildContext context) {
    if (shadowSize == ShadowSize.none) {
      return child;
    }

    final theme = SailTheme.of(context);

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            margin: EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: SailStyleValues.borderRadiusLarge,
              boxShadow: [
                BoxShadow(
                  color: theme.colors.shadow,
                  offset: Offset(0, 1), // x=0, y=1
                  blurRadius: 2,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class SailErrorShadow extends StatelessWidget {
  final bool enabled;
  final Widget child;
  final bool small;

  const SailErrorShadow({
    super.key,
    required this.enabled,
    required this.child,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final theme = SailTheme.of(context);
    final blurRadius = small ? 6.0 : 24.0;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: theme.colors.error,
                  blurRadius: blurRadius,
                  spreadRadius: 0,
                ),
              ],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
