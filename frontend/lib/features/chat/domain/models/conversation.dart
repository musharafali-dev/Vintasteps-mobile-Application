import 'message.dart';

class Conversation {
  final String id;
  final List<String> participantIds;
  final Message? lastMessage;
  final int unreadCount;
  final String? title;

  const Conversation({
    required this.id,
    required this.participantIds,
    this.lastMessage,
    this.unreadCount = 0,
    this.title,
  });

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id'] as String,
      participantIds: (map['participantIds'] as List<dynamic>? ??
              map['participant_ids'] as List<dynamic>? ??
              [])
          .map((p) => p.toString())
          .toList(),
      lastMessage: map['lastMessage'] != null
          ? Message.fromMap(map['lastMessage'] as Map<String, dynamic>)
          : null,
      unreadCount:
          map['unreadCount'] as int? ?? map['unread_count'] as int? ?? 0,
      title: map['title'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'participantIds': participantIds,
        'lastMessage': lastMessage?.toMap(),
        'unreadCount': unreadCount,
        if (title != null) 'title': title,
      };
}
