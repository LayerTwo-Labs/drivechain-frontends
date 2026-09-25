enum DialogType { info, error, success }

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

/// How a notification is presented: a transient toast, a strip pinned at the
/// top of the app until the user interacts with it, or a modal that opens one
/// time and leaves that strip behind.
enum NotificationStyle { toast, banner, modalThenBanner }

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

  /// What the action works on, such as the networks a switch names. The text
  /// the user reads and the work the action does come from one place.
  final Map<String, String> data;

  final bool read;

  /// True once the modal of a [NotificationStyle.modalThenBanner] item opened.
  /// It opens one time, and the banner carries the message after that.
  final bool modalShown;

  /// True for a style that pins a strip at the top of the app.
  bool get pinned => style == NotificationStyle.banner || style == NotificationStyle.modalThenBanner;

  NotificationItem({
    required this.id,
    required this.title,
    required this.content,
    required this.dialogType,
    required this.timestamp,
    this.links = const [],
    this.style = NotificationStyle.toast,
    this.action = '',
    this.data = const {},
    this.read = false,
    this.modalShown = false,
  });

  NotificationItem copyWith({bool? read, bool? modalShown}) => NotificationItem(
    id: id,
    title: title,
    content: content,
    dialogType: dialogType,
    timestamp: timestamp,
    links: links,
    style: style,
    action: action,
    data: data,
    read: read ?? this.read,
    modalShown: modalShown ?? this.modalShown,
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
    'data': data,
    'read': read,
    'modalShown': modalShown,
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
      data: map['data'] is Map ? Map<String, String>.from(map['data'] as Map) : const {},
      read: map['read'] ?? false,
      modalShown: map['modalShown'] ?? false,
    );
  }
}
