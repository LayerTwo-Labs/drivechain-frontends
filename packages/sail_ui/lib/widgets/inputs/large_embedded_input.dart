import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';

class LargeEmbeddedInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool bitcoinInput;
  final Widget? suffixWidget;
  final String? suffixText;

  const LargeEmbeddedInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.bitcoinInput = false,
    this.suffixWidget,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return TextField(
      controller: controller,
      cursorColor: theme.colors.orange,
      style: TextStyle(
        color: SailTheme.of(context).colors.text,
        fontSize: 15,
      ),
      inputFormatters: [
        if (bitcoinInput) FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,8}')),
      ],
      decoration: InputDecoration(
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        hintText: hintText,
        suffix: suffixText != null ? SailText.mediumPrimary14(suffixText!) : null,
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
    final newText = newValue.text;

    if (newText.contains(',')) {
      return TextEditingValue(text: newText.replaceAll(',', ','));
    }

    return newValue;
  }
}
