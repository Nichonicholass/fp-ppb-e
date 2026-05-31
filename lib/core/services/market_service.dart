import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class QuoteData {
  final double price;
  final double changePercent;
  const QuoteData({required this.price, required this.changePercent});
}

class StockDetail {
  final double price;
  final double change;
  final double changePercent;
  final double open;
  final double high;
  final double low;
  final double volume;
  final double prevClose;
  final double weekHigh52;
  final double weekLow52;
  final String currency;
  final String exchange;
  final List<double> closePrices;
  final List<int> timestamps;

  const StockDetail({
    required this.price,
    required this.change,
    required this.changePercent,
    required this.open,
    required this.high,
    required this.low,
    required this.volume,
    required this.prevClose,
    required this.weekHigh52,
    required this.weekLow52,
    required this.currency,
    required this.exchange,
    required this.closePrices,
    required this.timestamps,
  });
}

class MarketService {
  Future<Map<String, QuoteData>> fetchQuotes(List<String> symbols) async {
    debugPrint('[MarketService] fetching ${symbols.length} symbols via v8...');

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
      final resultList = (body['chart']?['result'] as List?);
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

  Future<StockDetail?> fetchDetail(String symbol, String range) async {
    try {
      final encoded = Uri.encodeComponent(symbol);
      final url =
          'https://query1.finance.yahoo.com/v8/finance/chart/$encoded'
          '?interval=1d&range=$range';

      debugPrint('[MarketService] fetchDetail $symbol range=$range');

      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'Mozilla/5.0'},
      ).timeout(const Duration(seconds: 15));

      debugPrint('[MarketService] detail $symbol → ${response.statusCode}');

      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final resultList = body['chart']?['result'] as List?;
      if (resultList == null || resultList.isEmpty) return null;

      final result = resultList[0] as Map<String, dynamic>;
      final meta = result['meta'] as Map<String, dynamic>?;
      if (meta == null) return null;

      final price = (meta['regularMarketPrice'] as num?)?.toDouble() ?? 0;
      final change = (meta['regularMarketChange'] as num?)?.toDouble() ?? 0;
      final changePercent =
          (meta['regularMarketChangePercent'] as num?)?.toDouble() ??
          _calcChange(price, meta);
      final open = (meta['regularMarketOpen'] as num?)?.toDouble() ?? 0;
      final high = (meta['regularMarketDayHigh'] as num?)?.toDouble() ?? 0;
      final low = (meta['regularMarketDayLow'] as num?)?.toDouble() ?? 0;
      final volume = (meta['regularMarketVolume'] as num?)?.toDouble() ?? 0;
      final prevClose =
          (meta['regularMarketPreviousClose'] as num?)?.toDouble() ??
          (meta['chartPreviousClose'] as num?)?.toDouble() ?? 0;
      final weekHigh52 = (meta['fiftyTwoWeekHigh'] as num?)?.toDouble() ?? 0;
      final weekLow52 = (meta['fiftyTwoWeekLow'] as num?)?.toDouble() ?? 0;
      final currency = meta['currency'] as String? ?? 'USD';
      final exchange = meta['exchangeName'] as String? ?? '';

      // Extract historical close prices, skipping null entries
      final indicators = result['indicators'] as Map<String, dynamic>?;
      final quoteList = indicators?['quote'] as List?;
      final rawCloses = (quoteList?.isNotEmpty == true)
          ? (quoteList![0] as Map<String, dynamic>)['close'] as List?
          : null;
      final rawTimestamps = result['timestamp'] as List?;

      final closePrices = <double>[];
      final timestamps = <int>[];
      if (rawCloses != null && rawTimestamps != null) {
        for (int i = 0; i < rawCloses.length; i++) {
          final c = rawCloses[i];
          if (c != null && i < rawTimestamps.length) {
            closePrices.add((c as num).toDouble());
            timestamps.add((rawTimestamps[i] as num).toInt());
          }
        }
      }

      return StockDetail(
        price: price,
        change: change,
        changePercent: changePercent,
        open: open,
        high: high,
        low: low,
        volume: volume,
        prevClose: prevClose,
        weekHigh52: weekHigh52,
        weekLow52: weekLow52,
        currency: currency,
        exchange: exchange,
        closePrices: closePrices,
        timestamps: timestamps,
      );
    } catch (e) {
      debugPrint('[MarketService] detail $symbol error: $e');
      return null;
    }
  }

  double _calcChange(double price, Map<String, dynamic> meta) {
    final prev =
        (meta['chartPreviousClose'] as num?)?.toDouble() ??
        (meta['previousClose'] as num?)?.toDouble() ??
        0;
    if (prev == 0) return 0;
    return ((price - prev) / prev) * 100;
  }
}
