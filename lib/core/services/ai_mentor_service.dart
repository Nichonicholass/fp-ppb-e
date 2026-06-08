import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AiMentorService {
  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';
  static const _systemInstruction =
      'You are Fintell AI, a helpful and friendly financial literacy mentor. '
      'Give clear, educational answers about investing, stocks, personal finance, '
      'and financial concepts. Keep responses concise (2–4 paragraphs max). '
      'When the user shares portfolio data, use it to give personalised advice. '
      'Never recommend specific stocks as guaranteed buys; always note that '
      'investing carries risk. Use plain text — no markdown like ** or ##.';

  final List<Map<String, String>> _history = [];

  void resetSession(List<Map<String, String>> history) {
    _history
      ..clear()
      ..addAll(history);
  }

  Future<String> sendMessage(String userMessage) async {
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    _history.add({'role': 'user', 'content': userMessage});

    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'system', 'content': _systemInstruction},
                ..._history,
              ],
              'max_tokens': 1024,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        debugPrint('[AiMentorService] HTTP ${response.statusCode}: ${response.body}');
        _history.removeLast();
        return 'Sorry, something went wrong (${response.statusCode}). Please try again.';
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final text = body['choices'][0]['message']['content'] as String;
      _history.add({'role': 'assistant', 'content': text});
      return text.trim();
    } catch (e) {
      debugPrint('[AiMentorService] error: $e');
      _history.removeLast();
      return 'Sorry, something went wrong. Please check your connection and try again.';
    }
  }
}
