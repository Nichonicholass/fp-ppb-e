import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/dummy_data/app_data.dart';
import '../../core/services/ai_mentor_service.dart';

class AiMentorProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AiMentorService _service = AiMentorService();
  StreamSubscription<User?>? _authSub;

  String? _userId;
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;

  AiMentorProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _userId = user.uid;
        _loadFromFirestore();
      } else {
        _userId = null;
        _reset();
      }
    });
  }

  void _reset() {
    _messages.clear();
    _isLoading = false;
    _error = null;
    _service.resetSession([]);
    notifyListeners();
  }

  Future<void> _loadFromFirestore() async {
    if (_userId == null) return;

    try {
      final doc = await _db
          .collection('users')
          .doc(_userId)
          .collection('ai_chat')
          .doc('history')
          .get();

      if (doc.exists) {
        final raw = doc.data()?['messages'] as List<dynamic>? ?? [];
        _messages.clear();
        for (final m in raw) {
          final map = m as Map<String, dynamic>;
          _messages.add(ChatMessage(
            text: map['text'] as String,
            isUser: map['isUser'] as bool,
            time: map['time'] as String,
          ));
        }

        // Rebuild Groq session history from stored messages
        final chatHistory = _messages
            .map((m) => {
                  'role': m.isUser ? 'user' : 'assistant',
                  'content': m.text,
                })
            .toList();
        _service.resetSession(chatHistory);
      }
    } catch (e) {
      debugPrint('[AiMentorProvider] load error: $e');
    }

    notifyListeners();
  }

  Future<void> sendMessage(String text, {String? portfolioContext}) async {
    final content = text.trim();
    if (content.isEmpty) return;

    final time = _nowTime();
    _messages.add(ChatMessage(text: content, isUser: true, time: time));
    _isLoading = true;
    _error = null;
    notifyListeners();

    final prompt = portfolioContext != null
        ? '[Context: $portfolioContext]\n\n$content'
        : content;

    final reply = await _service.sendMessage(prompt);

    _messages.add(ChatMessage(text: reply, isUser: false, time: _nowTime()));
    _isLoading = false;
    notifyListeners();

    await _saveToFirestore();
  }

  Future<void> clearHistory() async {
    _messages.clear();
    _service.resetSession([]);
    notifyListeners();

    if (_userId == null) return;
    try {
      await _db
          .collection('users')
          .doc(_userId)
          .collection('ai_chat')
          .doc('history')
          .delete();
    } catch (e) {
      debugPrint('[AiMentorProvider] clear error: $e');
    }
  }

  Future<void> _saveToFirestore() async {
    if (_userId == null) return;
    try {
      await _db
          .collection('users')
          .doc(_userId)
          .collection('ai_chat')
          .doc('history')
          .set({
        'messages': _messages
            .map((m) => {'text': m.text, 'isUser': m.isUser, 'time': m.time})
            .toList(),
      });
    } catch (e) {
      debugPrint('[AiMentorProvider] save error: $e');
    }
  }

  String _nowTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
