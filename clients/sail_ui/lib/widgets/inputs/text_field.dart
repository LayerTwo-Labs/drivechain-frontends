import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';

enum TextFieldSize { small, regular }

enum TextFieldType { number, bitcoin, text }

class SailTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? label;
  final String hintText;
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
    this.textFieldType = TextFieldType.text,
    this.suffix,
    this.suffixWidget,
    this.prefix,
    this.prefixWidget,
    this.prefixIcon,
    this.prefixIconConstraints,
    this.size = TextFieldSize.regular,
    this.focusNode,
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
    final padding = size != TextFieldSize.regular
        ? EdgeInsets.all(
            theme.dense ? SailStyleValues.padding12 : SailStyleValues.padding16,
          )
        : EdgeInsets.symmetric(
            vertical: theme.dense ? SailStyleValues.padding08 : SailStyleValues.padding10,
            horizontal: theme.dense ? SailStyleValues.padding12 : SailStyleValues.padding16,
          );
    final textSize = size == TextFieldSize.regular ? 15.0 : 12.0;

    return SailColumn(
      spacing: SailStyleValues.padding08,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(
              left: 2,
            ),
            child: SailText.secondary15(label!),
          ),
        TextField(
          enabled: enabled,
          mouseCursor: enabled ? WidgetStateMouseCursor.textable : SystemMouseCursors.forbidden,
          cursorColor: theme.colors.primary,
          controller: controller,
          focusNode: focusNode,
          onSubmitted: onSubmitted,
          readOnly: readOnly,
          style: SailStyleValues.fifteen.copyWith(
            color: SailTheme.of(context).colors.text,
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
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              borderSide: BorderSide(color: theme.colors.background),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              borderSide: BorderSide(color: theme.colors.text),
            ),
            suffixStyle: TextStyle(
              color: SailTheme.of(context).colors.textTertiary,
              fontSize: textSize,
            ),
            suffixText: suffix,
            suffix: suffixWidget == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: SailStyleValues.padding08),
                    child: suffixWidget,
                  ),
            prefixStyle: TextStyle(
              color: SailTheme.of(context).colors.textTertiary,
              fontSize: textSize,
            ),
            prefixText: prefix,
            prefix: prefixWidget,
            prefixIcon: prefixIcon,
            prefixIconConstraints: prefixIconConstraints,
            fillColor: SailTheme.of(context).colors.backgroundSecondary,
            filled: true,
            contentPadding: padding,
            hintText: hintText,
            hintStyle: SailStyleValues.fifteen.copyWith(
              color: SailTheme.of(context).colors.textTertiary,
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
