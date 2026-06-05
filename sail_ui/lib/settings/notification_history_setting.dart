import 'dart:convert';

import 'package:sail_ui/sail_ui.dart';

class NotificationHistory {
  final List<NotificationItem> items;

  NotificationHistory({this.items = const []});

  String toJson() => json.encode(items.map((i) => i.toMap()).toList());

  factory NotificationHistory.fromJson(String source) {
    try {
      final decoded = json.decode(source) as List;
      return NotificationHistory(
        items: decoded.map((e) => NotificationItem.fromMap(Map<String, dynamic>.from(e))).toList(),
      );
    } catch (e) {
      return NotificationHistory();
    }
  }
}

class NotificationHistorySetting extends SettingValue<NotificationHistory> {
  NotificationHistorySetting({super.newValue});

  @override
  String get key => 'notification_history';

  @override
  NotificationHistory defaultValue() => NotificationHistory();

  @override
  String toJson() => value.toJson();

  @override
  NotificationHistory? fromJson(String jsonString) => NotificationHistory.fromJson(jsonString);

  @override
  SettingValue<NotificationHistory> withValue([NotificationHistory? value]) {
    return NotificationHistorySetting(newValue: value);
  }
}
