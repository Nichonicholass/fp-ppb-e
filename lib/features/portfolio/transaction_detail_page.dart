import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/dummy_data/app_data.dart';

class TransactionDetailPage extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailPage({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final tx = transaction;
    final isBuy = tx.type == TransactionType.buy;
    final badgeColor = isBuy ? AppTheme.positive : AppTheme.negative;
    final tickerDisplay = tx.stock.ticker.length > 4
        ? tx.stock.ticker.substring(0, 4)
        : tx.stock.ticker;

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final d = tx.timestamp;
    final dateStr = '${months[d.month - 1]} ${d.day}, ${d.year}';
    final timeStr =
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _HeaderCard(
              tx: tx,
              isBuy: isBuy,
              badgeColor: badgeColor,
              tickerDisplay: tickerDisplay,
              dateStr: dateStr,
            ),
            const SizedBox(height: 16),
            _DetailsCard(
              tx: tx,
              isBuy: isBuy,
              badgeColor: badgeColor,
              dateStr: dateStr,
              timeStr: timeStr,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Transaction tx;
  final bool isBuy;
  final Color badgeColor;
  final String tickerDisplay;
  final String dateStr;

  const _HeaderCard({
    required this.tx,
    required this.isBuy,
    required this.badgeColor,
    required this.tickerDisplay,
    required this.dateStr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: tx.stock.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                tickerDisplay,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: tx.stock.color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            tx.stock.ticker,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tx.stock.name,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isBuy ? 'BUY ORDER' : 'SELL ORDER',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '\$${tx.total.toStringAsFixed(2)}',
            style: GoogleFonts.inter(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total ${isBuy ? 'Spent' : 'Received'}',
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

class _DetailsCard extends StatelessWidget {
  final Transaction tx;
  final bool isBuy;
  final Color badgeColor;
  final String dateStr;
  final String timeStr;

  const _DetailsCard({
    required this.tx,
    required this.isBuy,
    required this.badgeColor,
    required this.dateStr,
    required this.timeStr,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _DetailRow(label: 'Shares', value: '${tx.shares} shares'),
          Divider(height: 1, color: AppTheme.divider),
          _DetailRow(
            label: 'Price per Share',
            value: '\$${tx.price.toStringAsFixed(2)}',
          ),
          Divider(height: 1, color: AppTheme.divider),
          _DetailRow(label: 'Date', value: dateStr),
          Divider(height: 1, color: AppTheme.divider),
          _DetailRow(label: 'Time', value: timeStr),
          Divider(height: 1, color: AppTheme.divider),
          _DetailRow(label: 'Sector', value: tx.stock.sector),
          Divider(height: 1, color: AppTheme.divider),
          _DetailRow(
            label: 'Type',
            value: isBuy ? 'Buy' : 'Sell',
            valueColor: badgeColor,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
