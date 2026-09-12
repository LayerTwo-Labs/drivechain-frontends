class StatusMessage {
  final String id;
  final String message;

  StatusMessage({required this.id, required this.message});
}

class ChatMessage {
  final String id;
  final String content;
  final String senderPubkey;
  final String recipientPubkey;
  final String? senderBitname;
  final String? recipientBitname;
  final DateTime timestamp;
  final bool isOutgoing;
  final String? txid;
  final int? valueSats;

  /// True while the message waits in the mempool. A block clears it.
  final bool isPending;

  /// True once the reader opens the conversation. It follows the same shape as
  /// a NotificationItem, which the bell history already stores this way.
  final bool read;

  ChatMessage({
    required this.id,
    required this.content,
    required this.senderPubkey,
    required this.recipientPubkey,
    this.senderBitname,
    this.recipientBitname,
    required this.timestamp,
    required this.isOutgoing,
    this.txid,
    this.valueSats,
    this.isPending = false,
    this.read = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] ?? '',
    content: json['content'] ?? '',
    senderPubkey: json['sender_pubkey'] ?? '',
    recipientPubkey: json['recipient_pubkey'] ?? '',
    senderBitname: json['sender_bitname'],
    recipientBitname: json['recipient_bitname'],
    timestamp: json['timestamp'] != null ? DateTime.fromMillisecondsSinceEpoch(json['timestamp']) : DateTime.now(),
    isOutgoing: json['is_outgoing'] ?? false,
    txid: json['txid'],
    valueSats: json['value_sats'],
    isPending: json['is_pending'] ?? false,
    read: json['read'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'sender_pubkey': senderPubkey,
    'recipient_pubkey': recipientPubkey,
    'sender_bitname': senderBitname,
    'recipient_bitname': recipientBitname,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'is_outgoing': isOutgoing,
    'txid': txid,
    'value_sats': valueSats,
    'is_pending': isPending,
    'read': read,
  };

  ChatMessage copyWith({
    String? id,
    String? content,
    String? senderPubkey,
    String? recipientPubkey,
    String? senderBitname,
    String? recipientBitname,
    DateTime? timestamp,
    bool? isOutgoing,
    String? txid,
    int? valueSats,
    bool? isPending,
    bool? read,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      senderPubkey: senderPubkey ?? this.senderPubkey,
      recipientPubkey: recipientPubkey ?? this.recipientPubkey,
      senderBitname: senderBitname ?? this.senderBitname,
      recipientBitname: recipientBitname ?? this.recipientBitname,
      timestamp: timestamp ?? this.timestamp,
      isOutgoing: isOutgoing ?? this.isOutgoing,
      txid: txid ?? this.txid,
      valueSats: valueSats ?? this.valueSats,
      isPending: isPending ?? this.isPending,
      read: read ?? this.read,
    );
  }
}

class ChatContact {
  final String id;
  final String name;
  final String? plaintextName;
  final String encryptionPubkey;
  final String address;
  final int? paymailFeeSats;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final bool isManual;

  ChatContact({
    required this.id,
    required this.name,
    this.plaintextName,
    required this.encryptionPubkey,
    required this.address,
    this.paymailFeeSats,
    this.lastMessage,
    this.lastMessageTime,
    this.isManual = false,
  });

  String get displayName => plaintextName ?? name;

  factory ChatContact.fromJson(Map<String, dynamic> json) => ChatContact(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    plaintextName: json['plaintext_name'],
    encryptionPubkey: json['encryption_pubkey'] ?? '',
    address: json['address'] ?? '',
    paymailFeeSats: json['paymail_fee_sats'],
    lastMessage: json['last_message'],
    lastMessageTime: json['last_message_time'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['last_message_time'])
        : null,
    isManual: json['is_manual'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'plaintext_name': plaintextName,
    'encryption_pubkey': encryptionPubkey,
    'address': address,
    'paymail_fee_sats': paymailFeeSats,
    'last_message': lastMessage,
    'last_message_time': lastMessageTime?.millisecondsSinceEpoch,
    'is_manual': isManual,
  };

  ChatContact copyWith({
    String? id,
    String? name,
    String? plaintextName,
    String? encryptionPubkey,
    String? address,
    int? paymailFeeSats,
    String? lastMessage,
    DateTime? lastMessageTime,
    bool clearPreview = false,
    bool? isManual,
  }) {
    return ChatContact(
      id: id ?? this.id,
      name: name ?? this.name,
      plaintextName: plaintextName ?? this.plaintextName,
      encryptionPubkey: encryptionPubkey ?? this.encryptionPubkey,
      address: address ?? this.address,
      paymailFeeSats: paymailFeeSats ?? this.paymailFeeSats,
      lastMessage: clearPreview ? null : lastMessage ?? this.lastMessage,
      lastMessageTime: clearPreview ? null : lastMessageTime ?? this.lastMessageTime,
      isManual: isManual ?? this.isManual,
    );
  }
}
