import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

typedef NotificationActionHandler = Future<void> Function(BuildContext context);

/// Resolves a [NotificationItem.action] key to its handler. An unknown key is a
/// no-op, so a notification persisted by an older build cannot crash the banner.
class NotificationActions {
  final Map<String, NotificationActionHandler> _handlers;

  const NotificationActions(this._handlers);

  NotificationActionHandler? operator [](String key) => _handlers[key];
}

/// Strip pinned above the app for the newest unread banner notification. Shows
/// one at a time; tapping it runs its action, the ✕ just marks it read.
class NotificationBanner extends StatelessWidget {
  const NotificationBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!GetIt.I.isRegistered<NotificationProvider>()) {
      return const SizedBox.shrink();
    }
    final provider = GetIt.I.get<NotificationProvider>();

    return AnimatedBuilder(
      animation: provider,
      builder: (context, _) {
        final item = provider.activeBanner;
        if (item == null) return const SizedBox.shrink();

        final theme = SailTheme.of(context);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async {
            final handler = GetIt.I.isRegistered<NotificationActions>()
                ? GetIt.I.get<NotificationActions>()[item.action]
                : null;
            if (handler != null) await handler(context);
            await provider.markRead(item.id);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: theme.colors.orange.withValues(alpha: 0.08),
              border: Border(bottom: BorderSide(color: theme.colors.divider)),
            ),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(color: theme.colors.orange, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                SailText.secondary12(item.title, bold: true, color: theme.colors.text),
                const SizedBox(width: 10),
                Flexible(child: SailText.secondary12(item.content, color: theme.colors.orange)),
                const Spacer(),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async => provider.markRead(item.id),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: SailText.secondary13('✕', color: theme.colors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
