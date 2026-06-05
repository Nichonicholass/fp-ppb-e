class QuizModule {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final List<int> gradientColorsValues;
  final String lessonText;
  final List<String> keyTakeaways;
  final int sortOrder;

  const QuizModule({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.gradientColorsValues,
    required this.lessonText,
    required this.keyTakeaways,
    this.sortOrder = 0,
  });

  factory QuizModule.fromFirestore(Map<String, dynamic> json, String docId) {
    return QuizModule(
      id: docId,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconName: json['iconName'] as String? ?? 'help',
      gradientColorsValues: (json['gradientColorsValues'] as List<dynamic>? ?? [])
          .map((c) => (c as num).toInt())
          .toList(),
      lessonText: json['lessonText'] as String? ?? '',
      keyTakeaways: (json['keyTakeaways'] as List<dynamic>? ?? []).cast<String>(),
      sortOrder: (json['sortOrder'] as num? ?? 0).toInt(),
    );
  }

  factory QuizModule.fromJson(Map<String, dynamic> json) {
    return QuizModule(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconName: json['iconName'] as String? ?? 'help',
      gradientColorsValues: (json['gradientColorsValues'] as List<dynamic>? ?? [])
          .map((c) => (c as num).toInt())
          .toList(),
      lessonText: json['lessonText'] as String? ?? '',
      keyTakeaways: (json['keyTakeaways'] as List<dynamic>? ?? []).cast<String>(),
      sortOrder: (json['sortOrder'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'gradientColorsValues': gradientColorsValues,
      'lessonText': lessonText,
      'keyTakeaways': keyTakeaways,
      'sortOrder': sortOrder,
    };
  }
}

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
