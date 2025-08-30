import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SailSkeletonizer extends StatefulWidget {
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
  State<SailSkeletonizer> createState() => _SailSkeletonizerState();
}

class _SailSkeletonizerState extends State<SailSkeletonizer> {
  Widget? _cachedSkeletonizer;
  bool? _lastEnabled;

  @override
  void didUpdateWidget(SailSkeletonizer oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Always rebuild when not enabled (so child gets updates)
    if (!widget.enabled) {
      _cachedSkeletonizer = null;
      return;
    }

    // If skeleton properties changed, rebuild the skeletonizer
    if (widget.enabled != _lastEnabled ||
        widget.enableSwitchAnimation != oldWidget.enableSwitchAnimation ||
        widget.ignoreContainers != oldWidget.ignoreContainers ||
        widget.justifyMultiLineText != oldWidget.justifyMultiLineText ||
        widget.duration != oldWidget.duration) {
      _cachedSkeletonizer = null;
    }
  }

  Widget _buildSkeletonizer() {
    final theme = SailTheme.of(context);

    return Skeletonizer(
      enabled: widget.enabled,
      effect: ShimmerEffect(
        baseColor: theme.colors.backgroundSecondary,
        highlightColor: theme.colors.text.withValues(alpha: 0.5),
        duration: widget.duration,
      ),
      ignoreContainers: widget.ignoreContainers,
      justifyMultiLineText: widget.justifyMultiLineText,
      child: widget.child,
    );
  }

  @override
  Widget build(BuildContext context) {
    // When disabled, always build fresh
    if (!widget.enabled) {
      final skeletonizer = _buildSkeletonizer();
      return skeletonizer;
    }

    // When enabled, cache the skeletonizer to not restart animation
    if (_cachedSkeletonizer == null || _lastEnabled != widget.enabled) {
      _cachedSkeletonizer = _buildSkeletonizer();
      _lastEnabled = widget.enabled;
    }

    return Tooltip(message: widget.description, child: _cachedSkeletonizer!);
  }
}

class LoadingDetails {
  final bool enabled;
  final String description;

  const LoadingDetails({required this.enabled, required this.description});
}
