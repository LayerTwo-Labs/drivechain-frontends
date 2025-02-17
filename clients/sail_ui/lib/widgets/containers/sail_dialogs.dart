import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

Future<T?> showThemedDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) async {
  final theme = SailTheme.of(context);
  return await showDialog(
    context: context,
    barrierColor: theme.colors.background.withValues(alpha: 0.4),
    builder: builder,
  );
}

Future<T?> infoDialog<T>({
  required BuildContext context,
  required String title,
  required String subtitle,
  required Future<void> Function() onConfirm,
}) async {
  return await _baseDialogSimple(
    context: context,
    title: title,
    subtitle: subtitle,
    onConfirm: onConfirm,
  );
}

Future<T?> successDialog<T>({
  required BuildContext context,
  required String action,
  required String title,
  required String subtitle,
}) async {
  return await _baseDialogSimple(
    context: context,
    title: title,
    subtitle: subtitle,
    onConfirm: null,
  );
}

Future<T?> errorDialog<T>({
  required BuildContext context,
  required String action,
  required String title,
  required String subtitle,
}) async {
  return await _baseDialogSimple(
    context: context,
    title: title,
    subtitle: subtitle,
    onConfirm: null,
  );
}

Future<T?> _baseDialogSimple<T>({
  required BuildContext context,
  required String title,
  required String subtitle,
  required Future<void> Function()? onConfirm,
}) async {
  final theme = SailTheme.of(context);

  return widgetDialog(
    context: context,
    title: title,
    child: SailColumn(
      spacing: SailStyleValues.padding12,
      mainAxisSize: MainAxisSize.min,
      children: [
        SailText.primary15(
          subtitle,
          color: theme.colors.textSecondary,
        ),
        DialogButtons(onPressed: onConfirm),
      ],
    ),
  );
}

Future<T?> widgetDialog<T>({
  required String title,
  required BuildContext context,
  required Widget child,
  String? subtitle,
  double maxWidth = 740,
}) async {
  final theme = SailTheme.of(context);

  return showThemedDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: theme.colors.backgroundSecondary,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: SailRawCard(
          title: title,
          subtitle: subtitle ?? '',
          withCloseButton: true,
          child: child,
        ),
      ),
    ),
  );
}

class CardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? error;

  const CardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return SailColumn(
      spacing: 0,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SailText.primary20(
          title,
          bold: true,
        ),
        if (error != null || subtitle != null)
          SailText.primary12(
            error ?? subtitle!,
            color: error != null ? SailColorScheme.red : theme.colors.textTertiary,
            overflow: TextOverflow.visible,
          ),
      ],
    );
  }
}

enum DialogType { info, error, success }

class DialogHeader extends StatelessWidget {
  final Future<void> Function() onClose;
  final String title;
  final String? subtitle;

  const DialogHeader({
    super.key,
    required this.onClose,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding08,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CardHeader(title: title, subtitle: subtitle),
        ),
        SailScaleButton(
          onPressed: onClose,
          style: SailButtonStyle.secondary,
          child: SailSVG.icon(SailSVGAsset.iconClose),
        ),
      ],
    );
  }
}

class DialogButtons extends StatelessWidget {
  final Future<void> Function()? onPressed;

  const DialogButtons({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding08,
      children: [
        Expanded(child: Container()),
        SailTextButton(
          label: onPressed != null ? 'Cancel' : 'Close',
          onPressed: () async {
            Navigator.of(context).pop();
          },
        ),
        if (onPressed != null)
          SailButton.primary(
            'Confirm',
            onPressed: onPressed!,
            size: ButtonSize.regular,
          ),
      ],
    );
  }
}
