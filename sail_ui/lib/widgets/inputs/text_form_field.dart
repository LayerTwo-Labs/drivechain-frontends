import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SailTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final String? errorText;
  final bool readOnly;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final TextFieldSize? size;
  final bool enabled;
  final FocusNode? focusNode;
  final String? suffix;
  final Widget? suffixWidget;
  final String? prefix;
  final Widget? prefixWidget;
  final Widget? prefixIcon;
  final BoxConstraints? prefixIconConstraints;

  const SailTextFormField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.errorText,
    this.readOnly = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines,
    this.size,
    this.enabled = true,
    this.focusNode,
    this.suffix,
    this.suffixWidget,
    this.prefix,
    this.prefixWidget,
    this.prefixIcon,
    this.prefixIconConstraints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);
    final padding = size != TextFieldSize.regular
        ? EdgeInsets.all(
            theme.dense ? SailStyleValues.padding08 : SailStyleValues.padding16,
          )
        : EdgeInsets.symmetric(
            vertical: theme.dense ? SailStyleValues.padding04 : SailStyleValues.padding10,
            horizontal: theme.dense ? SailStyleValues.padding10 : SailStyleValues.padding16,
          );
    final textSize = size == TextFieldSize.regular ? 15.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(
              left: 2,
            ),
            child: SailText.primary12(label!),
          ),
        TextFormField(
          enabled: enabled,
          mouseCursor: enabled ? WidgetStateMouseCursor.textable : SystemMouseCursors.forbidden,
          cursorColor: theme.colors.primary,
          cursorHeight: textSize,
          controller: controller,
          focusNode: focusNode,
          readOnly: readOnly,
          decoration: InputDecoration(
            errorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              borderSide: BorderSide(color: theme.colors.error),
            ),
            disabledBorder: InputBorder.none,
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              borderSide: BorderSide(color: theme.colors.error),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              borderSide: BorderSide(color: theme.colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              borderSide: BorderSide(color: theme.colors.border),
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
            isDense: theme.dense,
            hintText: hintText,
            hintStyle: TextStyle(
              color: SailTheme.of(context).colors.textTertiary,
              fontSize: textSize,
            ),
          ),
          style: SailStyleValues.thirteen,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
        ),
      ],
    );
  }
}
