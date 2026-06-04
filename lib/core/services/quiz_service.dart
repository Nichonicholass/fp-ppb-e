import 'dart:convert';

import 'package:http/http.dart' as http;

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      question: json['question'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
    );
  }
}

class QuizSession {
  final String sessionId;
  final List<QuizQuestion> questions;

  const QuizSession({
    required this.sessionId,
    required this.questions,
  });

  factory QuizSession.fromJson(Map<String, dynamic> json) {
    return QuizSession(
      sessionId: json['sessionId'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QuizAnswerResult {
  final bool correct;
  final int correctIndex;
  final String explanation;

  const QuizAnswerResult({
    required this.correct,
    required this.correctIndex,
    required this.explanation,
  });

  factory QuizAnswerResult.fromJson(Map<String, dynamic> json) {
    return QuizAnswerResult(
      correct: json['correct'] as bool,
      correctIndex: json['correctIndex'] as int,
      explanation: json['explanation'] as String,
    );
  }
}

class QuizApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;

  const QuizApiException({
    required this.statusCode,
    required this.code,
    required this.message,
  });

  @override
  String toString() => message;
}

class QuizService {
  static final Uri defaultBaseUrl =
      Uri.parse('https://fintell-quiz-backend.vercel.app');

  final http.Client _client;
  final Uri _baseUrl;

  QuizService({
    http.Client? client,
    Uri? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? defaultBaseUrl;

  Future<QuizSession> createSession({
    String difficulty = 'beginner',
    int limit = 5,
  }) async {
    final response = await _client
        .post(
          _buildUri('/api/quiz/session'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'difficulty': difficulty,
            'limit': limit,
          }),
        )
        .timeout(const Duration(seconds: 15));

    return QuizSession.fromJson(_decodeResponse(response));
  }

  Future<QuizAnswerResult> answerQuestion({
    required String sessionId,
    required String questionId,
    required int selectedIndex,
  }) async {
    final response = await _client
        .post(
          _buildUri('/api/quiz/answer'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'sessionId': sessionId,
            'questionId': questionId,
            'selectedIndex': selectedIndex,
          }),
        )
        .timeout(const Duration(seconds: 15));

    return QuizAnswerResult.fromJson(_decodeResponse(response));
  }

  Uri _buildUri(String path) {
    return _baseUrl.replace(path: path, queryParameters: null);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final decoded = _decodeBody(response.body);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final error = decoded['error'] as Map<String, dynamic>?;
      throw QuizApiException(
        statusCode: response.statusCode,
        code: error?['code'] as String? ?? 'server_error',
        message: error?['message'] as String? ?? 'Quiz request failed.',
      );
    }

    return decoded;
  }

  Map<String, dynamic> _decodeBody(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      // Fall through to a consistent API exception.
    }

    throw const QuizApiException(
      statusCode: 500,
      code: 'invalid_response',
      message: 'Quiz server returned an invalid response.',
    );
  }
}
