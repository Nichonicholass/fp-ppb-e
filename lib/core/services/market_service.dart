import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class QuoteData {
  final double price;
  final double changePercent;
  const QuoteData({required this.price, required this.changePercent});
}

class MarketService {
  Future<Map<String, QuoteData>> fetchQuotes(List<String> symbols) async {
    debugPrint('[MarketService] fetching ${symbols.length} symbols via v8...');

    // Fire all requests in parallel
    final futures = symbols.map(_fetchOne);
    final results = await Future.wait(futures);

    final map = <String, QuoteData>{};
    for (int i = 0; i < symbols.length; i++) {
      if (results[i] != null) map[symbols[i]] = results[i]!;
    }

    debugPrint('[MarketService] got ${map.length}/${symbols.length} quotes');
    return map;
  }

  Future<QuoteData?> _fetchOne(String symbol) async {
    try {
      // ^ in index symbols (^GSPC) must be percent-encoded
      final encoded = Uri.encodeComponent(symbol);
      final url =
          'https://query1.finance.yahoo.com/v8/finance/chart/$encoded'
          '?interval=1d&range=1d';

      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'Mozilla/5.0'},
      ).timeout(const Duration(seconds: 15));

      debugPrint('[MarketService] $symbol → ${response.statusCode}');

      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final resultList =
          (body['chart']?['result'] as List?);
      if (resultList == null || resultList.isEmpty) return null;

      final meta = resultList[0]['meta'] as Map<String, dynamic>?;
      if (meta == null) return null;

      final price =
          (meta['regularMarketPrice'] as num?)?.toDouble() ?? 0;
      final changePercent =
          (meta['regularMarketChangePercent'] as num?)?.toDouble() ??
          _calcChange(price, meta);

      return QuoteData(price: price, changePercent: changePercent);
    } catch (e) {
      debugPrint('[MarketService] $symbol error: $e');
      return null;
    }
  }

  // Fallback: compute % change from previous close if field is missing
  double _calcChange(double price, Map<String, dynamic> meta) {
    final prev =
        (meta['chartPreviousClose'] as num?)?.toDouble() ??
        (meta['previousClose'] as num?)?.toDouble() ??
        0;
    if (prev == 0) return 0;
    return ((price - prev) / prev) * 100;
  }
}
