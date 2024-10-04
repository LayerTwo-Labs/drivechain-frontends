import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';

class SailNotification extends StatelessWidget {
  final String title;
  final String content;
  final DialogType dialogType;
  final Function(String content) removeNotification;
  final Function()? onPressed;

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

    return Dismissible(
      key: Key(content),
      direction: DismissDirection.horizontal,
      onDismissed: (direction) {
        removeNotification(content);
      },
      child: SailScaleButton(
        onPressed: onPressed,
        child: Card(
          color: theme.colors.text,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 250,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SailSVG.fromAsset(SailSVGAsset.iconInfo, color: findColorForType(dialogType)),
                          const SizedBox(width: 8),
                          SailText.primary13(title, color: theme.colors.background),
                        ],
                      ),
                      SailText.primary12(content, color: theme.colors.background),
                    ],
                  ),
                ),
                SailScaleButton(
                  child: Icon(
                    Icons.close,
                    color: theme.colors.background,
                    size: 14,
                  ),
                  onPressed: () {
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
