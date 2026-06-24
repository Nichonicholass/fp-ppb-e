import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fintell/core/services/quiz_service.dart';
import 'package:fintell/core/models/quiz_models.dart';

class QuizProvider extends ChangeNotifier {
  static const String defaultDifficulty = 'beginner';
  static const int defaultLimit = 5;
  static const double rewardPerCorrectAnswer = 100;
  static const Duration answerRevealDelay = Duration(milliseconds: 300);

  final QuizService _service;

  bool _loading = false;
  bool _loadingModules = false;
  bool _submitting = false;
  bool _claimingReward = false;
  bool _rewardClaimed = false;
  bool _rewardAlreadyClaimed = false;
  String? _error;
  String? _sessionId;
  int _currentIndex = 0;
  int _score = 0;
  final List<QuizQuestion> _questions = [];
  final List<QuizModule> _modules = [];
  final Map<String, int> _selectedAnswers = {};
  final Map<String, QuizAnswerResult> _answerResults = {};

  QuizProvider({QuizService? service}) : _service = service ?? QuizService();

  bool get loading => _loading;
  bool get loadingModules => _loadingModules;
  bool get submitting => _submitting;
  bool get claimingReward => _claimingReward;
  bool get rewardClaimed => _rewardClaimed;
  bool get rewardAlreadyClaimed => _rewardAlreadyClaimed;
  String? get error => _error;
  String? get sessionId => _sessionId; // Holds the topic / module name
  List<QuizModule> get modules => List.unmodifiable(_modules);

  Future<void> loadModules() async {
    _loadingModules = true;
    _error = null;
    notifyListeners();

    try {
      final fetched = await _service.fetchModules();
      _modules
        ..clear()
        ..addAll(fetched);
    } catch (e) {
      _error = _messageFromError(e);
    } finally {
      _loadingModules = false;
      notifyListeners();
    }
  }
  int get currentIndex => _currentIndex;
  int get score => _score;
  int get totalQuestions => _questions.length;
  List<QuizQuestion> get questions => List.unmodifiable(_questions);
  bool get hasSession => _sessionId != null && _questions.isNotEmpty;
  bool get isFinished => hasSession && _currentIndex >= _questions.length;
  double get rewardAmount => rewardForScore(_score);
  double get maxRewardAmount => rewardForScore(totalQuestions);
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
    String? topic,
    bool alreadyClaimed = false,
  }) async {
    _loading = true;
    _error = null;
    _resetSessionState();
    _rewardAlreadyClaimed = alreadyClaimed;
    notifyListeners();

    try {
      final random = Random();
      final allQuestions = await _service.fetchQuestions();
      final selectedDifficulty = difficulty.trim();
      final filtered = allQuestions.where((q) {
        final topicMatches = topic == null || q.topic == topic;
        final difficultyMatches =
            selectedDifficulty.isEmpty || q.difficulty == selectedDifficulty;
        return q.isValid && topicMatches && difficultyMatches;
      }).toList()
        ..shuffle(random);

      final quizQs = limit > 0 && limit < filtered.length
          ? filtered.sublist(0, limit)
          : filtered;

      if (quizQs.isEmpty) {
        throw Exception('No quiz questions available for this module yet.');
      }

      _sessionId = topic ?? 'general';
      _questions
        ..clear()
        ..addAll(
          quizQs.map((question) => _shuffleQuestionOptions(question, random)),
        );
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
    if (question == null ||
        session == null ||
        hasAnsweredCurrent ||
        selectedIndex < 0 ||
        selectedIndex >= question.options.length) {
      return;
    }

    _submitting = true;
    _error = null;
    _selectedAnswers[question.id] = selectedIndex;
    notifyListeners();

    await Future.delayed(answerRevealDelay);

    try {
      if (_sessionId != session || currentQuestion?.id != question.id) return;

      final result = _gradeAnswer(question, selectedIndex);
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

  static double rewardForScore(int score) => score * rewardPerCorrectAnswer;

  QuizAnswerResult _gradeAnswer(QuizQuestion question, int selectedIndex) {
    final isCorrect = selectedIndex == question.correctIndex;
    return QuizAnswerResult(
      correct: isCorrect,
      correctIndex: question.correctIndex,
      correctAnswerLabel: question.correctAnswerLabel,
      explanation: question.explanation,
    );
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
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    if (message.isNotEmpty) return message;
    return 'Unable to load quiz. Please try again.';
  }

  QuizQuestion _shuffleQuestionOptions(QuizQuestion question, Random random) {
    final indexedOptions = question.options
        .asMap()
        .entries
        .map((entry) => MapEntry(entry.key, entry.value))
        .toList()
      ..shuffle(random);
    final shuffledOptions = indexedOptions.map((entry) => entry.value).toList();
    final shuffledCorrectIndex = indexedOptions.indexWhere(
      (entry) => entry.key == question.correctIndex,
    );

    return QuizQuestion(
      id: question.id,
      question: question.question,
      options: shuffledOptions,
      correctIndex: shuffledCorrectIndex,
      explanation: question.explanation,
      topic: question.topic,
      difficulty: question.difficulty,
      active: question.active,
    );
  }
}
