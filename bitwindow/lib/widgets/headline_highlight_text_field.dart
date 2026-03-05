import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

/// A TextEditingController that highlights the headline portion (first 64 chars
/// or up to first newline) with a green background.
class HeadlineHighlightController extends TextEditingController {
  HeadlineHighlightController({super.text});

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final text = this.text;
    if (text.isEmpty) {
      return TextSpan(style: style, text: text);
    }

    final headlineEnd = _headlineEndIndex(text);
    final headlinePart = text.substring(0, headlineEnd);
    final restPart = text.substring(headlineEnd);

    return TextSpan(
      style: style,
      children: [
        TextSpan(
          text: headlinePart,
          style: TextStyle(backgroundColor: SailColorScheme.green.withValues(alpha: 0.3)),
        ),
        if (restPart.isNotEmpty) TextSpan(text: restPart),
      ],
    );
  }
}

int _headlineEndIndex(String text) {
  final newlineIndex = text.indexOf('\n');
  if (newlineIndex >= 0 && newlineIndex < 64) {
    return newlineIndex;
  }
  return min(64, text.length);
}

/// A text field that highlights the headline portion (first 64 chars or up to first newline)
/// with a green background directly in the text field.
class HeadlineHighlightTextField extends StatefulWidget {
  final HeadlineHighlightController controller;
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

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;
    final headlineEndIndex = _headlineEndIndex(text);

    return SailColumn(
      spacing: SailStyleValues.padding08,
      children: [
        if (widget.label != null) SailText.primary13(widget.label!, bold: true),
        SailTextField(
          controller: widget.controller,
          hintText: widget.hintText,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
        ),
        SailText.secondary12(
          'Headline: $headlineEndIndex/64 chars',
        ),
      ],
    );
  }
}
