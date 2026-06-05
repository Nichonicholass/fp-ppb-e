// ignore_for_file: avoid_print
// Seeding script — run with: dart bin/seed_questions.dart
// This script is NEVER included in the Flutter app build.
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:fintell/core/dummy_data/quiz_data.dart';

Future<void> main() async {
  print('=== Fintell Firestore Seeding Utility ===');
  final projectId = 'fintell-b789b';
  String? idToken;

  stdout.write('Do you want to authenticate with Firebase Auth? (y/n) [Default: y]: ');
  final authChoice = stdin.readLineSync()?.trim().toLowerCase();

  if (authChoice != 'n') {
    stdout.write('Enter Firebase Auth email: ');
    final email = stdin.readLineSync()?.trim();
    stdout.write('Enter Firebase Auth password: ');
    final password = stdin.readLineSync()?.trim();

    if (email != null && email.isNotEmpty && password != null && password.isNotEmpty) {
      final apiKey = 'AIzaSyDyHKt6N9__t3Z7mW6mcRTIzKOAShvkszg'; // From Web/Android config
      final authUrl = Uri.parse(
          'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey');

      try {
        print('Authenticating...');
        final authResponse = await http.post(
          authUrl,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }),
        );

        if (authResponse.statusCode == 200) {
          final authData = json.decode(authResponse.body);
          idToken = authData['idToken'];
          print('Successfully authenticated!');
        } else {
          print('Authentication failed: ${authResponse.statusCode} - ${authResponse.body}');
          print('Continuing without authentication (some write rules may deny)...');
        }
      } catch (e) {
        print('Error during authentication: $e');
        print('Continuing without authentication...');
      }
    } else {
      print('Email/password empty. Continuing without authentication...');
    }
  }

  // 1. Seed Modules
  print('\n--- Seeding Modules ---');
  for (final m in QuizData.defaultModules) {
    final docId = m.id;
    print('Seeding module: $docId...');

    final fields = {
      'title': {'stringValue': m.title},
      'description': {'stringValue': m.description},
      'iconName': {'stringValue': m.iconName},
      'gradientColorsValues': {
        'arrayValue': {
          'values': m.gradientColorsValues
              .map((val) => {'integerValue': val.toString()})
              .toList()
        }
      },
      'lessonText': {'stringValue': m.lessonText},
      'keyTakeaways': {
        'arrayValue': {
          'values': m.keyTakeaways
              .map((val) => {'stringValue': val})
              .toList()
        }
      },
      'sortOrder': {'integerValue': m.sortOrder.toString()},
    };

    final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/modules/$docId');

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (idToken != null) {
      headers['Authorization'] = 'Bearer $idToken';
    }

    try {
      final response = await http.patch(
        url,
        headers: headers,
        body: json.encode({'fields': fields}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Successfully seeded module: $docId!');
      } else {
        print('Failed to seed module: $docId: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error seeding module $docId: $e');
    }
  }

  // 2. Seed Questions
  print('\n--- Seeding Questions ---');
  for (final q in QuizData.defaultQuestions) {
    final docId = q.id;
    print('Seeding question: $docId...');

    final fields = {
      'question': {'stringValue': q.question},
      'options': {
        'arrayValue': {
          'values': q.options
              .map((opt) => {'stringValue': opt})
              .toList()
        }
      },
      'correctIndex': {'integerValue': q.correctIndex.toString()},
      'explanation': {'stringValue': q.explanation},
      'topic': {'stringValue': q.topic},
      'difficulty': {'stringValue': q.difficulty},
      'active': {'booleanValue': q.active},
    };

    final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/$projectId/databases/(default)/documents/questions/$docId');

    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (idToken != null) {
      headers['Authorization'] = 'Bearer $idToken';
    }

    try {
      final response = await http.patch(
        url,
        headers: headers,
        body: json.encode({'fields': fields}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Successfully seeded question: $docId!');
      } else {
        print('Failed to seed question: $docId: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error seeding question $docId: $e');
    }
  }

  print('\nSeeding complete!');
}
