import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';

enum TextFieldSize { small, regular }

enum TextFieldType { number, bitcoin, text }

class SailTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? label;
  final String hintText;
  final String? helperText;
  final String? suffix;
  final Widget? suffixWidget;
  final TextFieldType textFieldType;
  final String? prefix;
  final Widget? prefixWidget;
  final Widget? prefixIcon;
  final BoxConstraints? prefixIconConstraints;
  final TextFieldSize size;
  final void Function(String)? onSubmitted;
  final void Function(String)? onChanged;
  final bool readOnly;
  final bool dense;
  final bool enabled;
  final int? minLines;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final LoadingDetails? loading;
  final bool obscureText;

  /// Fills the parent's height; requires a bounded-height ancestor.
  final bool expands;
  final bool monospace;

  /// A row of actions inside the field's box, under the text.
  final Widget? bottomWidget;

  /// Puts [suffixWidget] beside the first line of text, not at the vertical center.
  final bool alignSuffixTop;

  const SailTextField({
    super.key,
    required this.controller,
    this.label,
    required this.hintText,
    this.helperText,
    this.textFieldType = TextFieldType.text,
    this.suffix,
    this.suffixWidget,
    this.prefix,
    this.prefixWidget,
    this.prefixIcon,
    this.prefixIconConstraints,
    this.size = TextFieldSize.regular,
    this.focusNode,
    this.autofocus = false,
    this.onSubmitted,
    this.onChanged,
    this.readOnly = false,
    this.dense = false,
    this.enabled = true,
    this.minLines,
    this.maxLines,
    this.inputFormatters,
    this.loading,
    this.obscureText = false,
    this.expands = false,
    this.monospace = false,
    this.bottomWidget,
    this.alignSuffixTop = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final padding = EdgeInsets.symmetric(vertical: 11.5, horizontal: 12);
    final textSize = size == TextFieldSize.regular ? 13.0 : 10.0;

    final terminal = theme.chrome.terminalStyle;
    final borderRadius = terminal ? theme.chrome.radiusSmall : theme.chrome.radius;
    final restingBorderColor = terminal ? theme.colors.outlineButtonBorder : theme.colors.border;
    final focusedBorderColor = terminal ? theme.colors.primary : theme.colors.text;
    final hintColor = terminal ? theme.colors.textHint : theme.colors.inactiveNavText;
    final fillColor = theme.chrome.fieldsSunken ? theme.colors.formField : theme.colors.background;
    // The box draws the border, the fill and the suffix, so the TextField draws none of them.
    final boxed = bottomWidget != null || alignSuffixTop;

    final Widget? trailing = loading != null && loading!.enabled
        ? Tooltip(
            message: loading!.description,
            child: Padding(
              padding: EdgeInsets.all(SailStyleValues.padding08),
              child: LoadingIndicator(),
            ),
          )
        : suffixWidget != null
        ? Align(
            alignment: Alignment.center,
            widthFactor: 1.0,
            child: Padding(
              padding: EdgeInsets.only(
                top: 1,
                bottom: 1,
                left: 1,
                right: 8,
              ),
              child: suffixWidget,
            ),
          )
        : null;

    final field = Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: theme.colors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: TextField(
        autofocus: autofocus,
        enabled: enabled,
        obscureText: obscureText,
        mouseCursor: enabled ? WidgetStateMouseCursor.textable : SystemMouseCursors.forbidden,
        cursorColor: theme.colors.primary,
        controller: controller,
        focusNode: focusNode,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
        readOnly: readOnly,
        style: SailStyleValues.thirteen.copyWith(
          color: SailTheme.of(context).colors.text,
          fontSize: textSize,
          fontFamily: theme.chrome.fontFamily ?? (monospace ? SailFonts.mono : null),
          // Inter draws the x in "9x8" as a times sign, which corrupts addresses and hex.
          fontFeatures: const [FontFeature.disable('calt')],
        ),
        inputFormatters: [
          if (textFieldType == TextFieldType.number) FilteringTextInputFormatter.allow(RegExp(r'^\d+$')),
          if (textFieldType == TextFieldType.bitcoin) FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,8}')),
          ...?inputFormatters,
        ],
        expands: expands,
        minLines: expands ? null : minLines,
        maxLines: expands ? null : maxLines ?? (minLines != null ? null : 1),
        decoration: InputDecoration(
          isDense: true, // This helps reduce the minimum height
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          enabledBorder: boxed
              ? InputBorder.none
              : OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide: BorderSide(color: restingBorderColor),
                ),
          focusedBorder: boxed
              ? InputBorder.none
              : OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide: BorderSide(color: focusedBorderColor),
                ),
          suffixStyle: TextStyle(
            color: SailTheme.of(context).colors.inactiveNavText,
            fontSize: textSize,
          ),
          suffixText: suffix,
          border: boxed
              ? InputBorder.none
              : OutlineInputBorder(
                  borderRadius: borderRadius,
                  borderSide: BorderSide(color: restingBorderColor),
                ),
          suffixIcon: boxed ? null : trailing,
          prefixStyle: TextStyle(
            color: SailTheme.of(context).colors.inactiveNavText,
            fontSize: textSize,
          ),
          prefixText: prefix,
          prefix: prefixWidget,
          prefixIcon: prefixIcon,
          prefixIconConstraints: prefixIconConstraints,
          fillColor: fillColor,
          filled: !boxed,
          contentPadding: padding,
          helperText: helperText,
          hintText: hintText,
          helperStyle: SailStyleValues.thirteen.copyWith(
            color: SailTheme.of(context).colors.inactiveNavText,
            fontSize: textSize,
          ),
          hintStyle: SailStyleValues.thirteen.copyWith(
            color: hintColor,
            fontSize: textSize,
          ),
        ),
      ),
    );

    final body = boxed
        ? _FieldBox(
            fillColor: fillColor,
            borderRadius: borderRadius,
            restingBorderColor: restingBorderColor,
            focusedBorderColor: focusedBorderColor,
            field: field,
            trailing: trailing,
            bottomWidget: bottomWidget,
          )
        : field;

    return SailColumn(
      spacing: SailStyleValues.padding08,
      children: [
        if (label != null) SailText.primary13(label!, bold: true),
        if (expands) Expanded(child: body) else body,
      ],
    );
  }

  static Widget tiny({
    required TextEditingController controller,
    required String hintText,
    String? label,
    String? suffix,
    String? prefix,
    TextFieldType textFieldType = TextFieldType.text,
  }) {
    return SailTextField(
      controller: controller,
      label: label,
      hintText: hintText,
      suffix: suffix,
      prefix: prefix,
      size: TextFieldSize.small,
      textFieldType: textFieldType,
    );
  }
}

/// The border and fill of a [SailTextField] drawn around the text, a suffix beside its first line and an
/// optional row under it.
class _FieldBox extends StatefulWidget {
  final Color fillColor;
  final BorderRadius borderRadius;
  final Color restingBorderColor;
  final Color focusedBorderColor;
  final Widget field;
  final Widget? trailing;
  final Widget? bottomWidget;

  const _FieldBox({
    required this.fillColor,
    required this.borderRadius,
    required this.restingBorderColor,
    required this.focusedBorderColor,
    required this.field,
    required this.trailing,
    required this.bottomWidget,
  });

  @override
  State<_FieldBox> createState() => _FieldBoxState();
}

class _FieldBoxState extends State<_FieldBox> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onFocusChange: (focused) => setState(() => _focused = focused),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: widget.fillColor,
          borderRadius: widget.borderRadius,
          border: Border.all(color: _focused ? widget.focusedBorderColor : widget.restingBorderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: widget.field),
                if (widget.trailing != null)
                  Padding(
                    padding: const EdgeInsets.only(top: _trailingTop),
                    child: widget.trailing,
                  ),
              ],
            ),
            if (widget.bottomWidget != null)
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 8, bottom: 8),
                child: Align(alignment: Alignment.centerLeft, child: widget.bottomWidget),
              ),
          ],
        ),
      ),
    );
  }

  // Centers a 32 px suffix on the first text line under the 11.5 px top content padding.
  static const _trailingTop = 3.5;
}
