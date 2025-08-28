import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';

class StaticField extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;

  const StaticField({super.key, required this.label, required this.value, this.copyable = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary13(label, color: context.sailTheme.colors.textSecondary),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: SailText.primary13(
                value,
                color: context.sailTheme.colors.text,
                monospace: true,
                overflow: TextOverflow.visible,
              ),
            ),
            if (copyable)
              SailButton(
                variant: ButtonVariant.icon,
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: value));
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Copied $label to clipboard'), duration: const Duration(seconds: 2)),
                  );
                },
                icon: SailSVGAsset.iconCopy,
              ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

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
    return InkWell(
      onTap: copyable
          ? () async {
              // If we contain spaces, make sure to copy a quoted string. This makes
              // it possible to copy-paste log file locations into a file viewer,
              // for example.
              var text = value;
              if (text.contains(' ')) {
                text = '"$text"';
              }

              await Clipboard.setData(ClipboardData(text: text));
              if (!context.mounted) {
                return;
              }
              showSnackBar(context, 'Copied $value');
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SailStyleValues.padding20, vertical: SailStyleValues.padding10),
        child: Row(
          children: [
            if (prefixWidget != null) prefixWidget!,
            if (label != null) SizedBox(width: 150, child: SailText.secondary13(label!)),
            SailText.primary13(value),
            Expanded(child: Container()),
            if (suffixWidget != null) suffixWidget!,
          ],
        ),
      ),
    );
  }
}

class StaticActionInfo extends StatelessWidget {
  final String text;

  const StaticActionInfo({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SailStyleValues.padding20, vertical: SailStyleValues.padding10),
      child: Row(
        children: [
          SailText.primary12(text, color: theme.colors.info),
          Expanded(child: Container()),
        ],
      ),
    );
  }
}
