import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class ActionHeaderChip extends StatelessWidget {
  final String title;

  const ActionHeaderChip({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        color: theme.colors.chip,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: SailStyleValues.padding05,
          horizontal: SailStyleValues.padding10,
        ),
        child: SailText.secondary12(title),
      ),
    );
  }
}

class DialogHeaderChip extends StatelessWidget {
  final DialogType dialogType;
  final String action;

  const DialogHeaderChip({
    super.key,
    required this.action,
    required this.dialogType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        color: theme.colors.chip,
      ),
      child: Padding(
        padding: const EdgeInsets.all(
          SailStyleValues.padding05,
        ),
        child: SailRow(
          spacing: SailStyleValues.padding08,
          children: [
            SailSVG.fromAsset(findIconForType(dialogType)),
            SailText.secondary12(action, bold: true),
          ],
        ),
      ),
    );
  }

  SailSVGAsset findIconForType(DialogType dialogType) {
    switch (dialogType) {
      case DialogType.info:
        return SailSVGAsset.iconInfo;
      case DialogType.error:
        return SailSVGAsset.iconFailed;
      case DialogType.success:
        return SailSVGAsset.iconSuccess;
    }
  }
}
