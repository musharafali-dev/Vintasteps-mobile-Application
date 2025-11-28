import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/models/conversation.dart';
import '../domain/models/message.dart';

/// A mocked chat repository that simulates a real-time data source.
/// Replace this implementation with a WebSocket or Firebase service when ready.
class ChatRepository {
  ChatRepository() {
    _seedMockData();
  }

  final Map<String, List<String>> _participantMap = {};
  final Map<String, List<Message>> _messagesByConversation = {};
  final Map<String, StreamController<List<Message>>> _controllers = {};

  void _seedMockData() {
    final now = DateTime.now();

    _participantMap['conv-1'] = ['user-1', 'user-2'];
    _participantMap['conv-2'] = ['user-1', 'user-3'];

    _messagesByConversation['conv-1'] = [
      Message(
        id: 'msg-1',
        conversationId: 'conv-1',
        senderId: 'user-2',
        body: 'Hey! Is the vintage jacket still available?',
        sentAt: now.subtract(const Duration(minutes: 25)),
        isRead: false,
      ),
      Message(
        id: 'msg-2',
        conversationId: 'conv-1',
        senderId: 'user-1',
        body: 'Yes, it is. I can ship tomorrow.',
        sentAt: now.subtract(const Duration(minutes: 20)),
        isRead: true,
      ),
    ];

    _messagesByConversation['conv-2'] = [
      Message(
        id: 'msg-3',
        conversationId: 'conv-2',
        senderId: 'user-3',
        body: 'Payment sent. Can you confirm?',
        sentAt: now.subtract(const Duration(hours: 2)),
        isRead: false,
      ),
    ];
  }

  Future<List<Conversation>> fetchConversations(String currentUserId) async {
    await Future.delayed(const Duration(milliseconds: 350));

    return _messagesByConversation.entries.map((entry) {
      final conversationId = entry.key;
      final messages = entry.value;
      final participants = _participantMap[conversationId] ?? const [];
      final unread = messages
          .where((msg) => msg.senderId != currentUserId && !msg.isRead)
          .length;

      return Conversation(
        id: conversationId,
        participantIds: participants,
        lastMessage: messages.isNotEmpty ? messages.last : null,
        unreadCount: unread,
        title: _buildConversationTitle(currentUserId, participants),
      );
    }).toList();
  }

  Stream<List<Message>> watchConversation(String conversationId) {
    final controller = _controllers.putIfAbsent(conversationId, () {
      final ctrl = StreamController<List<Message>>.broadcast();
      final initial = _messagesByConversation[conversationId] ?? [];
      ctrl.add(List.unmodifiable(initial));
      return ctrl;
    });

    // Ensure subscribers always receive the latest snapshot.
    Future.microtask(() {
      final current = _messagesByConversation[conversationId] ?? [];
      controller.add(List.unmodifiable(current));
    });

    return controller.stream;
  }

  Future<Message> sendMessage({
    required String conversationId,
    required String senderId,
    required String body,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));

    final message = Message(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      senderId: senderId,
      body: body,
      sentAt: DateTime.now(),
      isRead: false,
    );

    final messages =
        _messagesByConversation.putIfAbsent(conversationId, () => []);
    messages.add(message);

    _controllers[conversationId]?.add(List.unmodifiable(messages));
    return message;
  }

  String _buildConversationTitle(
      String currentUserId, List<String> participants) {
    final others = participants.where((id) => id != currentUserId).toList();
    if (others.isEmpty) {
      return 'Conversation';
    }
    if (others.length == 1) {
      return 'Chat with ${others.first}';
    }
    return 'Group (${others.join(', ')})';
  }

  void dispose() {
    for (final controller in _controllers.values) {
      controller.close();
    }
  }
}

final chatRepositoryProvider = Provider.autoDispose<ChatRepository>((ref) {
  final repo = ChatRepository();
  ref.onDispose(repo.dispose);
  return repo;
});
