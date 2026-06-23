import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AiMentorService {
  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';

  static const _systemInstructionGlobal =
      'You are Fintell AI, a helpful and friendly financial literacy mentor. '
      'Give clear, educational answers about investing, stocks, personal finance, '
      'and financial concepts in the US and global markets (USD currency). '
      'Keep responses concise (2–4 paragraphs max). '
      'When the user shares portfolio data, use it to give personalised advice. '
      'Never recommend specific stocks as guaranteed buys; always note that '
      'investing carries risk. Use plain text — no markdown like ** or ##.';

  static const _systemInstructionIDX =
      'You are Fintell AI, a helpful and friendly financial literacy mentor '
      'specialising in the Indonesian IDX (Bursa Efek Indonesia) stock market. '
      'Give clear, educational answers about investing in Indonesian stocks '
      '(IDR currency), OJK regulations, Reksa Dana (mutual funds), saham, '
      'obligasi, and Indonesian personal finance concepts. '
      'Keep responses concise (2–4 paragraphs max). '
      'When the user shares portfolio data, use it to give personalised advice. '
      'Never recommend specific stocks as guaranteed buys; always note that '
      'investing carries risk. Use plain text — no markdown like ** or ##.';

  String _systemInstruction = _systemInstructionGlobal;

  final List<Map<String, String>> _history = [];

  /// Call this whenever the user switches between Global and IDX market mode.
  void setMarketContext(bool isIDX) {
    _systemInstruction =
        isIDX ? _systemInstructionIDX : _systemInstructionGlobal;
  }

  void resetSession(List<Map<String, String>> history) {
    _history
      ..clear()
      ..addAll(history);
  }

  Stream<String> sendMessageStream(String userMessage) async* {
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    _history.add({'role': 'user', 'content': userMessage});

    final client = http.Client();
    try {
      final request = http.Request('POST', Uri.parse(_baseUrl));
      request.headers['Authorization'] = 'Bearer $apiKey';
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'system', 'content': _systemInstruction},
          ..._history,
        ],
        'max_tokens': 1024,
        'stream': true,
      });

      final streamed = await client.send(request);

      if (streamed.statusCode != 200) {
        final body = await streamed.stream.bytesToString();
        debugPrint('[AiMentorService] HTTP ${streamed.statusCode}: $body');
        _history.removeLast();
        throw Exception('API error ${streamed.statusCode}');
      }

      final fullResponse = StringBuffer();
      await for (final chunk in streamed.stream.transform(utf8.decoder)) {
        for (final line in chunk.split('\n')) {
          final trimmed = line.trim();
          if (!trimmed.startsWith('data: ')) continue;
          final data = trimmed.substring(6);
          if (data == '[DONE]') break;
          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final delta = json['choices']?[0]?['delta']?['content'] as String?;
            if (delta != null && delta.isNotEmpty) {
              fullResponse.write(delta);
              yield delta;
            }
          } catch (_) {
            // skip malformed SSE chunks
          }
        }
      }

      _history.add({'role': 'assistant', 'content': fullResponse.toString()});
    } catch (e) {
      debugPrint('[AiMentorService] streaming error: $e');
      _history.removeLast();
      rethrow;
    } finally {
      client.close();
    }
  }
}
