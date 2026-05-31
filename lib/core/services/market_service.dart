import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class QuoteData {
  final double price;
  final double changePercent;
  const QuoteData({required this.price, required this.changePercent});
}

class MarketService {
  String get _apiKey => dotenv.env['TWELVE_DATA_API_KEY'] ?? '';

  Future<Map<String, QuoteData>> fetchQuotes(List<String> symbols) async {
    final uri = Uri.https('api.twelvedata.com', '/quote', {
      'symbol': symbols.join(','),
      'apikey': _apiKey,
    });

    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final result = <String, QuoteData>{};

    if (symbols.length == 1) {
      if (body['close'] != null) {
        result[symbols.first] = _parseQuote(body);
      }
    } else {
      for (final symbol in symbols) {
        final data = body[symbol];
        if (data is Map<String, dynamic> && data['close'] != null) {
          result[symbol] = _parseQuote(data);
        }
      }
    }

    return result;
  }

  QuoteData _parseQuote(Map<String, dynamic> data) {
    return QuoteData(
      price: double.tryParse(data['close']?.toString() ?? '') ?? 0,
      changePercent: double.tryParse(data['percent_change']?.toString() ?? '') ?? 0,
    );
  }
}
