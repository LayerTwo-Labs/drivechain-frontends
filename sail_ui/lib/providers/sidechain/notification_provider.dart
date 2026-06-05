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

  Future<void> _load() async {
    final loaded = await GetIt.I.get<ClientSettings>().getValue(NotificationHistorySetting());
    history
      ..clear()
      ..addAll(loaded.value.items);
    notifyListeners();
  }

  Future<void> _persist() async {
    if (!GetIt.I.isRegistered<ClientSettings>()) return;
    await GetIt.I.get<ClientSettings>().setValue(
      NotificationHistorySetting(newValue: NotificationHistory(items: history)),
    );
  }

  void add({
    required String title,
    required String content,
    required DialogType dialogType,
    List<NotificationLink> links = const [],
    Future<void> Function()? onPressed,
  }) {
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

    final timestamp = DateTime.now();
    history.insert(
      0,
      NotificationItem(
        id: timestamp.microsecondsSinceEpoch.toString(),
        title: title,
        content: content,
        dialogType: dialogType,
        timestamp: timestamp,
        links: links,
      ),
    );
    unawaited(_persist());
    notifyListeners();

    // Automatically dismiss the notification after a set duration
    Future.delayed(const Duration(seconds: 5), () {
      notifications.remove(notification);
      notifyListeners();
    });
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
