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
      return QuizData.defaultQuestions.where((q) => q.isValid).toList();
    }

    final questions = snapshot.docs
        .map((doc) => QuizQuestion.fromFirestore(doc.data(), doc.id))
        .where((question) => question.isValid)
        .toList();

    if (questions.isEmpty) {
      return QuizData.defaultQuestions.where((q) => q.isValid).toList();
    }

    return questions;
  }

  Future<List<QuizModule>> fetchModules() async {
    final snapshot = await _db
        .collection('modules')
        .orderBy('sortOrder')
        .get();

    if (snapshot.docs.isEmpty) {
      return QuizData.defaultModules.where((m) => m.isValid).toList();
    }

    final modules = snapshot.docs
        .map((doc) => QuizModule.fromFirestore(doc.data(), doc.id))
        .where((module) => module.isValid)
        .toList();

    if (modules.isEmpty) {
      return QuizData.defaultModules.where((m) => m.isValid).toList();
    }

    return modules;
  }
}
