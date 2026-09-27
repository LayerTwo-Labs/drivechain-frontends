import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sail_ui/sail_ui.dart';

/// Returns whether the action was carried out. False leaves the banner unread,
/// so cancelling or failing keeps it on screen. The item comes along, because a
/// handler acts on what its own notification says, not on what the app reads
/// while the user reads the text.
typedef NotificationActionHandler = Future<bool> Function(BuildContext context, NotificationItem item);

/// Resolves a [NotificationItem.action] key to its handler. An unknown key is a
/// no-op, so a notification persisted by an older build cannot crash the banner.
class NotificationActions {
  final Map<String, NotificationActionHandler> _handlers;

  /// Action keys whose handler opens its own dialog. The generic card then stays
  /// shut: two dialogs in a row for one message read as a fault.
  final Set<String> ownDialogs;

  const NotificationActions(this._handlers, {this.ownDialogs = const {}});

  NotificationActionHandler? operator [](String key) => _handlers[key];
}

/// Strip pinned above the app for the newest unread banner notification. Shows
/// one at a time; tapping it runs its action, the ✕ just marks it read. An
/// item of style modalThenBanner also opens a modal one time.
class NotificationBanner extends StatefulWidget {
  const NotificationBanner({super.key});

  @override
  State<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<NotificationBanner> {
  bool _modalOpen = false;
  bool _actionRunning = false;
  NotificationProvider? _provider;

  @override
  void initState() {
    super.initState();
    if (GetIt.I.isRegistered<NotificationProvider>()) {
      _provider = GetIt.I.get<NotificationProvider>();
      _provider!.addListener(_onNotifications);
      WidgetsBinding.instance.addPostFrameCallback((_) => _onNotifications());
    }
  }

  @override
  void dispose() {
    _provider?.removeListener(_onNotifications);
    super.dispose();
  }

  void _onNotifications() => _openWhenFree();

  /// Opens a pending modal while the screen is free. The screen frees up at the
  /// end of an action and at the end of the loop, and a modal can arrive at any
  /// moment, so all three call this.
  void _openWhenFree() {
    final provider = _provider;
    if (!mounted || _modalOpen || _actionRunning || provider == null || provider.pendingModal == null) {
      return;
    }
    unawaited(_openPendingModal(provider));
  }

  /// Opens the modal of every item that waits for one, in turn. The mark goes
  /// in before the dialog, so a rebuild while it stands opens no second copy,
  /// and an item that arrives while one modal is open takes its turn after it.
  Future<void> _openPendingModal(NotificationProvider provider) async {
    if (_modalOpen) {
      return;
    }
    _modalOpen = true;
    try {
      while (mounted) {
        final item = provider.pendingModal;
        if (item == null) {
          return;
        }
        if (!mounted) {
          return;
        }
        if (_ownsDialog(item.action)) {
          // The handler carries the whole message, and _actionRunning stops a
          // second copy, so the mark waits for the action. A mark before a busy
          // action drops the modal for good. The loop ends while another action
          // owns the screen, and the end of that action opens this one.
          if (!await _runAction(context, provider, item)) {
            return;
          }
          await provider.markModalShown(item.id);
          continue;
        }
        await provider.markModalShown(item.id);
        if (!mounted) {
          return;
        }
        final confirmed = await showThemedDialog<bool>(
          context: context,
          builder: (context) => SailAlertCard(
            title: item.title,
            subtitle: item.content,
            onConfirm: () async => Navigator.of(context).pop(true),
          ),
        );
        if (confirmed == true && mounted) {
          await _runAction(context, provider, item);
        }
      }
    } finally {
      _modalOpen = false;
      _openWhenFree();
    }
  }

  bool _ownsDialog(String action) =>
      action.isNotEmpty &&
      GetIt.I.isRegistered<NotificationActions>() &&
      GetIt.I.get<NotificationActions>().ownDialogs.contains(action);

  /// Runs the item's action, and reports whether it ran. One at a time: the modal
  /// closes before the action ends, and a tap on the banner behind it would start
  /// a second one. False means another action owns the screen, so the caller
  /// leaves this item for its turn.
  Future<bool> _runAction(BuildContext context, NotificationProvider provider, NotificationItem item) async {
    if (_actionRunning) {
      return false;
    }
    _actionRunning = true;
    try {
      final handler = GetIt.I.isRegistered<NotificationActions>()
          ? GetIt.I.get<NotificationActions>()[item.action]
          : null;
      if (handler != null && !await handler(context, item)) {
        return true;
      }
      await provider.markRead(item.id);
      return true;
    } finally {
      _actionRunning = false;
      _openWhenFree();
    }
  }

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
        if (item == null) {
          return const SizedBox.shrink();
        }

        final theme = SailTheme.of(context);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () async => _runAction(context, provider, item),
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
                Expanded(child: SailText.secondary12(item.content, color: theme.colors.orange)),
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
