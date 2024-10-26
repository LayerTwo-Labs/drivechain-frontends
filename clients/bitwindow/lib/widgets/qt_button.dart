import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sail_ui/sail_ui.dart';

class QtButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String? label;
  final Widget? child;
  final ButtonSize size;
  final SailButtonStyle style;

  final EdgeInsets? padding;
  final bool disabled;
  final bool loading;

  const QtButton({
    super.key,
    required this.onPressed,
    this.style = SailButtonStyle.primary,
    this.label,
    this.child,
    this.padding,
    this.size = ButtonSize.regular,
    this.disabled = false,
    this.loading = false,
  }) : assert(label != null || child != null, 'Either label or child must be provided');

  @override
  Widget build(BuildContext context) {
    final theme = context.sailTheme;
    final backgroundColor = style == SailButtonStyle.secondary ? theme.colors.backgroundSecondary : theme.colors.text;
    final foregroundColor = style == SailButtonStyle.secondary ? theme.colors.text : theme.colors.backgroundSecondary;

    final buttonPadding = padding ??
        EdgeInsets.symmetric(
          vertical: SailStyleValues.padding08,
          horizontal: SailStyleValues.padding16,
        );

    final content = Row(
      mainAxisSize: size == ButtonSize.small ? MainAxisSize.min : MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (child != null) child!,
        if (child != null && label != null) SizedBox(width: SailStyleValues.padding08),
        if (label != null)
          SailText.primary15(
            label!,
            bold: true,
            color: foregroundColor,
          ),
      ],
    );

    return IntrinsicWidth(
      child: SailScaleButton(
        onPressed: onPressed,
        disabled: disabled,
        loading: loading,
        color: backgroundColor,
        child: Container(
          width: size == ButtonSize.regular ? double.infinity : null,
          padding: buttonPadding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: SailStyleValues.borderRadiusButton,
          ),
          child: content,
        ),
      ),
    );
  }
}

class CopyButton extends StatelessWidget {
  final String text;

  const CopyButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return QtButton(
      size: ButtonSize.small,
      label: 'Copy',
      style: SailButtonStyle.secondary,
      onPressed: () async {
        await Clipboard.setData(ClipboardData(text: text)).then((_) {
          if (context.mounted) showSnackBar(context, 'Copied $text');
        }).catchError((error) {
          if (context.mounted) showSnackBar(context, 'Could not copy $text: $error ');
        });
      },
      child: SailSVG.fromAsset(
        SailSVGAsset.iconCopy,
        color: SailTheme.of(context).colors.text,
      ),
    );
  }
}
