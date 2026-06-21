import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../../core/dummy_data/app_data.dart';
import '../../core/services/notification_service.dart';

class PortfolioProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSub;

  String? _userId;
  bool _loading = false;
  double _balance = AppData.initialBalance;
  bool _todayRewardClaimed = false;
  final Set<String> _completedModuleIds = {};
  final List<OwnedStock> _holdings = [];
  final List<Transaction> _transactions = [];

  bool get loading => _loading;
  double get balance => _balance;
  bool get todayRewardClaimed => _todayRewardClaimed;
  Set<String> get completedModuleIds => _completedModuleIds;
  List<OwnedStock> get holdings => List.unmodifiable(_holdings);
  List<Transaction> get transactions => List.unmodifiable(_transactions);

  bool isModuleCompleted(String moduleId) => _completedModuleIds.contains(moduleId);

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
    _completedModuleIds.clear();
    _todayRewardClaimed = false;
    _loading = false;
    notifyListeners();
  }

  Future<void> _loadFromFirestore() async {
    if (_userId == null) return;
    _loading = true;
    notifyListeners();

    try {
      final doc = await _db
          .collection('portfolio')
          .doc(_userId)
          .get();

      // Load all completed quizzes
      final rewardsSnap = await _db
          .collection('quiz_rewards')
          .where('userId', isEqualTo: _userId)
          .get();
      _completedModuleIds.clear();
      for (final doc in rewardsSnap.docs) {
        final moduleId = doc.data()['moduleId'] as String?;
        if (moduleId != null) _completedModuleIds.add(moduleId);
      }

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

  Future<void> checkTodayRewardClaimed() async {
    if (_userId == null) return;
    try {
      final rewardsSnap = await _db
          .collection('quiz_rewards')
          .where('userId', isEqualTo: _userId)
          .get();
      _completedModuleIds.clear();
      for (final doc in rewardsSnap.docs) {
        final moduleId = doc.data()['moduleId'] as String?;
        if (moduleId != null) _completedModuleIds.add(moduleId);
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _saveToFirestore() async {
    if (_userId == null) return;
    await _db
        .collection('portfolio')
        .doc(_userId)
        .set({
      'userId': _userId,
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
      type: TransactionType.buy,
    ));

    notifyListeners();
    _saveToFirestore();
    
    NotificationService().showTransactionSuccess(
      type: 'buy',
      stockTicker: stock.ticker,
      shares: shares,
      totalAmount: total,
    );
  }

  void sellStock(Stock stock, int shares, double price) {
    final idx = _holdings.indexWhere((h) => h.stock.ticker == stock.ticker);
    if (idx < 0) throw Exception('Holding not found');

    final existing = _holdings[idx];
    if (shares > existing.shares) throw Exception('Not enough shares');

    final proceeds = shares * price;
    _balance += proceeds;

    if (shares == existing.shares) {
      _holdings.removeAt(idx);
    } else {
      _holdings[idx] = OwnedStock(
        stock: existing.stock,
        shares: existing.shares - shares,
        avgPrice: existing.avgPrice,
      );
    }

    _transactions.add(Transaction(
      stock: stock,
      shares: shares,
      price: price,
      total: proceeds,
      timestamp: DateTime.now(),
      type: TransactionType.sell,
    ));

    notifyListeners();
    _saveToFirestore();
    
    NotificationService().showTransactionSuccess(
      type: 'sell',
      stockTicker: stock.ticker,
      shares: shares,
      totalAmount: proceeds,
    );
  }

  Future<bool> claimQuizReward({
    required String sessionId,
    required int score,
    required int totalQuestions,
    double rewardPerCorrect = 100,
  }) async {
    return claimModuleReward(
      moduleId: sessionId,
      score: score,
      totalQuestions: totalQuestions,
      rewardPerCorrect: rewardPerCorrect,
    );
  }

  Future<bool> claimModuleReward({
    required String moduleId,
    required int score,
    required int totalQuestions,
    double rewardPerCorrect = 100,
  }) async {
    final userId = _userId;
    if (userId == null) {
      throw Exception('Please sign in to claim quiz rewards.');
    }
    if (totalQuestions <= 0) {
      throw Exception('Quiz has no questions.');
    }

    final normalizedScore = score.clamp(0, totalQuestions).toInt();
    final rewardAmount = normalizedScore * rewardPerCorrect;
    if (rewardAmount <= 0) return false;

    final safeModuleId = moduleId.replaceAll('/', '_');
    
    // Check if already claimed using query to avoid permission denied on non-existent doc
    final existingQuery = await _db
        .collection('quiz_rewards')
        .where('userId', isEqualTo: userId)
        .where('moduleId', isEqualTo: moduleId)
        .get();
        
    if (existingQuery.docs.isNotEmpty) {
      return false;
    }

    final rewardRef = _db
        .collection('quiz_rewards')
        .doc('${userId}_$safeModuleId');
    final portfolioRef = _db
        .collection('portfolio')
        .doc(userId);

    final result = await _db.runTransaction((tx) async {
      final portfolioSnap = await tx.get(portfolioRef);
      final currentBalance = portfolioSnap.exists
          ? ((portfolioSnap.data()?['balance'] as num?)?.toDouble() ??
              AppData.initialBalance)
          : AppData.initialBalance;
      final newBalance = currentBalance + rewardAmount;

      tx.set(
        portfolioRef,
        {
          'userId': userId,
          'balance': newBalance,
          if (!portfolioSnap.exists) 'holdings': <Map<String, dynamic>>[],
          if (!portfolioSnap.exists) 'transactions': <Map<String, dynamic>>[],
        },
        SetOptions(merge: true),
      );
      tx.set(rewardRef, {
        'userId': userId,
        'moduleId': moduleId,
        'claimedAt': FieldValue.serverTimestamp(),
        'score': normalizedScore,
        'totalQuestions': totalQuestions,
        'rewardAmount': rewardAmount,
      });

      return _QuizRewardTransactionResult(
        claimed: true,
        balance: newBalance,
      );
    }) as _QuizRewardTransactionResult;

    if (result.claimed) {
      _balance = result.balance;
      _completedModuleIds.add(moduleId);
      notifyListeners();
    }

    return result.claimed;
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
        'type': t.type.name,
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
        type: TransactionType.values.byName((m['type'] as String?) ?? 'buy'),
      );

  /// Reconstructs portfolio value snapshots from [since] to now.
  /// Returns raw dollar values: [value_at_since, ...per_tx..., current_value].
  List<double> getTimelinePoints(DateTime since) {
    final sorted = List<Transaction>.from(_transactions)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    double bal = AppData.initialBalance;
    final Map<String, int> shareCount = {};
    final Map<String, double> avgPrices = {};

    void applyTx(Transaction tx) {
      if (tx.type == TransactionType.buy) {
        bal -= tx.total;
        final cur = shareCount[tx.stock.ticker] ?? 0;
        final curAvg = avgPrices[tx.stock.ticker] ?? 0.0;
        final newShares = cur + tx.shares;
        avgPrices[tx.stock.ticker] = (curAvg * cur + tx.total) / newShares;
        shareCount[tx.stock.ticker] = newShares;
      } else {
        bal += tx.total;
        final cur = shareCount[tx.stock.ticker] ?? 0;
        final remaining = cur - tx.shares;
        if (remaining <= 0) {
          shareCount.remove(tx.stock.ticker);
          avgPrices.remove(tx.stock.ticker);
        } else {
          shareCount[tx.stock.ticker] = remaining;
        }
      }
    }

    double holdingsVal() {
      double v = 0;
      for (final ticker in shareCount.keys) {
        v += (avgPrices[ticker] ?? 0) * (shareCount[ticker] ?? 0);
      }
      return v;
    }

    for (final tx in sorted) {
      if (tx.timestamp.isBefore(since)) applyTx(tx);
    }

    final values = <double>[bal + holdingsVal()];

    for (final tx in sorted) {
      if (!tx.timestamp.isBefore(since)) {
        applyTx(tx);
        values.add(bal + holdingsVal());
      }
    }

    values.add(_balance + portfolioValue);
    return values;
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

class _QuizRewardTransactionResult {
  final bool claimed;
  final double balance;

  const _QuizRewardTransactionResult({
    required this.claimed,
    required this.balance,
  });
}
