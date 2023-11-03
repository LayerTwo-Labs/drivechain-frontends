import 'package:flutter/material.dart';
import 'package:sail_ui/theme/theme.dart';

enum ShadowSize { regular, small, none }

// ignore: must_be_immutable
class SailShadow extends StatelessWidget {
  final Widget child;
  final ShadowSize shadowSize;

  // values set based on shadow size
  late double spreadRadius;
  late double blurRadius;

  SailShadow({
    super.key,
    required this.child,
    required this.shadowSize,
  }) {
    switch (shadowSize) {
      case ShadowSize.small:
        blurRadius = 4.0;
        spreadRadius = -8.0;
      case ShadowSize.regular:
        blurRadius = 7.0;
        spreadRadius = -5.0;
      case ShadowSize.none:
        blurRadius = 0.0;
        spreadRadius = -0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final shadowColor = shadowSize == ShadowSize.none ? Colors.transparent : theme.colors.shadow;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.background,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          // Bottom shadow
          BoxShadow(
            color: shadowColor,
            spreadRadius: spreadRadius,
            blurRadius: blurRadius,
            offset: const Offset(0, 5),
          ),
          // Left shadow
          BoxShadow(
            color: shadowColor,
            spreadRadius: spreadRadius,
            blurRadius: blurRadius,
            offset: const Offset(-5, 0),
          ),
          // Right shadow
          BoxShadow(
            color: shadowColor,
            spreadRadius: spreadRadius,
            blurRadius: blurRadius,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SailErrorShadow extends StatelessWidget {
  final bool enabled;
  final Widget child;

  const SailErrorShadow({
    super.key,
    required this.enabled,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    if (enabled) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colors.background,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          boxShadow: [
            // Bottom shadow
            BoxShadow(
              color: theme.colors.error,
              spreadRadius: 0,
              blurRadius: 24,
              offset: const Offset(0, 5),
            ),
            // Left shadow
            BoxShadow(
              color: theme.colors.error,
              spreadRadius: 0,
              blurRadius: 24,
              offset: const Offset(-5, 0),
            ),
            // Right shadow
            BoxShadow(
              color: theme.colors.error,
              spreadRadius: 0,
              blurRadius: 24,
              offset: const Offset(5, 0),
            ),
          ],
        ),
        child: child,
      );
    }

    return child;
  }
}
