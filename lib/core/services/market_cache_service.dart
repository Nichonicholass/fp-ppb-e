import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Caches market stock and index data to SharedPreferences.
/// Used to serve stale data when Yahoo Finance is unreachable.
class MarketCacheService {
  static const _stockKeyPrefix = 'market_cache_stocks_';
  static const _indexKeyPrefix = 'market_cache_indices_';
  static const _timestampKeyPrefix = 'market_cache_ts_';

  /// Saves [stocks] and [indices] JSON to SharedPreferences under [mode] key.
  Future<void> save({
    required String mode,
    required List<Map<String, dynamic>> stocks,
    required List<Map<String, dynamic>> indices,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setString(_stockKeyPrefix + mode, jsonEncode(stocks)),
        prefs.setString(_indexKeyPrefix + mode, jsonEncode(indices)),
        prefs.setString(
          _timestampKeyPrefix + mode,
          DateTime.now().toIso8601String(),
        ),
      ]);
      debugPrint('[MarketCacheService] saved cache for mode=$mode');
    } catch (e) {
      debugPrint('[MarketCacheService] save error: $e');
    }
  }

  /// Loads cached data for [mode]. Returns `null` if no cache exists.
  Future<MarketCacheResult?> load(String mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stocksJson = prefs.getString(_stockKeyPrefix + mode);
      final indicesJson = prefs.getString(_indexKeyPrefix + mode);
      final tsStr = prefs.getString(_timestampKeyPrefix + mode);

      if (stocksJson == null || indicesJson == null || tsStr == null) {
        return null;
      }

      final stocks = (jsonDecode(stocksJson) as List)
          .cast<Map<String, dynamic>>();
      final indices = (jsonDecode(indicesJson) as List)
          .cast<Map<String, dynamic>>();
      final cachedAt = DateTime.parse(tsStr);

      debugPrint('[MarketCacheService] loaded cache for mode=$mode '
          '(age: ${DateTime.now().difference(cachedAt).inMinutes} min)');
      return MarketCacheResult(
          stocks: stocks, indices: indices, cachedAt: cachedAt);
    } catch (e) {
      debugPrint('[MarketCacheService] load error: $e');
      return null;
    }
  }
}

class MarketCacheResult {
  final List<Map<String, dynamic>> stocks;
  final List<Map<String, dynamic>> indices;
  final DateTime cachedAt;

  const MarketCacheResult({
    required this.stocks,
    required this.indices,
    required this.cachedAt,
  });
}
