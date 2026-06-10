import 'package:flutter/material.dart' show SelectableText, SelectionArea, TextSelectionThemeData, Theme;
import 'package:flutter/widgets.dart';
import 'package:sail_ui/sail_ui.dart';

/// Selectable text styled with the Sail theme.
class SailSelectableText extends StatelessWidget {
  final String? text;
  final TextSpan? span;
  final TextStyle? style;
  final bool monospace;
  final TextAlign? textAlign;

  const SailSelectableText(
    this.text, {
    super.key,
    this.style,
    this.monospace = false,
    this.textAlign,
  }) : span = null;

  const SailSelectableText.rich(
    this.span, {
    super.key,
    this.style,
    this.monospace = false,
    this.textAlign,
  }) : text = null;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final effectiveStyle =
        style ??
        SailStyleValues.thirteen.copyWith(
          color: theme.colors.text,
          fontFamily: monospace ? 'IBMPlexMono' : 'Inter',
        );

    if (span != null) {
      return SelectableText.rich(span!, style: effectiveStyle, cursorColor: theme.colors.primary, textAlign: textAlign);
    }
    return SelectableText(text!, style: effectiveStyle, cursorColor: theme.colors.primary, textAlign: textAlign);
  }
}

/// SelectionArea with the selection highlight themed to the Sail primary color.
class SailSelectionArea extends StatelessWidget {
  final Widget child;

  const SailSelectionArea({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: theme.colors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: SelectionArea(child: child),
    );
  }
}
