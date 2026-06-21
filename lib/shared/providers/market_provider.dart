import 'package:flutter/material.dart';
import '../../core/services/market_service.dart';
import '../../core/services/currency_service.dart';
import '../../core/dummy_data/app_data.dart' show Stock, MarketIndex;

enum MarketMode { luarNegeri, dalamNegeri }

class MarketProvider extends ChangeNotifier {
  final _service = MarketService();

  MarketMode _mode = MarketMode.luarNegeri;
  List<Stock> _stocks = [];
  List<MarketIndex> _indices = [];
  bool _isLoading = false;
  String? _error;

  MarketMode get mode => _mode;
  List<Stock> get stocks => _stocks;
  List<MarketIndex> get indices => _indices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasData => _stocks.isNotEmpty;
  bool get isIDX => _mode == MarketMode.dalamNegeri;

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

      final quotes = await _service.fetchQuotes(allSymbols);

      _stocks = stockMeta.map((meta) {
        final q = quotes[meta.symbol];
        // IDX prices stay in IDR (native) — conversion handled at display/buy time
        return Stock(
          ticker: meta.symbol.replaceAll('.JK', ''),
          symbol: meta.symbol,
          name: meta.name,
          price: q?.price ?? 0,
          changePercent: q?.changePercent ?? 0,
          peRatio: meta.peRatio,
          roe: meta.roe,
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
