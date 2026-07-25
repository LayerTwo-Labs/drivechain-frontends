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

/// How a notification is presented: a transient toast, or a strip pinned at the
/// top of the app until the user interacts with it.
enum NotificationStyle { toast, banner }

/// A persisted notification shown in the bell history list.
class NotificationItem {
  final String id;
  final String title;
  final String content;
  final DialogType dialogType;
  final DateTime timestamp;
  final List<NotificationLink> links;
  final NotificationStyle style;

  /// Key of an in-app action to run when tapped, empty for none. A key rather
  /// than a callback because history is persisted as JSON.
  final String action;

  final bool read;

  NotificationItem({
    required this.id,
    required this.title,
    required this.content,
    required this.dialogType,
    required this.timestamp,
    this.links = const [],
    this.style = NotificationStyle.toast,
    this.action = '',
    this.read = false,
  });

  NotificationItem copyWith({bool? read}) => NotificationItem(
    id: id,
    title: title,
    content: content,
    dialogType: dialogType,
    timestamp: timestamp,
    links: links,
    style: style,
    action: action,
    read: read ?? this.read,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
    'dialogType': dialogType.index,
    'timestamp': timestamp.toIso8601String(),
    'links': links.map((l) => l.toMap()).toList(),
    'style': style.index,
    'action': action,
    'read': read,
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
      style: NotificationStyle.values[(map['style'] ?? 0).clamp(0, NotificationStyle.values.length - 1)],
      action: map['action'] ?? '',
      read: map['read'] ?? false,
    );
  }
}
