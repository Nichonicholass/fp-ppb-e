import 'package:cloud_firestore/cloud_firestore.dart';
import '../dummy_data/app_data.dart';

class ChatSession {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    List<ChatMessage>? messages,
  }) : messages = messages ?? [];

  factory ChatSession.create() {
    final now = DateTime.now();
    return ChatSession(
      id: '${now.millisecondsSinceEpoch}',
      title: 'New Chat',
      createdAt: now,
      updatedAt: now,
    );
  }

  factory ChatSession.fromMap(String id, Map<String, dynamic> map) {
    return ChatSession(
      id: id,
      title: map['title'] as String? ?? 'New Chat',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      messages: (map['messages'] as List<dynamic>? ?? []).map((m) {
        final msg = m as Map<String, dynamic>;
        return ChatMessage(
          text: msg['text'] as String,
          isUser: msg['isUser'] as bool,
          time: msg['time'] as String,
        );
      }).toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'messages': messages
            .map((m) => {'text': m.text, 'isUser': m.isUser, 'time': m.time})
            .toList(),
      };
}
