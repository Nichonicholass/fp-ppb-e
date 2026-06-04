import 'package:flutter/material.dart';

import '../../core/services/quiz_service.dart';

class QuizProvider extends ChangeNotifier {
  static const String defaultDifficulty = 'beginner';
  static const int defaultLimit = 5;
  static const double rewardPerCorrectAnswer = 100;

  final QuizService _service;

  bool _loading = false;
  bool _submitting = false;
  bool _claimingReward = false;
  bool _rewardClaimed = false;
  bool _rewardAlreadyClaimed = false;
  String? _error;
  String? _sessionId;
  int _currentIndex = 0;
  int _score = 0;
  final List<QuizQuestion> _questions = [];
  final Map<String, int> _selectedAnswers = {};
  final Map<String, QuizAnswerResult> _answerResults = {};

  QuizProvider({QuizService? service}) : _service = service ?? QuizService();

  bool get loading => _loading;
  bool get submitting => _submitting;
  bool get claimingReward => _claimingReward;
  bool get rewardClaimed => _rewardClaimed;
  bool get rewardAlreadyClaimed => _rewardAlreadyClaimed;
  String? get error => _error;
  String? get sessionId => _sessionId;
  int get currentIndex => _currentIndex;
  int get score => _score;
  int get totalQuestions => _questions.length;
  List<QuizQuestion> get questions => List.unmodifiable(_questions);
  bool get hasSession => _sessionId != null && _questions.isNotEmpty;
  bool get isFinished => hasSession && _currentIndex >= _questions.length;
  double get rewardAmount => _score * rewardPerCorrectAnswer;
  bool get canClaimReward =>
      isFinished &&
      rewardAmount > 0 &&
      !_rewardClaimed &&
      !_rewardAlreadyClaimed &&
      !_claimingReward;

  QuizQuestion? get currentQuestion {
    if (!hasSession) return null;
    final index = isFinished ? _questions.length - 1 : _currentIndex;
    return _questions[index];
  }

  int? get selectedIndex {
    final question = currentQuestion;
    if (question == null) return null;
    return _selectedAnswers[question.id];
  }

  QuizAnswerResult? get currentAnswerResult {
    final question = currentQuestion;
    if (question == null) return null;
    return _answerResults[question.id];
  }

  bool get hasAnsweredCurrent => currentAnswerResult != null;

  Future<void> startQuiz({
    String difficulty = defaultDifficulty,
    int limit = defaultLimit,
  }) async {
    _loading = true;
    _error = null;
    _resetSessionState();
    notifyListeners();

    try {
      final session = await _service.createSession(
        difficulty: difficulty,
        limit: limit,
      );
      _sessionId = session.sessionId;
      _questions
        ..clear()
        ..addAll(session.questions);
    } catch (e) {
      _error = _messageFromError(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> submitAnswer(int selectedIndex) async {
    final question = currentQuestion;
    final session = _sessionId;
    if (question == null || session == null || hasAnsweredCurrent) return;

    _submitting = true;
    _error = null;
    _selectedAnswers[question.id] = selectedIndex;
    notifyListeners();

    try {
      final result = await _service.answerQuestion(
        sessionId: session,
        questionId: question.id,
        selectedIndex: selectedIndex,
      );
      _answerResults[question.id] = result;
      if (result.correct) _score++;
    } catch (e) {
      _selectedAnswers.remove(question.id);
      _error = _messageFromError(e);
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  void nextQuestion() {
    if (!hasSession || !hasAnsweredCurrent) return;
    if (_currentIndex < _questions.length) {
      _currentIndex++;
      _error = null;
      notifyListeners();
    }
  }

  Future<void> claimReward(Future<bool> Function() claim) async {
    if (!canClaimReward) return;

    _claimingReward = true;
    _error = null;
    notifyListeners();

    try {
      final claimed = await claim();
      if (claimed) {
        _rewardClaimed = true;
      } else {
        _rewardAlreadyClaimed = true;
      }
    } catch (e) {
      _error = _messageFromError(e);
    } finally {
      _claimingReward = false;
      notifyListeners();
    }
  }

  void resetQuiz() {
    _error = null;
    _resetSessionState();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _resetSessionState() {
    _sessionId = null;
    _currentIndex = 0;
    _score = 0;
    _rewardClaimed = false;
    _rewardAlreadyClaimed = false;
    _questions.clear();
    _selectedAnswers.clear();
    _answerResults.clear();
  }

  String _messageFromError(Object error) {
    if (error is QuizApiException) return error.message;
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    if (message.isNotEmpty) return message;
    return 'Unable to load quiz. Please try again.';
  }
}
