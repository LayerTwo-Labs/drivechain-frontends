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
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) 
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: SailText.primary13(label!),
          ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: context.sailTheme.colors.formFieldBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: context.sailTheme.colors.formFieldBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: context.sailTheme.colors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: context.sailTheme.colors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: context.sailTheme.colors.error),
            ),
            filled: true,
            fillColor: context.sailTheme.colors.formField,
          ),
          style: SailStyleValues.thirteen,
          readOnly: readOnly,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
        ),
      ],
    );
  }
}