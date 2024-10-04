import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:sail_ui/sail_ui.dart';

class NotificationProvider extends ChangeNotifier {
  final List<Widget> notifications = [];
  Logger log = GetIt.I.get<Logger>();

  final Function()? onPressed;

  NotificationProvider({this.onPressed});

  void add({
    required String title,
    required String content,
    required DialogType dialogType,
    Function()? onPressed,
  }) {
    final notification = SailNotification(
      title: title,
      content: content,
      removeNotification: (content) => notifications.removeWhere((element) => element.key == Key(content)),
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
