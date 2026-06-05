import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

const _panelWidth = 380.0;
const _panelMaxListHeight = 360.0;

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    if (!GetIt.I.isRegistered<NotificationProvider>()) {
      return const SizedBox.shrink();
    }
    final provider = GetIt.I.get<NotificationProvider>();

    return SailButton(
      variant: ButtonVariant.icon,
      icon: SailSVGAsset.bell,
      small: true,
      onPressed: () async {
        final bounds = getGlobalBoundsForContext(context);
        await showSailMenu(
          context: context,
          preferredAnchorPoint: bounds.bottomRight,
          alignment: Alignment.topRight,
          menu: SailMenu(
            width: _panelWidth,
            items: [_NotificationPanel(provider: provider)],
          ),
        );
      },
    );
  }
}

class _NotificationPanel extends StatelessWidget implements SailMenuEntity {
  final NotificationProvider provider;

  const _NotificationPanel({required this.provider});

  @override
  double get height => _panelMaxListHeight;
  @override
  double get width => _panelWidth;

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return AnimatedBuilder(
      animation: provider,
      builder: (context, _) {
        final items = provider.history;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Row(
                children: [
                  Expanded(child: SailText.primary13('Notifications', bold: true)),
                  if (items.isNotEmpty)
                    SailButton(
                      variant: ButtonVariant.link,
                      label: 'Clear all',
                      small: true,
                      onPressed: () async => provider.clearAll(),
                    ),
                ],
              ),
            ),
            Divider(height: 1, color: theme.colors.divider),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: SailText.primary12('No notifications', color: theme.colors.textSecondary),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: _panelMaxListHeight),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  separatorBuilder: (context, _) => Divider(height: 1, color: theme.colors.divider),
                  itemBuilder: (context, i) => _NotificationRow(item: items[i], provider: provider),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _NotificationRow extends StatelessWidget {
  final NotificationItem item;
  final NotificationProvider provider;

  const _NotificationRow({required this.item, required this.provider});

  @override
  Widget build(BuildContext context) {
    final theme = SailTheme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: SailSVG.fromAsset(SailSVGAsset.iconInfo, color: _colorForType(item.dialogType)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: SailText.primary13(item.title, color: theme.colors.text, bold: true)),
                    const SizedBox(width: 8),
                    SailText.primary12(_timeAgo(item.timestamp), color: theme.colors.textTertiary),
                  ],
                ),
                SailText.primary12(item.content, color: theme.colors.textSecondary),
                for (final link in item.links) ...[
                  const SizedBox(height: 4),
                  NotificationLinkText(link: link),
                ],
              ],
            ),
          ),
          const SizedBox(width: 4),
          SailButton(
            variant: ButtonVariant.icon,
            icon: SailSVGAsset.iconClose,
            small: true,
            onPressed: () async => provider.dismiss(item.id),
          ),
        ],
      ),
    );
  }

  Color _colorForType(DialogType type) {
    switch (type) {
      case DialogType.info:
        return SailColorScheme.blue;
      case DialogType.error:
        return SailColorScheme.red;
      case DialogType.success:
        return SailColorScheme.green;
    }
  }
}

String _timeAgo(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inSeconds < 60) return 'just now';
  if (d.inMinutes < 60) return '${d.inMinutes}m ago';
  if (d.inHours < 24) return '${d.inHours}h ago';
  return '${d.inDays}d ago';
}
