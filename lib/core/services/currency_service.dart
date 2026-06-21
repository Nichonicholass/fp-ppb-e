import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Fetches USD → IDR exchange rate once per app session.
/// Falls back to [_kFallbackRate] if the request fails or times out.
class CurrencyService {
  static const double _kFallbackRate = 17000.0;
  static const String _apiUrl =
      'https://open.er-api.com/v6/latest/USD';

  // In-memory cache — lives as long as the app is running
  static double? _cachedRate;
  static bool _fetched = false;

  /// Returns USD → IDR rate.
  /// Fetches from the API on the first call; returns cached value afterwards.
  static Future<double> getUsdToIdr() async {
    if (_fetched) return _cachedRate ?? _kFallbackRate;

    _fetched = true; // mark early so concurrent calls don't double-fetch
    try {
      final response = await http
          .get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final rates = body['rates'] as Map<String, dynamic>?;
        final idr = (rates?['IDR'] as num?)?.toDouble();
        if (idr != null && idr > 0) {
          _cachedRate = idr;
          debugPrint('[CurrencyService] live rate USD→IDR: $idr');
          return idr;
        }
      }
    } catch (e) {
      debugPrint('[CurrencyService] fetch error: $e — using fallback $_kFallbackRate');
    }

    // Fallback
    _cachedRate = _kFallbackRate;
    return _kFallbackRate;
  }

  /// Convert IDR amount to USD using the cached/fetched rate.
  static double idrToUsd(double idrAmount) {
    final rate = _cachedRate ?? _kFallbackRate;
    return idrAmount / rate;
  }

  /// Convert USD amount to IDR using the cached/fetched rate.
  static double usdToIdr(double usdAmount) {
    final rate = _cachedRate ?? _kFallbackRate;
    return usdAmount * rate;
  }

  /// Whether the current rate is live (fetched) or the hardcoded fallback.
  static bool get isLiveRate =>
      _fetched && _cachedRate != null && _cachedRate != _kFallbackRate;

  /// The rate currently in use (fallback if not yet fetched).
  static double get currentRate => _cachedRate ?? _kFallbackRate;

  /// Reset cache (useful for testing or manual refresh).
  static void resetCache() {
    _cachedRate = null;
    _fetched = false;
  }
}
