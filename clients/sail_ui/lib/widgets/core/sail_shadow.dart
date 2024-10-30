import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

enum ShadowSize { regular, small, none }

class SailShadow extends StatelessWidget {
  final Widget child;
  final ShadowSize shadowSize;

  const SailShadow({
    super.key,
    required this.child,
    required this.shadowSize,
  });

  @override
  Widget build(BuildContext context) {
    if (shadowSize == ShadowSize.none) {
      return child;
    }

    final theme = SailTheme.of(context);
    final blurRadius = shadowSize == ShadowSize.small ? 10.0 : 7.0;
    final spreadRadius = shadowSize == ShadowSize.small ? 0.0 : 2.0;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            margin: EdgeInsets.all(spreadRadius),
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: theme.colors.shadow.withOpacity(0.05), // Reduced opacity from 0.05 to 0.02
                  blurRadius: blurRadius,
                  spreadRadius: spreadRadius,
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
