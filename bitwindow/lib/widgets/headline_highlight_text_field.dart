import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

/// A text field that highlights the headline portion (first 64 chars or up to first newline).
/// Shows a live preview with highlighting above the editable area.
class HeadlineHighlightTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final int minLines;
  final int? maxLines;
  final String? label;

  const HeadlineHighlightTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.minLines = 1,
    this.maxLines,
    this.label,
  });

  @override
  State<HeadlineHighlightTextField> createState() => _HeadlineHighlightTextFieldState();
}

class _HeadlineHighlightTextFieldState extends State<HeadlineHighlightTextField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  int _getHeadlineEndIndex(String text) {
    final newlineIndex = text.indexOf('\n');
    if (newlineIndex >= 0 && newlineIndex < 64) {
      return newlineIndex;
    }
    return min(64, text.length);
  }

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final text = widget.controller.text;
    final headlineEndIndex = _getHeadlineEndIndex(text);

    return SailColumn(
      spacing: SailStyleValues.padding08,
      children: [
        if (widget.label != null) SailText.primary13(widget.label!, bold: true),
        // Text input
        SailTextField(
          controller: widget.controller,
          hintText: widget.hintText,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
        ),
        // Character counter for headline
        Row(
          children: [
            SailText.secondary12(
              'Headline: $headlineEndIndex/64 chars',
              color: headlineEndIndex >= 64 ? theme.colors.success : null,
            ),
            if (text.contains('\n') && text.indexOf('\n') < 64)
              SailText.secondary12(
                ' (ends at newline)',
                color: theme.colors.textHint,
              ),
          ],
        ),
      ],
    );
  }
}
