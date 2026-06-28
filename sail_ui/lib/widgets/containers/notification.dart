import 'package:flutter/material.dart';
import 'package:sail_ui/sail_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class SailNotification extends StatelessWidget {
  final String title;
  final String content;
  final DialogType dialogType;
  final Function(String content) removeNotification;
  final List<NotificationLink> links;
  final Future<void> Function()? onPressed;

  const SailNotification({
    super.key,
    required this.title,
    required this.content,
    required this.dialogType,
    required this.removeNotification,
    this.links = const [],
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
              color: theme.colors.backgroundSecondary,
              border: Border.all(
                color: theme.chrome.terminalStyle ? theme.colors.border : theme.colors.divider,
                width: 1,
              ),
              borderRadius: theme.chrome.terminalStyle ? theme.chrome.radiusSmall : SailStyleValues.borderRadius,
              boxShadow: theme.chrome.terminalStyle
                  ? null
                  : [
                      BoxShadow(
                        color: theme.colors.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SailSVG.fromAsset(
                  SailSVGAsset.iconInfo,
                  color: findColorForType(dialogType),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SailText.primary13(title, color: theme.colors.text),
                    SailText.primary12(content, color: theme.colors.text),
                    for (final link in links) ...[
                      const SizedBox(height: 4),
                      NotificationLinkText(link: link),
                    ],
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

/// Tappable notification link rendered in the chain's primary color, underlined.
class NotificationLinkText extends StatelessWidget {
  final NotificationLink link;

  const NotificationLinkText({super.key, required this.link});

  @override
  Widget build(BuildContext context) {
    final primary = SailTheme.of(context).colors.primary;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => launchUrl(Uri.parse(link.url)),
        child: SailText.primary12(link.text, color: primary, decoration: TextDecoration.underline),
      ),
    );
  }
}
