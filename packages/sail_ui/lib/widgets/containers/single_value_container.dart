import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/widgets/core/sail_snackbar.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';

class SingleValueContainer extends StatelessWidget {
  final String? label;
  final dynamic value;
  final double width;
  final String? trailingText;
  final Widget? icon;
  final Widget? prefixAction;
  final bool copyable;
  final String? customCopyValue;

  const SingleValueContainer({
    super.key,
    required this.value,
    required this.width,
    this.label,
    this.trailingText,
    this.icon,
    this.prefixAction,
    this.copyable = true,
    this.customCopyValue,
  });

  @override
  Widget build(BuildContext context) {
    return SailRow(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: SailStyleValues.padding08,
      children: [
        if (prefixAction != null) prefixAction!,
        if (prefixAction != null) const SailSpacing(SailStyleValues.padding12),
        if (icon != null)
          icon!
        else
          const SizedBox(
            width: 13,
          ),
        if (label != null)
          SizedBox(
            width: width,
            child: SailText.secondary12(label!),
          ),
        Expanded(
          child: SailScaleButton(
            onPressed: copyable
                ? () {
                    Clipboard.setData(ClipboardData(text: customCopyValue ?? value.toString()));
                    showSnackBar(context, 'Copied ${copyLabel()}');
                  }
                : null,
            child: SailText.primary12(value.toString()),
          ),
        ),
        if (trailingText != null) SailText.secondary12(trailingText!),
      ],
    );
  }

  String copyLabel() {
    final textToShow = label ?? customCopyValue ?? value.toString();
    if (textToShow.length > 50) {
      return '${textToShow.substring(0, 50)}...';
    }

    return textToShow;
  }
}
