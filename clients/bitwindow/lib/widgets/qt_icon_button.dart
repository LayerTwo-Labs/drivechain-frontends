import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class QtIconButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;

  /// Only one of [tooltip] and [richTooltip] may be non-null.
  final String? tooltip;

  /// Only one of [tooltip] and [richTooltip] may be non-null.
  final InlineSpan? richTooltip;

  const QtIconButton({super.key, required this.icon, required this.onPressed, this.tooltip, this.richTooltip})
      : assert(tooltip == null || richTooltip == null, 'Only one of tooltip and richTooltip may be non-null');

  @override
  Widget build(BuildContext context) {
    final button = SailScaleButton(
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 4.0,
          vertical: 4.0,
        ),
        child: icon,
      ),
    );

    if (tooltip != null || richTooltip != null) {
      return Tooltip(
        message: tooltip,
        richMessage: richTooltip,
        child: button,
      );
    }

    return button;
  }
}
