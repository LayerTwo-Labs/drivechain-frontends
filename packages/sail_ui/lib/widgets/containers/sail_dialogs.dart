import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';
import 'package:sail_ui/widgets/core/sail_text.dart';

Future<T?> showThemedDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) async {
  final theme = SailTheme.of(context);
  return await showDialog(
    context: context,
    barrierColor: theme.colors.background.withOpacity(0.4),
    builder: builder,
  );
}

Future<T?> infoDialog<T>({
  required BuildContext context,
  required String action,
  required String title,
  required String subtitle,
  required VoidCallback onConfirm,
}) async {
  return await _baseDialogSimple(
    context: context,
    action: action,
    title: title,
    subtitle: subtitle,
    dialogType: DialogType.info,
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
    action: action,
    title: title,
    subtitle: subtitle,
    dialogType: DialogType.success,
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
    action: action,
    title: title,
    subtitle: subtitle,
    dialogType: DialogType.error,
    onConfirm: null,
  );
}

Future<T?> _baseDialogSimple<T>({
  required BuildContext context,
  required String action,
  required String title,
  required String subtitle,
  required DialogType dialogType,
  required VoidCallback? onConfirm,
}) async {
  return widgetDialog(
    context: context,
    action: action,
    dialogType: dialogType,
    child: SailColumn(
      spacing: 0,
      children: [
        const SailSpacing(SailStyleValues.padding12),
        SailText.primary20(title),
        const SailSpacing(SailStyleValues.padding08),
        SailText.secondary13(subtitle),
        const SailSpacing(SailStyleValues.padding30),
        DialogButtons(onPressed: onConfirm),
      ],
    ),
  );
}

Future<T?> widgetDialog<T>({
  required BuildContext context,
  required String action,
  required DialogType dialogType,
  required Widget child,
  double maxWidth = 640,
}) async {
  final theme = SailTheme.of(context);

  return showThemedDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: theme.colors.actionHeader,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: SailRawCard(
          child: Padding(
            padding: const EdgeInsets.all(
              SailStyleValues.padding12,
            ),
            child: SailColumn(
              spacing: 0,
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogHeader(
                  action: action,
                  dialogType: dialogType,
                  onClose: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                ),
                child,
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

enum DialogType { info, error, success }

class DialogHeader extends StatelessWidget {
  final DialogType dialogType;
  final String action;
  final VoidCallback onClose;

  const DialogHeader({
    super.key,
    required this.dialogType,
    required this.action,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SailRow(
      spacing: SailStyleValues.padding08,
      children: [
        DialogHeaderChip(
          action: action,
          dialogType: dialogType,
        ),
        SailSVG.fromAsset(SailSVGAsset.iconArrowForward),
        SailText.primary12(textForType(dialogType)),
        Expanded(child: Container()),
        SailScaleButton(
          onPressed: onClose,
          child: SailSVG.icon(SailSVGAsset.iconClose),
        ),
      ],
    );
  }

  String textForType(DialogType dialogType) {
    switch (dialogType) {
      case DialogType.info:
        return 'Confirm action';
      case DialogType.error:
        return 'Error';
      case DialogType.success:
        return 'Success';
    }
  }
}

class DialogButtons extends StatelessWidget {
  final VoidCallback? onPressed;

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
          onPressed: () {
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
