import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

class NotificationProvider extends ChangeNotifier {
  final List<Widget> notifications = [];
  final List<NotificationItem> history = [];
  Logger log = GetIt.I.get<Logger>();

  final Future<void> Function()? onPressed;

  NotificationProvider({this.onPressed}) {
    if (GetIt.I.isRegistered<ClientSettings>()) {
      unawaited(_load());
    }
  }

  /// Merges rather than replaces: loading is async, so anything added while it
  /// was in flight would otherwise be dropped.
  Future<void> _load() async {
    final loaded = await GetIt.I.get<ClientSettings>().getValue(NotificationHistorySetting());
    final existing = history.map((n) => n.id).toSet();
    history.addAll(loaded.value.items.where((n) => !existing.contains(n.id)));
    history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
  }

  Future<void> _persist() async {
    if (!GetIt.I.isRegistered<ClientSettings>()) return;
    await GetIt.I.get<ClientSettings>().setValue(
      NotificationHistorySetting(newValue: NotificationHistory(items: history)),
    );
  }

  /// The banner to pin, or null. Only the newest unread one is ever shown.
  NotificationItem? get activeBanner {
    for (final item in history) {
      if (item.style == NotificationStyle.banner && !item.read) return item;
    }
    return null;
  }

  /// [id] makes the notification idempotent — re-adding an id already in
  /// history is a no-op, so a poll loop can call this freely.
  void add({
    required String title,
    required String content,
    required DialogType dialogType,
    List<NotificationLink> links = const [],
    Future<void> Function()? onPressed,
    NotificationStyle style = NotificationStyle.toast,
    String action = '',
    String? id,
  }) {
    if (id != null && history.any((n) => n.id == id)) return;

    final timestamp = DateTime.now();
    history.insert(
      0,
      NotificationItem(
        id: id ?? timestamp.microsecondsSinceEpoch.toString(),
        title: title,
        content: content,
        dialogType: dialogType,
        timestamp: timestamp,
        links: links,
        style: style,
        action: action,
      ),
    );
    unawaited(_persist());
    notifyListeners();

    // A banner is already pinned on screen; a toast on top would double up.
    if (style == NotificationStyle.banner) return;

    late final SailNotification notification;
    notification = SailNotification(
      key: Key(content),
      title: title,
      content: content,
      removeNotification: (_) {
        notifications.remove(notification);
        notifyListeners();
      },
      dialogType: dialogType,
      links: links,
      onPressed: onPressed,
    );

    notifications.insert(0, notification);
    if (notifications.length > 3) {
      // only show 3 notifications at a time
      notifications.removeLast();
    }

    // Automatically dismiss the notification after a set duration
    Future.delayed(const Duration(seconds: 5), () {
      notifications.remove(notification);
      notifyListeners();
    });
  }

  /// Drops the pinned banner. The entry stays in the bell history.
  Future<void> markRead(String id) async {
    final i = history.indexWhere((n) => n.id == id);
    if (i == -1 || history[i].read) return;
    history[i] = history[i].copyWith(read: true);
    await _persist();
    notifyListeners();
  }

  Future<void> dismiss(String id) async {
    history.removeWhere((n) => n.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> clearAll() async {
    history.clear();
    await _persist();
    notifyListeners();
  }
}
