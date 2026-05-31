import 'package:flutter/material.dart';
import '../../core/services/market_service.dart';
import '../../core/dummy_data/app_data.dart' show Stock, MarketIndex;

class MarketProvider extends ChangeNotifier {
  final _service = MarketService();

  List<Stock> _stocks = [];
  List<MarketIndex> _indices = [];
  bool _isLoading = false;
  String? _error;

  List<Stock> get stocks => _stocks;
  List<MarketIndex> get indices => _indices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _stocks.isNotEmpty;

  static const _stockMeta = [
    _SM('AAPL', 'Apple Inc.', 29.5, 160.1, 'Technology', Color(0xFF6366F1)),
    _SM('MSFT', 'Microsoft Corp.', 37.2, 38.5, 'Technology', Color(0xFF0EA5E9)),
    _SM('GOOGL', 'Alphabet Inc.', 25.8, 28.3, 'Technology', Color(0xFFEA4335)),
    _SM('AMZN', 'Amazon.com Inc.', 59.4, 19.7, 'Consumer Disc.', Color(0xFFFF9900)),
    _SM('NVDA', 'NVIDIA Corp.', 68.1, 91.8, 'Technology', Color(0xFF76B900)),
    _SM('META', 'Meta Platforms', 28.9, 35.4, 'Comm. Services', Color(0xFF1877F2)),
    _SM('TSLA', 'Tesla Inc.', 44.3, 21.1, 'Consumer Disc.', Color(0xFFCC0000)),
    _SM('JPM', 'JPMorgan Chase', 11.8, 16.9, 'Finance', Color(0xFF003087)),
    _SM('JNJ', 'Johnson & Johnson', 16.3, 23.8, 'Healthcare', Color(0xFFD32F2F)),
    _SM('V', 'Visa Inc.', 30.1, 44.7, 'Finance', Color(0xFF1A1F71)),
    _SM('BRK-B', 'Berkshire Hathaway', 21.4, 15.2, 'Finance', Color(0xFF8B4513)),
    _SM('NFLX', 'Netflix Inc.', 45.0, 28.5, 'Comm. Services', Color(0xFFE50914)),
    _SM('AMD', 'Advanced Micro Devices', 35.5, 8.2, 'Technology', Color(0xFFED1C24)),
    _SM('DIS', 'Walt Disney Co.', 32.0, 6.5, 'Comm. Services', Color(0xFF006E99)),
    _SM('WMT', 'Walmart Inc.', 38.5, 23.1, 'Consumer Staples', Color(0xFF0071CE)),
    _SM('PG', 'Procter & Gamble', 25.8, 31.2, 'Consumer Staples', Color(0xFF003D99)),
    _SM('XOM', 'ExxonMobil Corp.', 14.2, 19.8, 'Energy', Color(0xFFDD0031)),
    _SM('BABA', 'Alibaba Group', 18.5, 14.5, 'Consumer Disc.', Color(0xFFFF6A00)),
    _SM('PYPL', 'PayPal Holdings', 15.8, 20.3, 'Finance', Color(0xFF009CDE)),
    _SM('COIN', 'Coinbase Global', 55.2, 25.5, 'Finance', Color(0xFF0052FF)),
  ];

  // Yahoo Finance index symbols
  static const _indexMeta = [
    _IM('^GSPC', 'S&P 500'),
    _IM('^IXIC', 'NASDAQ'),
    _IM('^DJI', 'DOW'),
  ];

  MarketProvider() {
    fetchAll();
  }

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final allSymbols = [
        ..._stockMeta.map((m) => m.symbol),
        ..._indexMeta.map((m) => m.symbol),
      ];

      final quotes = await _service.fetchQuotes(allSymbols);

      _stocks = _stockMeta.map((meta) {
        final q = quotes[meta.symbol];
        return Stock(
          ticker: meta.symbol,
          name: meta.name,
          price: q?.price ?? 0,
          changePercent: q?.changePercent ?? 0,
          peRatio: meta.peRatio,
          roe: meta.roe,
          sector: meta.sector,
          color: meta.color,
        );
      }).toList();

      _indices = _indexMeta.map((meta) {
        final q = quotes[meta.symbol];
        return MarketIndex(
          name: meta.name,
          value: q?.price ?? 0,
          changePercent: q?.changePercent ?? 0,
        );
      }).toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class _SM {
  final String symbol;
  final String name;
  final double peRatio;
  final double roe;
  final String sector;
  final Color color;
  const _SM(this.symbol, this.name, this.peRatio, this.roe, this.sector, this.color);
}

class _IM {
  final String symbol;
  final String name;
  const _IM(this.symbol, this.name);
}
