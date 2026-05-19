import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

class NotificationProvider extends ChangeNotifier {
  final List<Widget> notifications = [];
  Logger log = GetIt.I.get<Logger>();

  final Future<void> Function()? onPressed;

  NotificationProvider({this.onPressed});

  void add({
    required String title,
    required String content,
    required DialogType dialogType,
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
      onPressed: onPressed,
    );

    notifications.insert(0, notification);
    if (notifications.length > 3) {
      // only show 3 notifications at a time
      notifications.removeLast();
    }
    notifyListeners();

    // Automatically dismiss the notification after a set duration
    Future.delayed(const Duration(seconds: 5), () {
      notifications.remove(notification);
      notifyListeners();
    });
  }
}
