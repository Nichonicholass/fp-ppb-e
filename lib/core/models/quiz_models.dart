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
      title: _stringValue(json['title']),
      description: _stringValue(json['description']),
      iconName: _stringValue(json['iconName'], fallback: 'help'),
      gradientColorsValues: _intList(json['gradientColorsValues']),
      lessonText: _stringValue(json['lessonText']),
      keyTakeaways: _stringList(json['keyTakeaways']),
      sortOrder: _intValue(json['sortOrder']),
    );
  }

  factory QuizModule.fromJson(Map<String, dynamic> json) {
    return QuizModule(
      id: _stringValue(json['id']),
      title: _stringValue(json['title']),
      description: _stringValue(json['description']),
      iconName: _stringValue(json['iconName'], fallback: 'help'),
      gradientColorsValues: _intList(json['gradientColorsValues']),
      lessonText: _stringValue(json['lessonText']),
      keyTakeaways: _stringList(json['keyTakeaways']),
      sortOrder: _intValue(json['sortOrder']),
    );
  }

  bool get isValid =>
      id.trim().isNotEmpty &&
      title.trim().isNotEmpty &&
      description.trim().isNotEmpty &&
      lessonText.trim().isNotEmpty;

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
      question: _stringValue(json['question']),
      options: _stringList(json['options']),
      correctIndex: _intValue(json['correctIndex']),
      explanation: _stringValue(json['explanation']),
      topic: _stringValue(json['topic']),
      difficulty: _stringValue(json['difficulty'], fallback: 'beginner'),
      active: _boolValue(json['active'], fallback: true),
    );
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: _stringValue(json['id']),
      question: _stringValue(json['question']),
      options: _stringList(json['options']),
      correctIndex: _intValue(json['correctIndex']),
      explanation: _stringValue(json['explanation']),
      topic: _stringValue(json['topic']),
      difficulty: _stringValue(json['difficulty'], fallback: 'beginner'),
      active: _boolValue(json['active'], fallback: true),
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

  bool get isValid =>
      active &&
      id.trim().isNotEmpty &&
      question.trim().isNotEmpty &&
      options.length >= 2 &&
      correctIndex >= 0 &&
      correctIndex < options.length &&
      explanation.trim().isNotEmpty &&
      topic.trim().isNotEmpty &&
      difficulty.trim().isNotEmpty;

  String get correctAnswerLabel =>
      correctIndex >= 0 && correctIndex < options.length ? options[correctIndex] : '';
}

class QuizAnswerResult {
  final bool correct;
  final int correctIndex;
  final String correctAnswerLabel;
  final String explanation;

  const QuizAnswerResult({
    required this.correct,
    required this.correctIndex,
    required this.correctAnswerLabel,
    required this.explanation,
  });

  factory QuizAnswerResult.fromJson(Map<String, dynamic> json) {
    return QuizAnswerResult(
      correct: _boolValue(json['correct']),
      correctIndex: _intValue(json['correctIndex']),
      correctAnswerLabel: _stringValue(json['correctAnswerLabel']),
      explanation: _stringValue(json['explanation']),
    );
  }
}

String _stringValue(Object? value, {String fallback = ''}) {
  if (value is String) return value.trim();
  return fallback;
}

List<String> _stringList(Object? value) {
  if (value is! List) return const [];

  return value
      .whereType<String>()
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

List<int> _intList(Object? value) {
  if (value is! List) return const [];

  return value.whereType<num>().map((item) => item.toInt()).toList();
}

int _intValue(Object? value) {
  if (value is num) return value.toInt();
  return 0;
}

bool _boolValue(Object? value, {bool fallback = false}) {
  if (value is bool) return value;
  return fallback;
}
