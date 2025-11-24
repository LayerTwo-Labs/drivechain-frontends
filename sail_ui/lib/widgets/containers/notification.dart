import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SailNotification extends StatelessWidget {
  final String title;
  final String content;
  final DialogType dialogType;
  final Function(String content) removeNotification;
  final Future<void> Function()? onPressed;

  const SailNotification({
    super.key,
    required this.title,
    required this.content,
    required this.dialogType,
    required this.removeNotification,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Material(
      color: Colors.transparent,
      child: Dismissible(
        key: Key(content),
        direction: DismissDirection.horizontal,
        onDismissed: (direction) {
          removeNotification(content);
        },
        child: InkWell(
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SailTheme.of(context).colors.backgroundSecondary,
              border: Border.all(
                color: SailTheme.of(context).colors.divider,
                width: 1,
              ),
              borderRadius: SailStyleValues.borderRadius,
              boxShadow: [
                BoxShadow(color: SailTheme.of(context).colors.shadow, blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailSVG.fromAsset(SailSVGAsset.iconInfo, color: findColorForType(dialogType)),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.primary13(title, color: theme.colors.text),
                    SailText.primary12(content, color: theme.colors.text),
                  ],
                ),
                const SizedBox(width: 8),
                SailButton(
                  variant: ButtonVariant.icon,
                  icon: SailSVGAsset.iconClose,
                  onPressed: () async {
                    removeNotification(content);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color findColorForType(DialogType dialogType) {
    switch (dialogType) {
      case DialogType.info:
        return SailColorScheme.blue;
      case DialogType.error:
        return SailColorScheme.red;
      case DialogType.success:
        return SailColorScheme.green;
    }
  }
}
