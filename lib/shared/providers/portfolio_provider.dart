import 'package:flutter/material.dart';
import '../../core/dummy_data/app_data.dart';

class PortfolioProvider extends ChangeNotifier {
  double _balance = AppData.initialBalance;
  final List<OwnedStock> _holdings = [];
  final List<Transaction> _transactions = [];

  double get balance => _balance;
  List<OwnedStock> get holdings => List.unmodifiable(_holdings);
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  double get totalInvested => _holdings.fold(0.0, (sum, h) => sum + h.costBasis);
  double get portfolioValue => _holdings.fold(0.0, (sum, h) => sum + h.currentValue);
  double get portfolioReturn => portfolioValue - totalInvested;
  double get portfolioReturnPercent =>
      totalInvested == 0 ? 0.0 : (portfolioReturn / totalInvested) * 100;

  void buyStock(Stock stock, int shares, double price) {
    final total = shares * price;
    if (total > _balance) throw Exception('Insufficient balance');

    _balance -= total;

    final idx = _holdings.indexWhere((h) => h.stock.ticker == stock.ticker);
    if (idx >= 0) {
      final existing = _holdings[idx];
      final newShares = existing.shares + shares;
      final newAvgPrice = (existing.costBasis + total) / newShares;
      _holdings[idx] = OwnedStock(
        stock: stock,
        shares: newShares,
        avgPrice: newAvgPrice,
      );
    } else {
      _holdings.add(OwnedStock(stock: stock, shares: shares, avgPrice: price));
    }

    _transactions.add(Transaction(
      stock: stock,
      shares: shares,
      price: price,
      total: total,
      timestamp: DateTime.now(),
    ));

    notifyListeners();
  }
}
