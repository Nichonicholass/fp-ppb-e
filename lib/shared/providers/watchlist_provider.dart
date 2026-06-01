import 'package:flutter/material.dart';
import '../../core/dummy_data/app_data.dart';

class WatchlistProvider extends ChangeNotifier {
  
  final Map<String, List<Stock>> _watchlists = {
    'Technology': List<Stock>.from(AppData.watchlistTech),
    'Finance': List<Stock>.from(AppData.watchlistFinance),
    'Healthcare': List<Stock>.from(AppData.watchlistHealth),
  };
  
  List<String> get sectors => _watchlists.keys.toList();

  List<Stock> getStocks(String sector) =>
      List.unmodifiable(_watchlists[sector] ?? []);

  bool isWatched(String ticker) =>
      _watchlists.values.any((list) => list.any((s) => s.ticker == ticker));

  bool isWatchedInSector(String sector, String ticker) =>
      (_watchlists[sector] ?? []).any((s) => s.ticker == ticker);

  void addStock(String sector, Stock stock) {

    if (!_watchlists.containsKey(sector)) {
      _watchlists[sector] = [];
    }

    if (isWatchedInSector(sector, stock.ticker)) return;

    _watchlists[sector]!.add(stock);
    notifyListeners();

  }

  void insertStock(String sector, int index, Stock stock) {

    if (!_watchlists.containsKey(sector)) {
      _watchlists[sector] = [];
    }

    if (isWatchedInSector(sector, stock.ticker)) return;

    final clampedIndex = index.clamp(0, _watchlists[sector]!.length);
    _watchlists[sector]!.insert(clampedIndex, stock);

    notifyListeners();

  }

  void removeStock(String sector, String ticker) {
    _watchlists[sector]?.removeWhere((s) => s.ticker == ticker);
    notifyListeners();
  }

  void toggleWatchlist(Stock stock) {
  
    String? foundSector;
  
    for (final entry in _watchlists.entries) {
  
      if (entry.value.any((s) => s.ticker == stock.ticker)) {
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
  
    if (s.contains('tech') || s.contains('tele') || s.contains('comm') || s.contains('indus')) {
      return 'Technology';
  
    } else if (s.contains('fin') || s.contains('keu')) {
      return 'Finance';
  
    } else if (s.contains('health') || s.contains('kes')) {
      return 'Healthcare';
    }
  
    return 'Technology';
  
  }

}

