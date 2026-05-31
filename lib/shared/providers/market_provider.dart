import 'package:flutter/material.dart';
import '../../core/dummy_data/app_data.dart';
import '../../core/services/market_service.dart';

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
    _SM('BRK/B', 'Berkshire Hathaway', 21.4, 15.2, 'Finance', Color(0xFF8B4513), display: 'BRK.B'),
    _SM('JPM', 'JPMorgan Chase', 11.8, 16.9, 'Finance', Color(0xFF003087)),
    _SM('JNJ', 'Johnson & Johnson', 16.3, 23.8, 'Healthcare', Color(0xFFD32F2F)),
  ];

  static const _indexMeta = [
    _IM('SPX', 'S&P 500'),
    _IM('IXIC', 'NASDAQ'),
    _IM('DJI', 'DOW'),
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
        ..._stockMeta.map((m) => m.apiSymbol),
        ..._indexMeta.map((m) => m.symbol),
      ];

      final quotes = await _service.fetchQuotes(allSymbols);

      _stocks = _stockMeta.map((meta) {
        final q = quotes[meta.apiSymbol];
        return Stock(
          ticker: meta.displayTicker,
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
      if (_stocks.isEmpty) {
        _stocks = List.from(AppData.popularStocks);
        _indices = List.from(AppData.indices);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class _SM {
  final String apiSymbol;
  final String name;
  final double peRatio;
  final double roe;
  final String sector;
  final Color color;
  final String? display;

  String get displayTicker => display ?? apiSymbol;

  const _SM(
    this.apiSymbol,
    this.name,
    this.peRatio,
    this.roe,
    this.sector,
    this.color, {
    this.display,
  });
}

class _IM {
  final String symbol;
  final String name;
  const _IM(this.symbol, this.name);
}
