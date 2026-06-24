import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/dummy_data/app_data.dart';
import '../../core/services/market_service.dart';

enum WatchlistSort {
  custom,
  ticker,
  name,
  price,
  change,
  peRatio,
  roe,
  dateAdded,
}

enum WatchlistFilter { all, gainers, losers, pinned }

class WatchlistItem {
  final Stock stock;
  final DateTime addedAt;
  final bool pinned;
  final int sortOrder;

  const WatchlistItem({
    required this.stock,
    required this.addedAt,
    required this.pinned,
    required this.sortOrder,
  });

  WatchlistItem copyWith({
    Stock? stock,
    DateTime? addedAt,
    bool? pinned,
    int? sortOrder,
  }) {
    return WatchlistItem(
      stock: stock ?? this.stock,
      addedAt: addedAt ?? this.addedAt,
      pinned: pinned ?? this.pinned,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class WatchlistGroup {
  final String id;
  final String name;
  final int sortOrder;
  final List<WatchlistItem> items;

  const WatchlistGroup({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.items,
  });

  WatchlistGroup copyWith({
    String? id,
    String? name,
    int? sortOrder,
    List<WatchlistItem>? items,
  }) {
    return WatchlistGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      sortOrder: sortOrder ?? this.sortOrder,
      items: items ?? this.items,
    );
  }
}

class WatchlistProvider extends ChangeNotifier {
  static const int _schemaVersion = 2;
  static const List<String> _defaultListNames = [
    'Technology',
    'Finance',
    'Healthcare',
  ];
  final bool _enablePersistence;
  final bool _fetchPricesOnCreate;
  final _service = MarketService();

  List<WatchlistGroup> _lists = _defaultLists();
  StreamSubscription? _authSubscription;
  StreamSubscription? _firestoreSubscription;

  WatchlistProvider({
    bool enablePersistence = true,
    bool fetchPricesOnCreate = true,
  })  : _enablePersistence = enablePersistence,
        _fetchPricesOnCreate = fetchPricesOnCreate {
    if (_enablePersistence) {
      _initAuthListener();
    }
    if (_fetchPricesOnCreate) {
      fetchWatchlistPrices();
    }
  }

  List<WatchlistGroup> get lists =>
      List.unmodifiable(_sortedLists().map(_unmodifiableGroup));

  List<String> get sectors => lists.map((list) => list.name).toList();

  List<Stock> getStocks(String listIdOrName) {
    final list = _findList(listIdOrName);
    if (list == null) return const [];
    return List.unmodifiable(
      _sortedItems(list.items).map((item) => item.stock),
    );
  }

  List<WatchlistItem> getSortedFilteredStocks(
    String listIdOrName, {
    WatchlistSort sort = WatchlistSort.custom,
    WatchlistFilter filter = WatchlistFilter.all,
  }) {
    final list = _findList(listIdOrName);
    if (list == null) return const [];

    final filtered = list.items.where((item) {
      switch (filter) {
        case WatchlistFilter.all:
          return true;
        case WatchlistFilter.gainers:
          return item.stock.changePercent > 0;
        case WatchlistFilter.losers:
          return item.stock.changePercent < 0;
        case WatchlistFilter.pinned:
          return item.pinned;
      }
    }).toList();

    filtered.sort((a, b) => _compareItems(a, b, sort));
    return List.unmodifiable(filtered);
  }

  bool canEditList(String listIdOrName) {
    final list = _findList(listIdOrName);
    return list != null;
  }

  bool canDeleteList(String listIdOrName) => canEditList(listIdOrName);

  bool isWatched(String ticker) =>
      _lists.any((list) => list.items.any((item) => _matchesStock(item.stock, ticker)));

  bool isWatchedInSector(String listIdOrName, String ticker) {
    final list = _findList(listIdOrName);
    return list?.items.any((item) => _matchesStock(item.stock, ticker)) ?? false;
  }

  String createList(String name) {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      if (_lists.isNotEmpty) return _sortedLists().first.id;
      return createList('Watchlist');
    }

    final existing = _lists.where(
      (list) => list.name.toLowerCase() == cleanName.toLowerCase(),
    );
    if (existing.isNotEmpty) return existing.first.id;

    final id = _uniqueListId(cleanName);
    _lists.add(
      WatchlistGroup(
        id: id,
        name: cleanName,
        sortOrder: _nextListSortOrder(),
        items: const [],
      ),
    );
    _renumberLists();
    notifyListeners();
    _syncToFirestore();
    return id;
  }

  void renameList(String listIdOrName, String name) {
    final index = _indexOfList(listIdOrName);
    final cleanName = name.trim();
    if (index == -1 || cleanName.isEmpty || !canEditList(listIdOrName)) return;

    final duplicate = _lists.any(
      (list) =>
          list.id != _lists[index].id &&
          list.name.toLowerCase() == cleanName.toLowerCase(),
    );
    if (duplicate) return;

    _lists[index] = _lists[index].copyWith(name: cleanName);
    notifyListeners();
    _syncToFirestore();
  }

  void deleteList(String listIdOrName) {
    if (!canDeleteList(listIdOrName)) return;
    _lists.removeWhere((list) => _matchesList(list, listIdOrName));
    _renumberLists();
    notifyListeners();
    _syncToFirestore();
  }

  void reorderList(String listIdOrName, int newIndex) {
    final oldIndex = _sortedLists().indexWhere(
      (list) => _matchesList(list, listIdOrName),
    );
    if (oldIndex == -1) return;

    final sorted = _sortedLists();
    final item = sorted.removeAt(oldIndex);
    final clampedIndex = newIndex.clamp(0, sorted.length);
    sorted.insert(clampedIndex, item);
    _lists = sorted
        .asMap()
        .entries
        .map((entry) => entry.value.copyWith(sortOrder: entry.key))
        .toList();

    notifyListeners();
    _syncToFirestore();
  }

  void addStock(String listIdOrName, Stock stock) {
    final listIndex = _ensureList(listIdOrName);
    if (isWatchedInSector(_lists[listIndex].id, stock.ticker)) return;

    final items = List<WatchlistItem>.from(_lists[listIndex].items)
      ..add(
        WatchlistItem(
          stock: stock,
          addedAt: DateTime.now(),
          pinned: false,
          sortOrder: _nextItemSortOrder(_lists[listIndex].items),
        ),
      );
    _lists[listIndex] = _lists[listIndex].copyWith(items: items);

    notifyListeners();
    _syncToFirestore();
  }

  void insertStock(String listIdOrName, int index, Stock stock) {
    final listIndex = _ensureList(listIdOrName);
    if (isWatchedInSector(_lists[listIndex].id, stock.ticker)) return;

    final items = _sortedItems(_lists[listIndex].items);
    final clampedIndex = index.clamp(0, items.length);
    items.insert(
      clampedIndex,
      WatchlistItem(
        stock: stock,
        addedAt: DateTime.now(),
        pinned: false,
        sortOrder: clampedIndex,
      ),
    );
    _lists[listIndex] = _lists[listIndex].copyWith(
      items: _renumberItems(items),
    );

    notifyListeners();
    _syncToFirestore();
  }

  void removeStock(String listIdOrName, String ticker) {
    final listIndex = _indexOfList(listIdOrName);
    if (listIndex == -1) return;

    final items = List<WatchlistItem>.from(_lists[listIndex].items)
      ..removeWhere((item) => _matchesStock(item.stock, ticker));
    _lists[listIndex] = _lists[listIndex].copyWith(
      items: _renumberItems(items),
    );

    notifyListeners();
    _syncToFirestore();
  }

  void togglePinned(String listIdOrName, String ticker) {
    final listIndex = _indexOfList(listIdOrName);
    if (listIndex == -1) return;

    final items = _lists[listIndex].items.map((item) {
      if (!_matchesStock(item.stock, ticker)) return item;
      return item.copyWith(pinned: !item.pinned);
    }).toList();

    _lists[listIndex] = _lists[listIndex].copyWith(items: items);
    notifyListeners();
    _syncToFirestore();
  }

  void reorderItem(String listIdOrName, int oldIndex, int newIndex) {
    final listIndex = _indexOfList(listIdOrName);
    if (listIndex == -1) return;

    final items = _sortedItems(_lists[listIndex].items);
    if (oldIndex < 0 || oldIndex >= items.length) return;

    final adjustedIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final item = items.removeAt(oldIndex);
    items.insert(adjustedIndex.clamp(0, items.length), item);

    _lists[listIndex] = _lists[listIndex].copyWith(
      items: _renumberItems(items),
    );
    notifyListeners();
    _syncToFirestore();
  }

  void toggleWatchlist(Stock stock) {
    String? foundListId;

    for (final list in _lists) {
      if (list.items.any((item) => _matchesStock(item.stock, stock.ticker))) {
        foundListId = list.id;
        break;
      }
    }

    if (foundListId != null) {
      removeStock(foundListId, stock.ticker);
    } else {
      addStock(_mapSector(stock.sector), stock);
    }
  }

  Future<void> fetchWatchlistPrices() async {
    final symbolsToFetch = <String>[];
    for (final list in _lists) {
      for (final item in list.items) {
        if (!symbolsToFetch.contains(item.stock.symbol)) {
          symbolsToFetch.add(item.stock.symbol);
        }
      }
    }

    if (symbolsToFetch.isEmpty) return;

    try {
      final quotes = await _service.fetchQuotes(symbolsToFetch);
      bool updatedAny = false;

      _lists = _lists.map((list) {
        final updatedItems = list.items.map((item) {
          final quote = quotes[item.stock.symbol];
          if (quote == null) return item;
          updatedAny = true;
          return item.copyWith(
            stock: Stock(
              ticker: item.stock.ticker,
              symbol: item.stock.symbol,
              name: item.stock.name,
              price: quote.price,
              changePercent: quote.changePercent,
              peRatio: item.stock.peRatio,
              roe: item.stock.roe,
              sector: item.stock.sector,
              color: item.stock.color,
            ),
          );
        }).toList();
        return list.copyWith(items: updatedItems);
      }).toList();

      if (updatedAny) {
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching watchlist prices: $e');
    }
  }

  @visibleForTesting
  void loadFromFirestoreData(Map<String, dynamic> data) {
    final parsed = _parseFirestoreData(data);
    _lists = parsed.lists;
    notifyListeners();
    if (parsed.needsSync) _syncToFirestore();
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
            final parsed = _parseFirestoreData(snapshot.data()!);
            _lists = parsed.lists;

            notifyListeners();
            fetchWatchlistPrices();
            if (parsed.needsSync) _syncToFirestore();
          } else {
            _syncToFirestore();
          }
        }, onError: (err) {
          debugPrint('Firestore Watchlist error: $err');
        });
      } else {
        _lists = _defaultLists();
        notifyListeners();
        fetchWatchlistPrices();
      }
    });
  }

  void _syncToFirestore() {
    if (!_enablePersistence) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('watchlists')
        .doc(user.uid)
        .set(_toFirestoreData())
        .catchError((err) {
      debugPrint('Error syncing watchlist to Firestore: $err');
    });
  }

  Map<String, dynamic> _toFirestoreData() {
    final sorted = _sortedLists();
    return {
      'version': _schemaVersion,
      'lists': sorted.map((list) {
        return {
          'id': list.id,
          'name': list.name,
          'sortOrder': list.sortOrder,
          'items': _sortedItems(list.items).map((item) {
            return {
              'ticker': item.stock.ticker,
              'symbol': item.stock.symbol,
              'addedAt': Timestamp.fromDate(item.addedAt),
              'pinned': item.pinned,
              'sortOrder': item.sortOrder,
            };
          }).toList(),
        };
      }).toList(),
    };
  }

  _ParsedWatchlist _parseFirestoreData(Map<String, dynamic> data) {
    final listsData = data['lists'];
    if (data['version'] == _schemaVersion && listsData is List) {
      final parsedLists = listsData
          .whereType<Map>()
          .map((raw) => _parseVersionedList(Map<String, dynamic>.from(raw)))
          .whereType<WatchlistGroup>()
          .toList();

      final lists = _mergeMissingDefaultLists(parsedLists);
      return _ParsedWatchlist(_renumberListObjects(lists), parsedLists.length != lists.length);
    }

    return _ParsedWatchlist(_parseLegacyLists(data), true);
  }

  WatchlistGroup? _parseVersionedList(Map<String, dynamic> raw) {
    final id = (raw['id'] as String?)?.trim();
    final name = (raw['name'] as String?)?.trim();
    if (id == null || id.isEmpty || name == null || name.isEmpty) return null;

    final rawItems = raw['items'];
    final items = <WatchlistItem>[];
    if (rawItems is List) {
      for (final rawItem in rawItems) {
        if (rawItem is! Map) continue;
        final item = _parseVersionedItem(Map<String, dynamic>.from(rawItem));
        if (item != null) items.add(item);
      }
    }

    return WatchlistGroup(
      id: _slugify(id),
      name: name,
      sortOrder: _readInt(raw['sortOrder'], 0),
      items: _renumberItems(_sortedItems(items)),
    );
  }

  WatchlistItem? _parseVersionedItem(Map<String, dynamic> raw) {
    final symbol = (raw['symbol'] ?? raw['ticker'])?.toString();
    if (symbol == null || symbol.trim().isEmpty) return null;

    final stock = _resolveStock(symbol);
    if (stock == null) return null;

    return WatchlistItem(
      stock: stock,
      addedAt: _readDateTime(raw['addedAt']),
      pinned: raw['pinned'] == true,
      sortOrder: _readInt(raw['sortOrder'], 0),
    );
  }

  List<WatchlistGroup> _parseLegacyLists(Map<String, dynamic> data) {
    final lists = <WatchlistGroup>[];
    for (int i = 0; i < _defaultListNames.length; i++) {
      final name = _defaultListNames[i];
      final tickers = data[name] is List ? data[name] as List : const [];
      final items = <WatchlistItem>[];

      for (int j = 0; j < tickers.length; j++) {
        final stock = _resolveStock(tickers[j].toString());
        if (stock == null) continue;
        items.add(
          WatchlistItem(
            stock: stock,
            addedAt: DateTime.now(),
            pinned: false,
            sortOrder: j,
          ),
        );
      }

      lists.add(
        WatchlistGroup(
          id: _slugify(name),
          name: name,
          sortOrder: i,
          items: items,
        ),
      );
    }
    return lists;
  }

  static List<WatchlistGroup> _defaultLists() {
    return [];
  }

  List<WatchlistGroup> _mergeMissingDefaultLists(List<WatchlistGroup> parsed) {
    return List<WatchlistGroup>.from(parsed);
  }

  int _ensureList(String listIdOrName) {
    final existing = _indexOfList(listIdOrName);
    if (existing != -1) return existing;

    final id = createList(listIdOrName);
    return _indexOfList(id);
  }

  int _indexOfList(String listIdOrName) =>
      _lists.indexWhere((list) => _matchesList(list, listIdOrName));

  WatchlistGroup? _findList(String listIdOrName) {
    for (final list in _lists) {
      if (_matchesList(list, listIdOrName)) return list;
    }
    return null;
  }

  bool _matchesList(WatchlistGroup list, String listIdOrName) {
    final target = _slugify(listIdOrName);
    return list.id == target || _slugify(list.name) == target;
  }

  List<WatchlistGroup> _sortedLists() {
    final sorted = List<WatchlistGroup>.from(_lists);
    sorted.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return sorted;
  }

  List<WatchlistItem> _sortedItems(List<WatchlistItem> items) {
    final sorted = List<WatchlistItem>.from(items);
    sorted.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return sorted;
  }

  WatchlistGroup _unmodifiableGroup(WatchlistGroup list) {
    return list.copyWith(items: List.unmodifiable(list.items));
  }

  int _compareItems(WatchlistItem a, WatchlistItem b, WatchlistSort sort) {
    if (a.pinned != b.pinned) return a.pinned ? -1 : 1;

    switch (sort) {
      case WatchlistSort.custom:
        return a.sortOrder.compareTo(b.sortOrder);
      case WatchlistSort.ticker:
        return a.stock.ticker.compareTo(b.stock.ticker);
      case WatchlistSort.name:
        return a.stock.name.compareTo(b.stock.name);
      case WatchlistSort.price:
        return b.stock.price.compareTo(a.stock.price);
      case WatchlistSort.change:
        return b.stock.changePercent.compareTo(a.stock.changePercent);
      case WatchlistSort.peRatio:
        return b.stock.peRatio.compareTo(a.stock.peRatio);
      case WatchlistSort.roe:
        return b.stock.roe.compareTo(a.stock.roe);
      case WatchlistSort.dateAdded:
        return b.addedAt.compareTo(a.addedAt);
    }
  }

  List<WatchlistItem> _renumberItems(List<WatchlistItem> items) {
    return items
        .asMap()
        .entries
        .map((entry) => entry.value.copyWith(sortOrder: entry.key))
        .toList();
  }

  void _renumberLists() {
    _lists = _renumberListObjects(_sortedLists());
  }

  List<WatchlistGroup> _renumberListObjects(List<WatchlistGroup> lists) {
    final sorted = List<WatchlistGroup>.from(lists)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return sorted
        .asMap()
        .entries
        .map((entry) => entry.value.copyWith(sortOrder: entry.key))
        .toList();
  }

  int _nextListSortOrder([List<WatchlistGroup>? lists]) {
    final source = lists ?? _lists;
    if (source.isEmpty) return 0;
    return source.map((list) => list.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
  }

  int _nextItemSortOrder(List<WatchlistItem> items) {
    if (items.isEmpty) return 0;
    return items.map((item) => item.sortOrder).reduce((a, b) => a > b ? a : b) + 1;
  }

  String _uniqueListId(String name) {
    final base = _slugify(name);
    var candidate = base;
    var i = 2;
    while (_lists.any((list) => list.id == candidate)) {
      candidate = '$base-$i';
      i++;
    }
    return candidate;
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

  DateTime _readDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  int _readInt(Object? value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback;
  }

  String _slugify(String value) => _slugifyStatic(value);

  static String _slugifyStatic(String value) {
    final slug = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    return slug.isEmpty ? 'watchlist' : slug;
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

class _ParsedWatchlist {
  final List<WatchlistGroup> lists;
  final bool needsSync;

  const _ParsedWatchlist(this.lists, this.needsSync);
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
