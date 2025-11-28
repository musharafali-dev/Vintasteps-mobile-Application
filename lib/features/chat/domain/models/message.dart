class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String body;
  final DateTime sentAt;
  final bool isRead;

  const Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.body,
    required this.sentAt,
    this.isRead = false,
  });

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      conversationId:
          map['conversationId'] as String? ?? map['conversation_id'] as String,
      senderId: map['senderId'] as String? ?? map['sender_id'] as String,
      body: map['body'] as String,
      sentAt:
          DateTime.parse(map['sentAt'] as String? ?? map['sent_at'] as String),
      isRead: map['isRead'] as bool? ?? map['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'conversationId': conversationId,
        'senderId': senderId,
        'body': body,
        'sentAt': sentAt.toIso8601String(),
        'isRead': isRead,
      };

  Message copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? body,
    DateTime? sentAt,
    bool? isRead,
  }) {
    return Message(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      body: body ?? this.body,
      sentAt: sentAt ?? this.sentAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
