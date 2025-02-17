import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';

class SingleValueContainer extends StatelessWidget {
  final String? label;
  final String? labelTooltip;
  final dynamic value;
  final double? width;
  final String? trailingText;
  final Widget? icon;
  final Widget? prefixAction;
  final bool copyable;
  final Color? color;

  const SingleValueContainer({
    super.key,
    required this.value,
    this.width,
    this.label,
    this.labelTooltip,
    this.trailingText,
    this.icon,
    this.prefixAction,
    this.copyable = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SailRow(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: SailStyleValues.padding08,
      children: [
        if (prefixAction != null) prefixAction!,
        if (prefixAction != null) const SailSpacing(SailStyleValues.padding04),
        if (icon != null) icon!,
        if (label != null)
          Tooltip(
            message: labelTooltip ?? '',
            child: width != null
                ? SizedBox(
                    width: width,
                    child: SailText.primary12(label!, color: color),
                  )
                : SailText.primary12(label!, color: color),
          ),
        Expanded(
          child: copyable
              ? SailScaleButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: value.toString()));
                    if (context.mounted) {
                      showSnackBar(context, 'Copied ${copyLabel()}');
                    }
                  },
                  child: SailText.primary12(value.toString()),
                )
              : SailText.primary12(value.toString()),
        ),
        if (trailingText != null) SailText.secondary12(trailingText!),
      ],
    );
  }

  String copyLabel() {
    final textToShow = label ?? value.toString();
    if (textToShow.length > 50) {
      return '${textToShow.substring(0, 50)}...';
    }

    return textToShow;
  }
}
