import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_snackbar.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';

class StaticActionField extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;
  final Widget? suffixWidget;

  const StaticActionField({
    super.key,
    required this.label,
    required this.value,
    this.copyable = false,
    this.suffixWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return BScaleButton(
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);

        if (copyable) {
          await Clipboard.setData(
            ClipboardData(text: value),
          );
          showSnackBar(theme, messenger, 'Copied address');
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SailStyleValues.padding20,
          vertical: SailStyleValues.padding10,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 130,
              child: SailText.primary14(label),
            ),
            SailText.primary14(value),
            Expanded(child: Container()),
            if (suffixWidget != null) suffixWidget!,
          ],
        ),
      ),
    );
  }
}
