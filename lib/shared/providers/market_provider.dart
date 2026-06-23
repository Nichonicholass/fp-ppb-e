import 'package:flutter/material.dart';
import '../../core/services/market_service.dart';
import '../../core/services/currency_service.dart';
import '../../core/services/fundamentals_service.dart';
import '../../core/services/market_cache_service.dart';
import '../../core/dummy_data/app_data.dart' show Stock, MarketIndex;

enum MarketMode { luarNegeri, dalamNegeri }

class MarketProvider extends ChangeNotifier {
  final _service = MarketService();
  final _fundamentalsService = FundamentalsService();
  final _cacheService = MarketCacheService();

  MarketMode _mode = MarketMode.luarNegeri;
  List<Stock> _stocks = [];
  List<MarketIndex> _indices = [];
  bool _isLoading = false;
  String? _error;
  bool _isFromCache = false;
  DateTime? _cachedAt;

  MarketMode get mode => _mode;
  List<Stock> get stocks => _stocks;
  List<MarketIndex> get indices => _indices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _stocks.isNotEmpty;
  bool get isIDX => _mode == MarketMode.dalamNegeri;
  bool get isFromCache => _isFromCache;
  DateTime? get cachedAt => _cachedAt;

  /// Current USD→IDR rate being used (live or fallback)
  double get usdToIdrRate => CurrencyService.currentRate;
  /// True if the rate was fetched live, false if using fallback Rp 17.000
  bool get isLiveRate => CurrencyService.isLiveRate;

  // ── Global (Luar Negeri) ──────────────────────────────────────────────────
  static const _stockMetaGlobal = [
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

  static const _indexMetaGlobal = [
    _IM('^GSPC', 'S&P 500'),
    _IM('^IXIC', 'NASDAQ'),
    _IM('^DJI', 'DOW'),
  ];

  // ── Dalam Negeri (IDX) ────────────────────────────────────────────────────
  static const _stockMetaIDX = [
    _SM('BBCA.JK', 'Bank Central Asia', 24.1, 18.2, 'Keuangan', Color(0xFF003087)),
    _SM('BBRI.JK', 'Bank Rakyat Indonesia', 13.5, 20.1, 'Keuangan', Color(0xFF003D99)),
    _SM('TLKM.JK', 'Telkom Indonesia', 16.8, 24.3, 'Telekomunikasi', Color(0xFFDD0031)),
    _SM('ASII.JK', 'Astra International', 10.2, 12.5, 'Industri', Color(0xFF0EA5E9)),
    _SM('BMRI.JK', 'Bank Mandiri', 12.3, 17.8, 'Keuangan', Color(0xFFFF9900)),
    _SM('UNVR.JK', 'Unilever Indonesia', 22.4, 98.5, 'Konsumer', Color(0xFF1877F2)),
    _SM('GOTO.JK', 'GoTo Gojek Tokopedia', 0.0, -5.2, 'Teknologi', Color(0xFF00B14F)),
    _SM('ICBP.JK', 'Indofood CBP Sukses', 15.6, 14.2, 'Konsumer', Color(0xFFE50914)),
    _SM('KLBF.JK', 'Kalbe Farma', 26.3, 17.5, 'Kesehatan', Color(0xFF10B981)),
    _SM('HMSP.JK', 'HM Sampoerna', 18.9, 55.3, 'Konsumer', Color(0xFF8B4513)),
    _SM('INDF.JK', 'Indofood Sukses Makmur', 9.8, 13.6, 'Konsumer', Color(0xFFED1C24)),
    _SM('ADRO.JK', 'Adaro Energy Indonesia', 6.2, 22.8, 'Energi', Color(0xFF374151)),
    _SM('ANTM.JK', 'Aneka Tambang', 11.5, 9.3, 'Pertambangan', Color(0xFFF59E0B)),
    _SM('BBNI.JK', 'Bank Negara Indonesia', 9.1, 13.4, 'Keuangan', Color(0xFFFF6A00)),
    _SM('EXCL.JK', 'XL Axiata', 20.4, 8.7, 'Telekomunikasi', Color(0xFF6366F1)),
  ];

  static const _indexMetaIDX = [
    _IM('^JKSE', 'IHSG'),
    _IM('^JKLQ45', 'LQ45'),
    _IM('^JKII', 'IDX30'),
  ];

  MarketProvider({bool fetchOnCreate = true}) {
    if (fetchOnCreate) {
      // Fetch exchange rate immediately on startup (runs in background)
      CurrencyService.getUsdToIdr();
      fetchAll();
    }
  }

  Future<void> switchMode(MarketMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    _stocks = [];
    _indices = [];
    notifyListeners();
    await fetchAll();
  }

  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final stockMeta = isIDX ? _stockMetaIDX : _stockMetaGlobal;
    final indexMeta = isIDX ? _indexMetaIDX : _indexMetaGlobal;

    try {
      // Fetch exchange rate in background (cached after first call)
      CurrencyService.getUsdToIdr();

      final allSymbols = [
        ...stockMeta.map((m) => m.symbol),
        ...indexMeta.map((m) => m.symbol),
      ];

      // Fetch live quotes and Supabase fundamentals in parallel
      final results = await Future.wait([
        _service.fetchQuotes(allSymbols),
        _fundamentalsService.fetchAll(),
      ]);
      final quotes = results[0] as Map<String, QuoteData>;
      final fundamentals = results[1] as Map<String, StockFundamentals>;

      _stocks = stockMeta.map((meta) {
        final q = quotes[meta.symbol];
        // Prefer live Supabase fundamentals; fall back to hardcoded meta values
        final fund = fundamentals[meta.symbol] ??
            fundamentals[meta.symbol.replaceAll('.JK', '')];
        // IDX prices stay in IDR (native) — conversion handled at display/buy time
        return Stock(
          ticker: meta.symbol.replaceAll('.JK', ''),
          symbol: meta.symbol,
          name: meta.name,
          price: q?.price ?? 0,
          changePercent: q?.changePercent ?? 0,
          peRatio: fund?.peRatio ?? meta.peRatio,
          roe: fund?.roe ?? meta.roe,
          sector: meta.sector,
          color: meta.color,
        );
      }).toList();

      _indices = indexMeta.map((meta) {
        final q = quotes[meta.symbol];
        return MarketIndex(
          name: meta.name,
          value: q?.price ?? 0,
          changePercent: q?.changePercent ?? 0,
        );
      }).toList();

      _isFromCache = false;
      _cachedAt = null;

      // Persist successful fetch to local cache
      await _cacheService.save(
        mode: _mode.name,
        stocks: _stocks.map(_stockToMap).toList(),
        indices: _indices.map(_indexToMap).toList(),
      );
    } catch (e) {
      _error = e.toString();

      // Attempt to serve stale cached data on failure
      final cached = await _cacheService.load(_mode.name);
      if (cached != null && _stocks.isEmpty) {
        _stocks = cached.stocks.map(_stockFromMap).toList();
        _indices = cached.indices.map(_indexFromMap).toList();
        _isFromCache = true;
        _cachedAt = cached.cachedAt;
        _error = null; // suppress error when we have usable cached data
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Cache serialization helpers ──────────────────────────────────────────

  Map<String, dynamic> _stockToMap(Stock s) => {
        'ticker': s.ticker,
        'symbol': s.symbol,
        'name': s.name,
        'price': s.price,
        'changePercent': s.changePercent,
        'peRatio': s.peRatio,
        'roe': s.roe,
        'sector': s.sector,
        'colorValue': s.color.toARGB32(),
      };

  Stock _stockFromMap(Map<String, dynamic> m) => Stock(
        ticker: m['ticker'] as String,
        symbol: m['symbol'] as String,
        name: m['name'] as String,
        price: (m['price'] as num).toDouble(),
        changePercent: (m['changePercent'] as num).toDouble(),
        peRatio: (m['peRatio'] as num).toDouble(),
        roe: (m['roe'] as num).toDouble(),
        sector: m['sector'] as String,
        color: Color(m['colorValue'] as int),
      );

  Map<String, dynamic> _indexToMap(MarketIndex idx) => {
        'name': idx.name,
        'value': idx.value,
        'changePercent': idx.changePercent,
      };

  MarketIndex _indexFromMap(Map<String, dynamic> m) => MarketIndex(
        name: m['name'] as String,
        value: (m['value'] as num).toDouble(),
        changePercent: (m['changePercent'] as num).toDouble(),
      );
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
