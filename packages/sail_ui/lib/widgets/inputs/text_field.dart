import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final padding = size != TextFieldSize.regular
        ? const EdgeInsets.all(
            SailStyleValues.padding15,
          )
        : const EdgeInsets.symmetric(
            vertical: SailStyleValues.padding10,
            horizontal: SailStyleValues.padding15,
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
            child: SailText.secondary13(label!),
          ),
        TextField(
          cursorColor: theme.colors.primary,
          controller: controller,
          focusNode: focusNode,
          onSubmitted: onSubmitted,
          style: TextStyle(
            color: SailTheme.of(context).colors.text,
            fontSize: textSize,
          ),
          inputFormatters: [
            if (textFieldType == TextFieldType.number) FilteringTextInputFormatter.allow(RegExp(r'^\d+$')),
            if (textFieldType == TextFieldType.bitcoin) FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,8}')),
          ],
          decoration: InputDecoration(
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              borderSide: BorderSide(color: theme.colors.formFieldBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              borderSide: BorderSide(color: theme.colors.formFieldBorder),
            ),
            suffixStyle: TextStyle(
              color: SailTheme.of(context).colors.textTertiary,
              fontSize: textSize,
            ),
            suffixText: suffix,
            suffix: Padding(
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
            fillColor: SailTheme.of(context).colors.background,
            filled: true,
            contentPadding: padding,
            isDense: true,
            hintText: hintText,
            hintStyle: TextStyle(
              color: SailTheme.of(context).colors.textTertiary,
              fontSize: textSize,
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
