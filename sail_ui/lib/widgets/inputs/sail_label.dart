import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

class SailLabel extends StatelessWidget {
  final String text;
  final String? htmlFor;
  final bool required;
  final TextStyle? style;

  const SailLabel({
    super.key,
    required this.text,
    this.htmlFor,
    this.required = false,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final baseStyle =
        style ??
        SailStyleValues.thirteen.copyWith(
          color: theme.colors.text,
          fontWeight: SailStyleValues.boldWeight,
        );

    final scaler = MediaQuery.of(context).textScaler.clamp(maxScaleFactor: 2);

    return Semantics(
      label: htmlFor == null ? text : '$text (for $htmlFor)',
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: text, style: baseStyle),
            if (required)
              TextSpan(
                text: ' *',
                style: baseStyle.copyWith(color: theme.colors.error),
              ),
          ],
        ),
        textScaler: scaler,
      ),
    );
  }
}
