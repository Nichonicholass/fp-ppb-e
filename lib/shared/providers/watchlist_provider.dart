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

}
