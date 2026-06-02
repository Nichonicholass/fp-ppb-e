import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/dummy_data/app_data.dart';
import '../../core/services/market_service.dart';

class WatchlistProvider extends ChangeNotifier {
  static const List<String> _defaultSectors = [
    'Technology',
    'Finance',
    'Healthcare',
  ];

  final Map<String, List<Stock>> _watchlists = {
    'Technology': List<Stock>.from(AppData.watchlistTech),
    'Finance': List<Stock>.from(AppData.watchlistFinance),
    'Healthcare': List<Stock>.from(AppData.watchlistHealth),
  };

  StreamSubscription? _authSubscription;
  StreamSubscription? _firestoreSubscription;

  WatchlistProvider() {
    _initAuthListener();
    fetchWatchlistPrices();
  }

  void _initAuthListener() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      _firestoreSubscription?.cancel();

      if (user != null) {
        _firestoreSubscription = FirebaseFirestore.instance
            .collection('watchlists')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            final data = snapshot.data() as Map<String, dynamic>;

            for (final sector in _defaultSectors) {
              final List<dynamic> tickers = data[sector] ?? [];
              final List<Stock> resolvedStocks = [];

              for (final tickerObj in tickers) {
                final ticker = tickerObj.toString();
                
                Stock? existing;
                if (_watchlists.containsKey(sector)) {
                  for (final s in _watchlists[sector]!) {
                    if (_matchesStock(s, ticker)) {
                      existing = s;
                      break;
                    }
                  }
                }

                final stock = existing ?? _resolveStock(ticker);

                if (stock != null) {
                  resolvedStocks.add(stock);
                }
              }

              _watchlists[sector] = resolvedStocks;
            }

            notifyListeners();
            fetchWatchlistPrices();
          } else {
            _syncToFirestore();
          }
        }, onError: (err) {
          debugPrint('Firestore Watchlist error: $err');
        });
      } else {
        _watchlists['Technology'] = List<Stock>.from(AppData.watchlistTech);
        _watchlists['Finance'] = List<Stock>.from(AppData.watchlistFinance);
        _watchlists['Healthcare'] = List<Stock>.from(AppData.watchlistHealth);

        notifyListeners();
        fetchWatchlistPrices();
      }
    });
  }

  void _syncToFirestore() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final Map<String, List<String>> serialized = {};
    for (final entry in _watchlists.entries) {
      serialized[entry.key] = entry.value.map((s) => s.ticker).toList();
    }

    FirebaseFirestore.instance
        .collection('watchlists')
        .doc(user.uid)
        .set(serialized)
        .catchError((err) {
      debugPrint('Error syncing watchlist to Firestore: $err');
    });
  }

  final _service = MarketService();

  Future<void> fetchWatchlistPrices() async {
    final List<String> symbolsToFetch = [];
    for (final list in _watchlists.values) {
      for (final stock in list) {
        if (!symbolsToFetch.contains(stock.symbol)) {
          symbolsToFetch.add(stock.symbol);
        }
      }
    }

    if (symbolsToFetch.isEmpty) return;

    try {
      final quotes = await _service.fetchQuotes(symbolsToFetch);
      bool updatedAny = false;

      for (final sector in _watchlists.keys) {
        final list = _watchlists[sector]!;
        for (int i = 0; i < list.length; i++) {
          final stock = list[i];
          final quote = quotes[stock.symbol];
          if (quote != null) {
            list[i] = Stock(
              ticker: stock.ticker,
              symbol: stock.symbol,
              name: stock.name,
              price: quote.price,
              changePercent: quote.changePercent,
              peRatio: stock.peRatio,
              roe: stock.roe,
              sector: stock.sector,
              color: stock.color,
            );
            updatedAny = true;
          }
        }
      }

      if (updatedAny) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching watchlist prices: $e');
    }
  }

  List<String> get sectors => _watchlists.keys.toList();

  List<Stock> getStocks(String sector) =>
      List.unmodifiable(_watchlists[sector] ?? []);

  bool isWatched(String ticker) =>
      _watchlists.values.any(
        (list) => list.any((s) => _matchesStock(s, ticker)),
      );

  bool isWatchedInSector(String sector, String ticker) =>
      (_watchlists[sector] ?? []).any((s) => _matchesStock(s, ticker));

  void addStock(String sector, Stock stock) {
    if (!_watchlists.containsKey(sector)) {
      _watchlists[sector] = [];
    }

    if (isWatchedInSector(sector, stock.ticker)) return;

    _watchlists[sector]!.add(stock);
    notifyListeners();
    _syncToFirestore();
  }

  void insertStock(String sector, int index, Stock stock) {
    if (!_watchlists.containsKey(sector)) {
      _watchlists[sector] = [];
    }

    if (isWatchedInSector(sector, stock.ticker)) return;

    final clampedIndex = index.clamp(0, _watchlists[sector]!.length);
    _watchlists[sector]!.insert(clampedIndex, stock);

    notifyListeners();
    _syncToFirestore();
  }

  void removeStock(String sector, String ticker) {
    _watchlists[sector]?.removeWhere((s) => _matchesStock(s, ticker));
    notifyListeners();
    _syncToFirestore();
  }

  void toggleWatchlist(Stock stock) {
    String? foundSector;

    for (final entry in _watchlists.entries) {
      if (entry.value.any((s) => _matchesStock(s, stock.ticker))) {
        foundSector = entry.key;
        break;
      }
    }

    if (foundSector != null) {
      removeStock(foundSector, stock.ticker);
    } else {
      final targetSector = _mapSector(stock.sector);
      addStock(targetSector, stock);
    }
  }

  String _mapSector(String stockSector) {
    final s = stockSector.toLowerCase();

    if (s.contains('tech') ||
        s.contains('tele') ||
        s.contains('comm') ||
        s.contains('indus')) {
      return 'Technology';
    } else if (s.contains('fin') || s.contains('keu')) {
      return 'Finance';
    } else if (s.contains('health') || s.contains('kes')) {
      return 'Healthcare';
    }

    return 'Technology';
  }

  bool _matchesStock(Stock stock, String tickerOrSymbol) {
    final target = _normalizeStockId(tickerOrSymbol);
    return _normalizeStockId(stock.ticker) == target ||
        _normalizeStockId(stock.symbol) == target;
  }

  String _normalizeStockId(String value) {
    var normalized = value.trim().toUpperCase();
    if (normalized.endsWith('.JK')) {
      normalized = normalized.substring(0, normalized.length - 3);
    }
    return normalized.replaceAll('.', '-');
  }

  Stock? _resolveStock(String ticker) {
    final target = _normalizeStockId(ticker);

    final allAppStocks = [
      ...AppData.popularStocks,
      ...AppData.watchlistTech,
      ...AppData.watchlistFinance,
      ...AppData.watchlistHealth,
    ];

    for (final s in allAppStocks) {
      if (_matchesStock(s, ticker)) return s;
    }

    const globalMeta = [
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

    const idxMeta = [
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

    for (final meta in globalMeta) {
      final t = meta.symbol.replaceAll('.JK', '');
      if (_normalizeStockId(t) == target) {
        return Stock(
          ticker: t,
          symbol: meta.symbol,
          name: meta.name,
          price: 0,
          changePercent: 0,
          peRatio: meta.peRatio,
          roe: meta.roe,
          sector: meta.sector,
          color: meta.color,
        );
      }
    }

    for (final meta in idxMeta) {
      final t = meta.symbol.replaceAll('.JK', '');
      if (_normalizeStockId(t) == target) {
        return Stock(
          ticker: t,
          symbol: meta.symbol,
          name: meta.name,
          price: 0,
          changePercent: 0,
          peRatio: meta.peRatio,
          roe: meta.roe,
          sector: meta.sector,
          color: meta.color,
        );
      }
    }

    return null;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _firestoreSubscription?.cancel();
    super.dispose();
  }
}

class _SM {
  final String symbol;
  final String name;
  final double peRatio;
  final double roe;
  final String sector;
  final Color color;
  const _SM(
    this.symbol,
    this.name,
    this.peRatio,
    this.roe,
    this.sector,
    this.color,
  );
}
