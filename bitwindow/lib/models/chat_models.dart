// dart format off
enum ChatRelationshipState { none, outgoingIntroduction, incomingIntroduction, acceptancePending, accepted, rejected, blocked }
enum ChatMessageKind { introduction, acceptance, message }
enum ChatDeliveryState { pending, delivered, confirmed, failed }
enum ChatTransport { bitnamesChain, direct, tor }

class StatusMessage {
  final String id; final String message;

  StatusMessage({required this.id, required this.message});
}

class ChatMessage {
  final String id;
  final String content;
  final String senderBitname;
  final String recipientBitname;
  final DateTime timestamp;
  final bool isOutgoing;
  final ChatMessageKind kind; final ChatDeliveryState deliveryState; final ChatTransport transport;
  final String? introductionId;
  final String? txid;
  final int? valueSats;
  final String? error;
  String get localBitname => isOutgoing ? senderBitname : recipientBitname;

  ChatMessage({
    required this.id,
    required this.content,
    required this.senderBitname,
    required this.recipientBitname,
    required this.timestamp,
    required this.isOutgoing,
    this.kind = ChatMessageKind.message, this.deliveryState = ChatDeliveryState.pending,
    this.transport = ChatTransport.bitnamesChain, this.introductionId,
    this.txid,
    this.valueSats,
    this.error,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'] ?? '',
    content: json['content'] ?? '',
    senderBitname: json['sender_bitname'] ?? json['sender_pubkey'] ?? '',
    recipientBitname: json['recipient_bitname'] ?? json['recipient_pubkey'] ?? '',
    timestamp: json['timestamp'] != null ? DateTime.fromMillisecondsSinceEpoch(json['timestamp']) : DateTime.now(),
    isOutgoing: json['is_outgoing'] ?? false,
    kind: _enum(ChatMessageKind.values, json['kind'], ChatMessageKind.message),
    deliveryState: _enum(ChatDeliveryState.values, json['delivery_state'], ChatDeliveryState.confirmed),
    transport: _enum(ChatTransport.values, json['transport'], ChatTransport.bitnamesChain),
    introductionId: json['introduction_id'], error: json['error'],
    txid: json['txid'],
    valueSats: json['value_sats'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'sender_bitname': senderBitname,
    'recipient_bitname': recipientBitname,
    'timestamp': timestamp.millisecondsSinceEpoch,
    'is_outgoing': isOutgoing,
    'kind': kind.name, 'delivery_state': deliveryState.name, 'transport': transport.name,
    if (introductionId != null) 'introduction_id': introductionId,
    if (txid != null) 'txid': txid,
    if (valueSats != null) 'value_sats': valueSats,
    if (error != null) 'error': error,
  };

  ChatMessage copyWith({
    String? id,
    String? content,
    String? senderBitname,
    String? recipientBitname,
    DateTime? timestamp,
    bool? isOutgoing,
    ChatMessageKind? kind, ChatDeliveryState? deliveryState, ChatTransport? transport,
    String? introductionId, String? error,
    String? txid,
    int? valueSats,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      senderBitname: senderBitname ?? this.senderBitname,
      recipientBitname: recipientBitname ?? this.recipientBitname,
      timestamp: timestamp ?? this.timestamp,
      isOutgoing: isOutgoing ?? this.isOutgoing,
      kind: kind ?? this.kind, deliveryState: deliveryState ?? this.deliveryState,
      transport: transport ?? this.transport, introductionId: introductionId ?? this.introductionId,
      txid: txid ?? this.txid,
      valueSats: valueSats ?? this.valueSats,
      error: error ?? this.error,
    );
  }
}

class ChatContact {
  final String id;
  final String localBitname;
  final String name;
  final String? plaintextName;
  final String encryptionPubkey;
  final String? signingPubkey; final String? address;
  final int? paymailFeeSats;
  final ChatRelationshipState relationshipState; final String? introductionId;
  final Map<String, dynamic>? replyProfile;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final bool isManual;

  ChatContact({
    required this.id,
    this.localBitname = '',
    required this.name,
    this.plaintextName,
    required this.encryptionPubkey,
    this.signingPubkey, this.address,
    this.paymailFeeSats,
    this.relationshipState = ChatRelationshipState.none, this.introductionId, this.replyProfile,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.isManual = false,
  });

  String get displayName => plaintextName ?? (name == id && id.length > 8 ? 'BitName ${id.substring(0, 8)}…' : name);
  String get relationshipId => '$localBitname:$id';
  bool get isAccepted => relationshipState == ChatRelationshipState.accepted;

  factory ChatContact.fromJson(Map<String, dynamic> json) => ChatContact(
    id: json['id'] ?? '',
    localBitname: json['local_bitname'] ?? '',
    name: json['name'] ?? '',
    plaintextName: json['plaintext_name'],
    encryptionPubkey: json['encryption_pubkey'] ?? '',
    signingPubkey: json['signing_pubkey'], address: json['address'],
    paymailFeeSats: json['paymail_fee_sats'],
    relationshipState: _enum(ChatRelationshipState.values, json['relationship_state'], ChatRelationshipState.none),
    introductionId: json['introduction_id'],
    replyProfile: json['reply_profile'] is Map ? Map<String, dynamic>.from(json['reply_profile']) : null,
    lastMessage: json['last_message'],
    lastMessageTime: json['last_message_time'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['last_message_time'])
        : null,
    unreadCount: json['unread_count'] ?? 0,
    isManual: json['is_manual'] ?? false,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'local_bitname': localBitname,
    'name': name,
    if (plaintextName != null) 'plaintext_name': plaintextName,
    'encryption_pubkey': encryptionPubkey,
    if (signingPubkey != null) 'signing_pubkey': signingPubkey,
    if (address != null) 'address': address,
    if (paymailFeeSats != null) 'paymail_fee_sats': paymailFeeSats,
    'relationship_state': relationshipState.name,
    if (introductionId != null) 'introduction_id': introductionId,
    if (replyProfile != null) 'reply_profile': replyProfile,
    if (lastMessage != null) 'last_message': lastMessage,
    if (lastMessageTime != null) 'last_message_time': lastMessageTime!.millisecondsSinceEpoch,
    'unread_count': unreadCount,
    'is_manual': isManual,
  };

  ChatContact copyWith({
    String? id,
    String? localBitname,
    String? name,
    String? plaintextName,
    String? encryptionPubkey,
    String? signingPubkey, String? address,
    int? paymailFeeSats,
    ChatRelationshipState? relationshipState, String? introductionId,
    Map<String, dynamic>? replyProfile,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? isManual,
  }) {
    return ChatContact(
      id: id ?? this.id,
      localBitname: localBitname ?? this.localBitname,
      name: name ?? this.name,
      plaintextName: plaintextName ?? this.plaintextName,
      encryptionPubkey: encryptionPubkey ?? this.encryptionPubkey,
      signingPubkey: signingPubkey ?? this.signingPubkey, address: address ?? this.address,
      paymailFeeSats: paymailFeeSats ?? this.paymailFeeSats,
      relationshipState: relationshipState ?? this.relationshipState,
      introductionId: introductionId ?? this.introductionId, replyProfile: replyProfile ?? this.replyProfile,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      isManual: isManual ?? this.isManual,
    );
  }
}

T _enum<T extends Enum>(List<T> values, Object? name, T fallback) =>
    values.firstWhere((value) => value.name == name, orElse: () => fallback);
// dart format on
