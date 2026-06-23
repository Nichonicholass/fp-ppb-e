import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A row from the Supabase `stock_fundamentals` table.
class StockFundamentals {
  final double peRatio;
  final double roe;

  const StockFundamentals({required this.peRatio, required this.roe});
}

/// Fetches PE Ratio and ROE from Supabase.
///
/// Expected table schema (run once in Supabase SQL editor):
/// ```sql
/// create table if not exists stock_fundamentals (
///   symbol     text primary key,
///   pe_ratio   double precision not null default 0,
///   roe        double precision not null default 0,
///   updated_at timestamptz not null default now()
/// );
/// alter table stock_fundamentals enable row level security;
/// create policy "Public read" on stock_fundamentals
///   for select using (true);
/// ```
///
/// Populate / refresh with an Edge Function or manually via the Supabase
/// dashboard. Falls back to an empty map if the table does not yet exist
/// or if the request fails, so the app continues working with hardcoded data.
class FundamentalsService {
  final _client = Supabase.instance.client;

  /// Returns a map of `{ symbol -> StockFundamentals }`.
  /// Silently returns `{}` on any error.
  Future<Map<String, StockFundamentals>> fetchAll() async {
    try {
      final data = await _client
          .from('stock_fundamentals')
          .select('symbol, pe_ratio, roe');

      final map = <String, StockFundamentals>{};
      for (final row in data as List<dynamic>) {
        final symbol = row['symbol'] as String?;
        if (symbol == null) continue;
        map[symbol] = StockFundamentals(
          peRatio: (row['pe_ratio'] as num?)?.toDouble() ?? 0,
          roe: (row['roe'] as num?)?.toDouble() ?? 0,
        );
      }
      debugPrint('[FundamentalsService] fetched ${map.length} rows');
      return map;
    } catch (e) {
      debugPrint('[FundamentalsService] error (using hardcoded fallback): $e');
      return {};
    }
  }
}
