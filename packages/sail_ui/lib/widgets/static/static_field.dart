import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/core/sail_snackbar.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';

class StaticActionField extends StatelessWidget {
  final String? label;
  final String value;
  final bool copyable;
  final Widget? suffixWidget;
  final Widget? prefixWidget;

  const StaticActionField({
    super.key,
    this.label,
    required this.value,
    this.copyable = false,
    this.suffixWidget,
    this.prefixWidget,
  });

  @override
  Widget build(BuildContext context) {
    return SailScaleButton(
      onPressed: copyable
          ? () async {
              await Clipboard.setData(
                ClipboardData(text: value),
              );
              if (!context.mounted) {
                return;
              }
              showSnackBar(context, "Copied '$value'");
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SailStyleValues.padding20,
          vertical: SailStyleValues.padding10,
        ),
        child: Row(
          children: [
            if (prefixWidget != null) prefixWidget!,
            if (label != null)
              SizedBox(
                width: 150,
                child: SailText.secondary13(label!),
              ),
            SailText.primary13(value),
            Expanded(child: Container()),
            if (suffixWidget != null) suffixWidget!,
          ],
        ),
      ),
    );
  }
}
