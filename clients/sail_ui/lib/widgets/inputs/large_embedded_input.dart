import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';

class LargeEmbeddedInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool bitcoinInput;
  final bool numberInput;
  final Widget? suffixWidget;
  final String? suffixText;
  final bool autofocus;
  final bool disabled;

  const LargeEmbeddedInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.bitcoinInput = false,
    this.numberInput = false,
    this.suffixWidget,
    this.suffixText,
    this.autofocus = false,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return TextField(
      autofocus: autofocus,
      enabled: !disabled,
      controller: controller,
      cursorColor: theme.colors.primary,
      style: TextStyle(
        color: SailTheme.of(context).colors.text,
        fontSize: 15,
      ),
      inputFormatters: [
        if (bitcoinInput) FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,8}')),
        if (numberInput) FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        if (bitcoinInput || numberInput) CommaReplacerInputFormatter(),
      ],
      decoration: InputDecoration(
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        hintText: hintText,
        suffix: suffixText != null ? SailText.primary13(suffixText!, bold: true) : null,
        contentPadding: const EdgeInsets.all(SailStyleValues.padding20),
        hintStyle: TextStyle(
          color: SailTheme.of(context).colors.textHint,
          fontSize: 15,
        ),
      ),
    );
  }
}

class BitcoinTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;

    if (newText.contains('.') && newText.substring(newText.indexOf('.') + 1).length > 8) {
      return oldValue;
    }
    if (newText.contains(',') && newText.substring(newText.indexOf(',') + 1).length > 8) {
      return oldValue;
    }

    return newValue;
  }
}

class CommaReplacerInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll(',', '.');

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newValue.selection.end),
    );
  }
}
