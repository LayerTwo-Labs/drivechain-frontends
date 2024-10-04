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
    final button = ClipRRect(
      borderRadius: BorderRadius.circular(4.0),
      child: SailScaleButton(
        onPressed: onPressed,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: context.sailTheme.colors.formFieldBorder,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 4.0,
            vertical: 4.0,
          ),
          child: icon,
        ),
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
