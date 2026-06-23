import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/dummy_data/app_data.dart';
import '../../core/services/currency_service.dart';
import '../../shared/providers/portfolio_provider.dart';
import '../../shared/providers/market_provider.dart';
import 'transaction_detail_page.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  bool _showIdr = false; // false = USD, true = IDR

  @override
  Widget build(BuildContext context) {
    final rate = CurrencyService.currentRate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
        actions: [
          // Currency Toggle
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () => setState(() => _showIdr = !_showIdr),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _showIdr
                      ? const Color(0xFFFEF3C7)
                      : AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _showIdr
                        ? const Color(0xFFD97706)
                        : AppTheme.primary,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _showIdr ? 'IDR' : 'USD',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _showIdr
                            ? const Color(0xFFD97706)
                            : AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.swap_horiz_rounded,
                      size: 14,
                      color: _showIdr
                          ? const Color(0xFFD97706)
                          : AppTheme.primary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BalanceCard(showIdr: _showIdr, rate: rate),
            const SizedBox(height: 20),
            const _PerformanceChart(),
            const SizedBox(height: 24),
            Text(
              'My Holdings',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...context.watch<PortfolioProvider>().holdings.map(
              (s) => _HoldingTile(
                owned: s,
                showIdr: _showIdr,
                rate: rate,
                onSell: () => _showSellSheet(context, s),
              ),
            ),
            if (context.watch<PortfolioProvider>().holdings.isEmpty)
              const _EmptyHoldings(),
            const SizedBox(height: 24),
            _TransactionHistorySection(showIdr: _showIdr, rate: rate),
            const SizedBox(height: 24),
            // ── DEV ONLY: Crashlytics Test — Remove before production ──
            _CrashTestButton(),
            // ──────────────────────────────────────────────────────────
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final bool showIdr;
  final double rate;
  const _BalanceCard({required this.showIdr, required this.rate});

  String _fmt(double usdVal) {
    if (showIdr) {
      final idr = usdVal * rate;
      final s = idr.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
      return 'Rp $s';
    }
    return '\$${usdVal.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final portfolio = context.watch<PortfolioProvider>();
    final market = context.watch<MarketProvider>();

    final livePriceMap = {for (final s in market.stocks) s.ticker: s.price};
    final livePortfolioValue = portfolio.holdings.fold(0.0, (sum, h) {
      final price = livePriceMap[h.stock.ticker] ?? h.stock.price;
      return sum + price * h.shares;
    });
    final totalAccountValue = portfolio.balance + livePortfolioValue;
    final ret = totalAccountValue - AppData.initialBalance;
    final retPct = (ret / AppData.initialBalance) * 100;
    final isPositive = ret >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Virtual Portfolio Balance',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              // Currency label badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  showIdr ? 'IDR' : 'USD',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _fmt(portfolio.balance),
            style: GoogleFonts.inter(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _BalanceStat(
                label: 'Total Invested',
                value: _fmt(portfolio.totalInvested),
              ),
              Container(
                width: 1,
                height: 36,
                color: Colors.white.withValues(alpha: 0.3),
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              _BalanceStat(
                label: 'Total Return',
                value: '${isPositive ? '+' : ''}${_fmt(ret)}',
                badge: '${isPositive ? '+' : ''}${retPct.toStringAsFixed(2)}%',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BalanceStat extends StatelessWidget {
  final String label;
  final String value;
  final String? badge;

  const _BalanceStat({required this.label, required this.value, this.badge});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        if (badge != null) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              badge!,
              style: GoogleFonts.inter(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ],
    );
  }
}

class _PerformanceChart extends StatefulWidget {
  const _PerformanceChart();

  @override
  State<_PerformanceChart> createState() => _PerformanceChartState();
}

class _PerformanceChartState extends State<_PerformanceChart> {
  String _selected = '1M';

  @override
  Widget build(BuildContext context) {
    final portfolio = context.watch<PortfolioProvider>();
    final now = DateTime.now();

    DateTime since;
    if (_selected == '1W') {
      since = now.subtract(const Duration(days: 7));
    } else if (_selected == '3M') {
      since = DateTime(now.year, now.month - 3, now.day);
    } else if (_selected == '1Y') {
      since = DateTime(now.year - 1, now.month, now.day);
    } else {
      since = DateTime(now.year, now.month - 1, now.day);
    }

    final raw = portfolio.getTimelinePoints(since);
    final minV = raw.reduce((a, b) => a < b ? a : b);
    final maxV = raw.reduce((a, b) => a > b ? a : b);
    final range = maxV - minV;
    final normalized = range == 0
        ? List<double>.filled(raw.length, 0.5)
        : raw.map((v) => (v - minV) / range).toList();

    return Container(
      width: double.infinity,
      height: 185,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Performance',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const Spacer(),
              ...['1W', '1M', '3M', '1Y'].map(
                (t) => GestureDetector(
                  onTap: () => setState(() => _selected = t),
                  child: _TimeFilter(label: t, isSelected: t == _selected),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: CustomPaint(
              painter: _LineChartPainter(points: normalized),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeFilter extends StatelessWidget {
  final String label;
  final bool isSelected;
  const _TimeFilter({required this.label, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : AppTheme.textSecondary,
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> points;

  _LineChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final linePaint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [AppTheme.primary.withValues(alpha: 0.18), AppTheme.primary.withValues(alpha: 0.0)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final linePath = Path();
    final fillPath = Path();

    for (int i = 0; i < points.length; i++) {
      final x = (i / (points.length - 1)) * size.width;
      final y = size.height - (points[i] * size.height * 0.9) - size.height * 0.05;
      if (i == 0) {
        linePath.moveTo(x, y);
        fillPath.moveTo(x, y);
      } else {
        linePath.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);

    final lastX = size.width;
    final lastY = size.height - (points.last * size.height * 0.9) - size.height * 0.05;
    canvas.drawCircle(
      Offset(lastX, lastY),
      4,
      Paint()
        ..color = AppTheme.primary
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      Offset(lastX, lastY),
      4,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) => old.points != points;
}

class _HoldingTile extends StatelessWidget {
  final OwnedStock owned;
  final bool showIdr;
  final double rate;
  final VoidCallback? onSell;
  const _HoldingTile({
    required this.owned,
    required this.showIdr,
    required this.rate,
    this.onSell,
  });

  String _fmt(double usdVal) {
    if (showIdr) {
      final idr = usdVal * rate;
      final s = idr.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
      return 'Rp $s';
    }
    return '\$${usdVal.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketProvider>();
    final isIDX = owned.stock.symbol.endsWith('.JK');

    // Get live price (in native currency: IDR for IDX, USD for Global)
    double livePrice = market.stocks
        .firstWhere(
          (s) => s.ticker == owned.stock.ticker,
          orElse: () => owned.stock,
        )
        .price;

    // BUG FIX: IDX live price is in IDR, but avgPrice is stored in USD.
    // Convert live price to USD for consistent comparison.
    if (isIDX && livePrice > 0) {
      livePrice = CurrencyService.idrToUsd(livePrice);
    }

    final currentValue = livePrice * owned.shares;
    final gainLoss = (livePrice - owned.avgPrice) * owned.shares;
    final gainLossPercent = owned.avgPrice == 0
        ? 0.0
        : ((livePrice - owned.avgPrice) / owned.avgPrice) * 100;
    final isPositive = gainLoss >= 0;
    final tickerDisplay = owned.stock.ticker.length > 4
        ? owned.stock.ticker.substring(0, 4)
        : owned.stock.ticker;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: owned.stock.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                tickerDisplay,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: owned.stock.color,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  owned.stock.ticker,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${owned.shares} shares · avg ${_fmt(owned.avgPrice)}',
                  style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _fmt(currentValue),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${isPositive ? '+' : ''}${_fmt(gainLoss)} '
                '(${isPositive ? '+' : ''}${gainLossPercent.toStringAsFixed(2)}%)',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? AppTheme.positive : AppTheme.negative,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSell,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.negative.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Sell',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.negative,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHoldings extends StatelessWidget {
  const _EmptyHoldings();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.show_chart_rounded, size: 48, color: AppTheme.textSecondary),
          const SizedBox(height: 12),
          Text(
            'No holdings yet',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Go to Market and buy your first stock',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sell Sheet ────────────────────────────────────────────────────────────────

void _showSellSheet(BuildContext context, OwnedStock holding) {
  final portfolio = context.read<PortfolioProvider>();
  final market = context.read<MarketProvider>();
  final isIDX = holding.stock.symbol.endsWith('.JK');
  const int lotSize = 100; // 1 lot = 100 shares (IDX rule)

  // Use live price from market API; fall back to stored price if not loaded yet
  final liveStock = market.stocks.firstWhere(
    (s) => s.ticker == holding.stock.ticker,
    orElse: () => holding.stock,
  );
  final livePriceRaw = liveStock.price > 0 ? liveStock.price : holding.stock.price;

  // BUG FIX: IDX price from market is in IDR — must convert to USD for sell
  final livePriceUsd = isIDX
      ? CurrencyService.idrToUsd(livePriceRaw)
      : livePriceRaw;
  final rate = CurrencyService.currentRate;

  // For IDX: sell in lots (1 lot = 100 shares)
  final maxLots = isIDX ? (holding.shares ~/ lotSize) : holding.shares;
  int qty = 1; // lots for IDX, shares for global

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => StatefulBuilder(
      builder: (ctx, setSheetState) {
        final actualShares = isIDX ? qty * lotSize : qty;
        final proceedsUsd = actualShares * livePriceUsd;
        final proceedsIdr = proceedsUsd * rate;

        String fmtIdr(double v) {
          final s = v.toStringAsFixed(0).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
          return 'Rp $s';
        }

        // Price display: IDR for IDX stocks, USD for global
        final priceDisplay = isIDX
            ? fmtIdr(livePriceRaw)   // show IDR (native)
            : '\$${livePriceUsd.toStringAsFixed(2)}';

        final tickerDisplay = holding.stock.ticker.length > 4
            ? holding.stock.ticker.substring(0, 4)
            : holding.stock.ticker;

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            24, 20, 24,
            24 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: holding.stock.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        tickerDisplay,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: holding.stock.color,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          holding.stock.ticker,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          holding.stock.name,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Price display with conversion
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        priceDisplay,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (isIDX)
                        Text(
                          '≈ \$${livePriceUsd.toStringAsFixed(4)}',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Shares/Lots info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      isIDX ? 'Lot Dimiliki' : 'Shares Owned',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      isIDX
                          ? '$maxLots lot (${holding.shares} saham)'
                          : '${holding.shares}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isIDX ? 'Lot to Sell' : 'Shares to Sell',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _SellQtyButton(
                    icon: Icons.remove_rounded,
                    enabled: qty > 1,
                    onTap: () => setSheetState(() => qty--),
                  ),
                  Expanded(
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            isIDX ? '$qty lot' : '$qty',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          if (isIDX)
                            Text(
                              '= $actualShares saham',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppTheme.textTertiary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  _SellQtyButton(
                    icon: Icons.add_rounded,
                    enabled: qty < maxLots,
                    onTap: () => setSheetState(() => qty++),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Estimated Proceeds',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${proceedsUsd.toStringAsFixed(2)}',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.positive,
                        ),
                      ),
                      if (isIDX)
                        Text(
                          '≈ ${fmtIdr(proceedsIdr)}',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppTheme.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Sell at USD price (converted from IDR for IDX)
                    portfolio.sellStock(holding.stock, actualShares, livePriceUsd);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isIDX
                              ? 'Sold $qty lot ($actualShares saham) ${holding.stock.ticker}'
                              : 'Sold $qty share${qty > 1 ? 's' : ''} of ${holding.stock.ticker}',
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: AppTheme.negative,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.negative,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'Confirm Sell',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _SellQtyButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _SellQtyButton({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled
              ? AppTheme.negative.withValues(alpha: 0.1)
              : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppTheme.negative : AppTheme.textSecondary,
        ),
      ),
    );
  }
}

// ── Transaction History ───────────────────────────────────────────────────────

class _TransactionHistorySection extends StatelessWidget {
  final bool showIdr;
  final double rate;
  const _TransactionHistorySection({required this.showIdr, required this.rate});

  @override
  Widget build(BuildContext context) {
    final transactions = context.watch<PortfolioProvider>().transactions;
    final recent = transactions.reversed.take(20).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction History',
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (recent.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  size: 36,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(height: 10),
                Text(
                  'No transactions yet',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              separatorBuilder: (_, _) => const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: AppTheme.divider,
              ),
              itemBuilder: (_, i) => _TransactionRow(tx: recent[i], showIdr: showIdr, rate: rate),
            ),
          ),
      ],
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final Transaction tx;
  final bool showIdr;
  final double rate;
  const _TransactionRow({required this.tx, required this.showIdr, required this.rate});

  String _fmt(double usdVal) {
    if (showIdr) {
      final idr = usdVal * rate;
      final s = idr.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
      return 'Rp $s';
    }
    return '\$${usdVal.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final isBuy = tx.type == TransactionType.buy;
    final badgeColor = isBuy ? AppTheme.positive : AppTheme.negative;
    final badgeBg = isBuy
        ? AppTheme.positive.withValues(alpha: 0.1)
        : AppTheme.negative.withValues(alpha: 0.1);

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final d = tx.timestamp;
    final dateStr = '${months[d.month - 1]} ${d.day}, ${d.year}';

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TransactionDetailPage(transaction: tx),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                isBuy ? 'BUY' : 'SELL',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: badgeColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tx.stock.ticker,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _fmt(tx.total),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${tx.shares} sh @ ${_fmt(tx.price)}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 16,
                  color: AppTheme.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── DEV ONLY: Firebase Crashlytics Test Widget ────────────────────────────────
// Remove _CrashTestButton() from portfolio_page.dart build() before production.

class _CrashTestButton extends StatelessWidget {
  const _CrashTestButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.shade300, width: 1.5),
        borderRadius: BorderRadius.circular(14),
        color: Colors.red.shade50,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report_rounded, color: Colors.red.shade600, size: 16),
              const SizedBox(width: 6),
              Text(
                'DEV TOOLS — Remove before production',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.red.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.warning_amber_rounded, size: 16),
                  label: const Text('Fatal Crash'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                    textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => FirebaseCrashlytics.instance.crash(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.info_outline_rounded, size: 16),
                  label: const Text('Non-Fatal'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    FirebaseCrashlytics.instance.recordError(
                      Exception('Test non-fatal error from Fintell Portfolio'),
                      StackTrace.current,
                      fatal: false,
                      reason: 'Manual test trigger via DEV button',
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '✅ Non-fatal error sent to Crashlytics',
                          style: GoogleFonts.inter(fontSize: 13),
                        ),
                        backgroundColor: Colors.orange.shade700,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Fatal: kills app → relaunch → check Firebase Console\nNon-Fatal: stays open → snackbar confirms → check Console',
            style: GoogleFonts.inter(fontSize: 10, color: Colors.red.shade400, height: 1.5),
          ),
        ],
      ),
    );
  }
}
