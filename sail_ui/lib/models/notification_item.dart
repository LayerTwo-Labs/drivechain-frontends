import 'package:sail_ui/sail_ui.dart';

/// A tappable link attached to a notification (e.g. "View transaction").
class NotificationLink {
  final String text;
  final String url;

  const NotificationLink({required this.text, required this.url});

  Map<String, dynamic> toMap() => {'text': text, 'url': url};

  factory NotificationLink.fromMap(Map<String, dynamic> map) => NotificationLink(
    text: map['text'] ?? '',
    url: map['url'] ?? '',
  );
}

/// A persisted notification shown in the bell history list.
class NotificationItem {
  final String id;
  final String title;
  final String content;
  final DialogType dialogType;
  final DateTime timestamp;
  final List<NotificationLink> links;

  NotificationItem({
    required this.id,
    required this.title,
    required this.content,
    required this.dialogType,
    required this.timestamp,
    this.links = const [],
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'dialogType': dialogType.index,
    'timestamp': timestamp.toIso8601String(),
    'links': links.map((l) => l.toMap()).toList(),
  };

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    final rawLinks = map['links'];
    return NotificationItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      dialogType: DialogType.values[(map['dialogType'] ?? 0).clamp(0, DialogType.values.length - 1)],
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      links: rawLinks is List
          ? rawLinks.map((l) => NotificationLink.fromMap(Map<String, dynamic>.from(l))).toList()
          : const [],
    );
  }
}
