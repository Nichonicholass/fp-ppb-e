import 'package:cloud_firestore/cloud_firestore.dart';
import '../dummy_data/quiz_data.dart';
import '../models/quiz_models.dart';

class QuizService {
  final FirebaseFirestore _db;

  QuizService({
    FirebaseFirestore? db,
  }) : _db = db ?? FirebaseFirestore.instance;

  Future<List<QuizQuestion>> fetchQuestions() async {
    final snapshot = await _db
        .collection('questions')
        .where('active', isEqualTo: true)
        .get();

    if (snapshot.docs.isEmpty) {
      return QuizData.defaultQuestions;
    }

    return snapshot.docs
        .map((doc) => QuizQuestion.fromFirestore(doc.data(), doc.id))
        .toList();
  }


  Future<List<QuizModule>> fetchModules() async {
    final snapshot = await _db
        .collection('modules')
        .orderBy('sortOrder')
        .get();

    if (snapshot.docs.isEmpty) {
      return QuizData.defaultModules;
    }

    return snapshot.docs
        .map((doc) => QuizModule.fromFirestore(doc.data(), doc.id))
        .toList();
  }
}
