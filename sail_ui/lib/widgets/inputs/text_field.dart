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
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final padding = EdgeInsets.symmetric(vertical: 11.5, horizontal: 12);
    final textSize = size == TextFieldSize.regular ? 13.0 : 10.0;

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
          fontFamily: theme.chrome.fontFamily ?? (monospace ? 'IBMPlexMono' : null),
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
          enabledBorder: OutlineInputBorder(
            borderRadius: theme.chrome.radius,
            borderSide: BorderSide(color: theme.colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: theme.chrome.radius,
            borderSide: BorderSide(color: theme.colors.text),
          ),
          suffixStyle: TextStyle(
            color: SailTheme.of(context).colors.inactiveNavText,
            fontSize: textSize,
          ),
          suffixText: suffix,
          border: OutlineInputBorder(
            borderRadius: theme.chrome.radius,
            borderSide: BorderSide(color: theme.colors.border),
          ),
          suffixIcon: loading != null && loading!.enabled
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
              : null,
          prefixStyle: TextStyle(
            color: SailTheme.of(context).colors.inactiveNavText,
            fontSize: textSize,
          ),
          prefixText: prefix,
          prefix: prefixWidget,
          prefixIcon: prefixIcon,
          prefixIconConstraints: prefixIconConstraints,
          fillColor: theme.chrome.fieldsSunken ? theme.colors.formField : theme.colors.background,
          filled: true,
          contentPadding: padding,
          helperText: helperText,
          hintText: hintText,
          helperStyle: SailStyleValues.thirteen.copyWith(
            color: SailTheme.of(context).colors.inactiveNavText,
            fontSize: textSize,
          ),
          hintStyle: SailStyleValues.thirteen.copyWith(
            color: SailTheme.of(context).colors.inactiveNavText,
            fontSize: textSize,
          ),
        ),
      ),
    );

    return SailColumn(
      spacing: SailStyleValues.padding08,
      children: [
        if (label != null) SailText.primary13(label!, bold: true),
        if (expands) Expanded(child: field) else field,
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
