import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// An error shown next to the control that failed. Needs a bounded width.
class SailInlineError extends StatelessWidget {
  final String message;
  final int? maxLines;

  const SailInlineError(this.message, {super.key, this.maxLines});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailSVG.fromAsset(SailSVGAsset.circleAlert, width: 16, color: theme.colors.error),
        const SizedBox(width: SailStyleValues.padding08),
        Expanded(
          child: SailText.primary12(
            message,
            color: theme.colors.error,
            maxLines: maxLines,
            overflow: maxLines == null ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
