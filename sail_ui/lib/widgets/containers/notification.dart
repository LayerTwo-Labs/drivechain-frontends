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
              boxShadow: [
                BoxShadow(color: SailTheme.of(context).colors.shadow, blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 250),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SailSVG.fromAsset(SailSVGAsset.iconInfo, color: findColorForType(dialogType)),
                          const SizedBox(width: 8),
                          SailText.primary13(title, color: theme.colors.text, overflow: TextOverflow.visible),
                        ],
                      ),
                      SailText.primary12(content, color: theme.colors.text, overflow: TextOverflow.visible),
                    ],
                  ),
                ),
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
