import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:sail_ui/theme/theme.dart';

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
          color: theme.colors.actionHeader.withOpacity(0.8),
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
                          Text(
                            title,
                            style: const TextStyle(color: Colors.white),
                            softWrap: true,
                          ),
                        ],
                      ),
                      Text(
                        content,
                        style: TextStyle(color: Colors.white.withOpacity(0.6)),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                    ],
                  ),
                ),
                SailScaleButton(
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
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
