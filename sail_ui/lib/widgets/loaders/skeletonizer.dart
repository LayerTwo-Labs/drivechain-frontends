import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SailSkeletonizer extends StatelessWidget {
  final Widget child;
  // a description of what the widget is waiting on, why its loading
  final String description;
  final bool enabled;
  final bool enableSwitchAnimation;
  final bool ignoreContainers;
  final bool justifyMultiLineText;
  final Duration duration;

  const SailSkeletonizer({
    super.key,
    required this.child,
    required this.description,
    this.enabled = false,
    this.enableSwitchAnimation = true,
    this.ignoreContainers = false,
    this.justifyMultiLineText = true,
    this.duration = const Duration(seconds: 3),
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    final skeletonizer = Skeletonizer(
      enabled: enabled,
      effect: ShimmerEffect(
        baseColor: theme.colors.backgroundSecondary,
        highlightColor: theme.colors.text.withValues(alpha: 0.5),
        duration: duration,
      ),
      ignoreContainers: ignoreContainers,
      justifyMultiLineText: justifyMultiLineText,
      child: child,
    );

    return enabled ? Tooltip(message: description, child: skeletonizer) : skeletonizer;
  }
}

class LoadingDetails {
  final bool enabled;
  final String description;

  const LoadingDetails({
    required this.enabled,
    required this.description,
  });
}
