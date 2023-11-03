import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';

class SailTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;

  const SailTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailColumn(
      spacing: SailStyleValues.padding08,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: 2,
          ),
          child: SailText.secondary13(label),
        ),
        TextField(
          cursorColor: SailColorScheme.orange,
          controller: controller,
          style: TextStyle(
            color: SailTheme.of(context).colors.text,
            fontSize: 15,
          ),
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
            fillColor: SailTheme.of(context).colors.background,
            filled: true,
            hintText: hintText,
            contentPadding: const EdgeInsets.all(
              SailStyleValues.padding15,
            ),
            hintStyle: TextStyle(
              color: SailTheme.of(context).colors.textTertiary,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}
