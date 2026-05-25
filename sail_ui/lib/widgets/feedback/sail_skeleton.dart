import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

class SailSkeleton extends StatelessWidget {
  final Widget child;
  final String description;
  final bool enabled;
  final bool enableSwitchAnimation;
  final bool ignoreContainers;
  final bool justifyMultiLineText;
  final Duration duration;

  const SailSkeleton({
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
    return SailSkeletonizer(
      description: description,
      enabled: enabled,
      enableSwitchAnimation: enableSwitchAnimation,
      ignoreContainers: ignoreContainers,
      justifyMultiLineText: justifyMultiLineText,
      duration: duration,
      child: child,
    );
  }
}
