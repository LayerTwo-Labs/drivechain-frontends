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
  final bool readOnly;
  final bool dense;
  final bool enabled;
  final int? minLines;
  final int? maxLines;
  final List<TextInputFormatter>? inputFormatters;

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
    this.readOnly = false,
    this.dense = false,
    this.enabled = true,
    this.minLines,
    this.maxLines,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final padding = EdgeInsets.symmetric(
      vertical: 11.5,
      horizontal: 12,
    );
    final textSize = size == TextFieldSize.regular ? 14.0 : 12.0;

    return SailColumn(
      spacing: SailStyleValues.padding08,
      children: [
        if (label != null)
          SailText.primary13(
            label!,
            bold: true,
          ),
        Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              selectionColor: theme.colors.primary.withValues(alpha: 0.2),
            ),
          ),
          child: TextField(
            autofocus: autofocus,
            enabled: enabled,
            mouseCursor: enabled ? WidgetStateMouseCursor.textable : SystemMouseCursors.forbidden,
            cursorColor: theme.colors.primary,
            controller: controller,
            focusNode: focusNode,
            onSubmitted: onSubmitted,
            readOnly: readOnly,
            style: SailStyleValues.fifteen.copyWith(
              color: SailTheme.of(context).colors.text,
              fontSize: textSize,
            ),
            inputFormatters: [
              if (textFieldType == TextFieldType.number) FilteringTextInputFormatter.allow(RegExp(r'^\d+$')),
              if (textFieldType == TextFieldType.bitcoin) FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,8}')),
              ...?inputFormatters,
            ],
            minLines: minLines,
            maxLines: maxLines,
            decoration: InputDecoration(
              isDense: true, // This helps reduce the minimum height
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                borderRadius: SailStyleValues.borderRadius,
                borderSide: BorderSide(color: theme.colors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: SailStyleValues.borderRadius,
                borderSide: BorderSide(color: theme.colors.text),
              ),
              suffixStyle: TextStyle(
                color: SailTheme.of(context).colors.textTertiary,
                fontSize: textSize,
              ),
              border: OutlineInputBorder(
                borderRadius: SailStyleValues.borderRadius,
                borderSide: BorderSide(color: theme.colors.border),
              ),
              suffixIcon: suffixWidget == null
                  ? null
                  : Align(
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
                    ),
              prefixStyle: TextStyle(
                color: SailTheme.of(context).colors.textTertiary,
                fontSize: textSize,
              ),
              prefixText: prefix,
              prefix: prefixWidget,
              prefixIcon: prefixIcon,
              prefixIconConstraints: prefixIconConstraints,
              fillColor: SailTheme.of(context).colors.background,
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
        ),
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
