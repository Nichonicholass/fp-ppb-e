import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../../core/dummy_data/app_data.dart';

class PortfolioProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSub;

  String? _userId;
  bool _loading = false;
  double _balance = AppData.initialBalance;
  final List<OwnedStock> _holdings = [];
  final List<Transaction> _transactions = [];

  bool get loading => _loading;
  double get balance => _balance;
  List<OwnedStock> get holdings => List.unmodifiable(_holdings);
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  double get totalInvested => _holdings.fold(0.0, (acc, h) => acc + h.costBasis);
  double get portfolioValue => _holdings.fold(0.0, (acc, h) => acc + h.currentValue);
  double get portfolioReturn => portfolioValue - totalInvested;
  double get portfolioReturnPercent =>
      totalInvested == 0 ? 0.0 : (portfolioReturn / totalInvested) * 100;

  PortfolioProvider() {
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        _userId = user.uid;
        _loadFromFirestore();
      } else {
        _userId = null;
        _reset();
      }
    });
  }

  void _reset() {
    _balance = AppData.initialBalance;
    _holdings.clear();
    _transactions.clear();
    _loading = false;
    notifyListeners();
  }

  Future<void> _loadFromFirestore() async {
    if (_userId == null) return;
    _loading = true;
    notifyListeners();

    try {
      final doc = await _db
          .collection('users')
          .doc(_userId)
          .collection('portfolio')
          .doc('data')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _balance = (data['balance'] as num).toDouble();

        _holdings.clear();
        for (final h in (data['holdings'] as List<dynamic>? ?? [])) {
          _holdings.add(_holdingFromMap(h as Map<String, dynamic>));
        }

        _transactions.clear();
        for (final t in (data['transactions'] as List<dynamic>? ?? [])) {
          _transactions.add(_transactionFromMap(t as Map<String, dynamic>));
        }
      }
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToFirestore() async {
    if (_userId == null) return;
    await _db
        .collection('users')
        .doc(_userId)
        .collection('portfolio')
        .doc('data')
        .set({
      'balance': _balance,
      'holdings': _holdings.map(_holdingToMap).toList(),
      'transactions': _transactions.map(_transactionToMap).toList(),
    });
  }

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
    _saveToFirestore();
  }

  // --- Serialization helpers ---

  Map<String, dynamic> _holdingToMap(OwnedStock h) => {
        'ticker': h.stock.ticker,
        'symbol': h.stock.symbol,
        'name': h.stock.name,
        'price': h.stock.price,
        'changePercent': h.stock.changePercent,
        'peRatio': h.stock.peRatio,
        'roe': h.stock.roe,
        'sector': h.stock.sector,
        'colorValue': h.stock.color.toARGB32(),
        'shares': h.shares,
        'avgPrice': h.avgPrice,
      };

  OwnedStock _holdingFromMap(Map<String, dynamic> m) => OwnedStock(
        stock: Stock(
          ticker: m['ticker'] as String,
          symbol: m['symbol'] as String,
          name: m['name'] as String,
          price: (m['price'] as num).toDouble(),
          changePercent: (m['changePercent'] as num).toDouble(),
          peRatio: (m['peRatio'] as num).toDouble(),
          roe: (m['roe'] as num).toDouble(),
          sector: m['sector'] as String,
          color: Color(m['colorValue'] as int),
        ),
        shares: m['shares'] as int,
        avgPrice: (m['avgPrice'] as num).toDouble(),
      );

  Map<String, dynamic> _transactionToMap(Transaction t) => {
        'ticker': t.stock.ticker,
        'symbol': t.stock.symbol,
        'name': t.stock.name,
        'price': t.stock.price,
        'changePercent': t.stock.changePercent,
        'peRatio': t.stock.peRatio,
        'roe': t.stock.roe,
        'sector': t.stock.sector,
        'colorValue': t.stock.color.toARGB32(),
        'shares': t.shares,
        'transactionPrice': t.price,
        'total': t.total,
        'timestamp': t.timestamp.toIso8601String(),
      };

  Transaction _transactionFromMap(Map<String, dynamic> m) => Transaction(
        stock: Stock(
          ticker: m['ticker'] as String,
          symbol: m['symbol'] as String,
          name: m['name'] as String,
          price: (m['price'] as num).toDouble(),
          changePercent: (m['changePercent'] as num).toDouble(),
          peRatio: (m['peRatio'] as num).toDouble(),
          roe: (m['roe'] as num).toDouble(),
          sector: m['sector'] as String,
          color: Color(m['colorValue'] as int),
        ),
        shares: m['shares'] as int,
        price: (m['transactionPrice'] as num).toDouble(),
        total: (m['total'] as num).toDouble(),
        timestamp: DateTime.parse(m['timestamp'] as String),
      );

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}
