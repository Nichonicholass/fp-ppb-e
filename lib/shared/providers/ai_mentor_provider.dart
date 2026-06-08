import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/dummy_data/app_data.dart';
import '../../core/models/chat_session.dart';
import '../../core/services/ai_mentor_service.dart';

class AiMentorProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AiMentorService _service = AiMentorService();
  StreamSubscription<User?>? _authSub;

  String? _userId;
  final List<ChatSession> _sessions = [];
  ChatSession? _currentSession;
  bool _isLoading = false;
  String? _error;

  List<ChatSession> get sessions => List.unmodifiable(_sessions);
  ChatSession? get currentSession => _currentSession;
  List<ChatMessage> get messages =>
      List.unmodifiable(_currentSession?.messages ?? []);
  bool get isLoading => _isLoading;
  String? get error => _error;

  AiMentorProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _userId = user.uid;
        _loadSessions();
      } else {
        _userId = null;
        _reset();
      }
    });
  }

  void _reset() {
    _sessions.clear();
    _currentSession = null;
    _isLoading = false;
    _error = null;
    _service.resetSession([]);
    notifyListeners();
  }

  Future<void> _loadSessions() async {
    if (_userId == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db
          .collection('users')
          .doc(_userId)
          .collection('chat_sessions')
          .orderBy('updatedAt', descending: true)
          .get();

      _sessions.clear();
      for (final doc in snapshot.docs) {
        _sessions.add(ChatSession.fromMap(doc.id, doc.data()));
      }

      if (_sessions.isNotEmpty) {
        _currentSession = _sessions.first;
        _rebuildGroqHistory();
      }
    } catch (e) {
      debugPrint('[AiMentorProvider] load error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void startNewSession() {
    _currentSession = null;
    _service.resetSession([]);
    notifyListeners();
  }

  void switchSession(ChatSession session) {
    _currentSession = session;
    _rebuildGroqHistory();
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);
    if (_currentSession?.id == sessionId) {
      _currentSession = _sessions.isNotEmpty ? _sessions.first : null;
      if (_currentSession != null) {
        _rebuildGroqHistory();
      } else {
        _service.resetSession([]);
      }
    }
    notifyListeners();

    if (_userId == null) return;
    try {
      await _db
          .collection('users')
          .doc(_userId)
          .collection('chat_sessions')
          .doc(sessionId)
          .delete();
    } catch (e) {
      debugPrint('[AiMentorProvider] delete error: $e');
    }
  }

  Future<void> sendMessage(String text, {String? portfolioContext}) async {
    final content = text.trim();
    if (content.isEmpty) return;

    if (_currentSession == null) {
      final session = ChatSession.create();
      _sessions.insert(0, session);
      _currentSession = session;
    }

    _currentSession!.messages.add(
      ChatMessage(text: content, isUser: true, time: _nowTime()),
    );

    // Auto-title from first user message
    if (_currentSession!.messages.where((m) => m.isUser).length == 1) {
      _currentSession!.title =
          content.length > 45 ? '${content.substring(0, 45)}...' : content;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final prompt = portfolioContext != null
        ? '[Context: $portfolioContext]\n\n$content'
        : content;

    final reply = await _service.sendMessage(prompt);

    _currentSession!.messages.add(
      ChatMessage(text: reply, isUser: false, time: _nowTime()),
    );
    _currentSession!.updatedAt = DateTime.now();
    _isLoading = false;
    notifyListeners();

    await _saveCurrentSession();
  }

  void _rebuildGroqHistory() {
    final history = (_currentSession?.messages ?? [])
        .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
        .toList();
    _service.resetSession(history);
  }

  Future<void> _saveCurrentSession() async {
    if (_userId == null || _currentSession == null) return;
    try {
      await _db
          .collection('users')
          .doc(_userId)
          .collection('chat_sessions')
          .doc(_currentSession!.id)
          .set(_currentSession!.toMap());

      _sessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      notifyListeners();
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
