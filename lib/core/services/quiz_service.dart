import 'package:cloud_firestore/cloud_firestore.dart';
import '../dummy_data/quiz_data.dart';

class QuizQuestion {
  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String topic;
  final String difficulty;
  final bool active;

  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.topic,
    required this.difficulty,
    this.active = true,
  });

  factory QuizQuestion.fromFirestore(Map<String, dynamic> json, String docId) {
    return QuizQuestion(
      id: docId,
      question: json['question'] as String? ?? '',
      options: (json['options'] as List<dynamic>? ?? []).cast<String>(),
      correctIndex: json['correctIndex'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'beginner',
      active: json['active'] as bool? ?? true,
    );
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      options: (json['options'] as List<dynamic>? ?? []).cast<String>(),
      correctIndex: json['correctIndex'] as int? ?? 0,
      explanation: json['explanation'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'beginner',
      active: json['active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'options': options,
      'correctIndex': correctIndex,
      'explanation': explanation,
      'topic': topic,
      'difficulty': difficulty,
      'active': active,
    };
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

class QuizService {
  final FirebaseFirestore _db;

  QuizService({
    FirebaseFirestore? db,
  }) : _db = db ?? FirebaseFirestore.instance;

  /// Fetches all active questions from the Firestore 'questions' collection.
  Future<List<QuizQuestion>> fetchQuestions() async {
    final snapshot = await _db
        .collection('questions')
        .where('active', isEqualTo: true)
        .get();
    
    // If the database has no questions yet, return the default questions locally
    // to prevent blank screen while seeding runs or permissions propagation.
    if (snapshot.docs.isEmpty) {
      return QuizData.defaultQuestions;
    }

    return snapshot.docs
        .map((doc) => QuizQuestion.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  /// Seeds all default questions to the Firestore 'questions' collection if they don't exist.
  Future<void> seedQuestionsLocal() async {
    try {
      for (final q in QuizData.defaultQuestions) {
        final docRef = _db.collection('questions').doc(q.id);
        final doc = await docRef.get();
        if (!doc.exists) {
          await docRef.set(q.toJson());
        }
      }
    } catch (e) {
      // Quietly log and ignore, so that it doesn't block the app if rules deny writes
      print('Local seeding warning: $e');
    }
  }
}
