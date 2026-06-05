import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/portfolio_provider.dart';
import '../../../shared/providers/quiz_provider.dart';

class StartQuizView extends StatelessWidget {
  const StartQuizView({super.key});

  @override
  Widget build(BuildContext context) {
    final portfolio = context.watch<PortfolioProvider>();
    final todayClaimed = portfolio.todayRewardClaimed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (todayClaimed) ...[
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.negative.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.negative.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppTheme.negative, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Limit Reached',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.negative,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'You have already claimed today\'s reward. You can still play the quiz for practice, but no rewards will be granted.',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          height: 1.45,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.quiz_rounded,
                  color: AppTheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Mini Quiz',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                todayClaimed
                    ? 'Practice Mode | 5 questions | No rewards'
                    : 'Beginner | 5 questions | \$100 per correct answer',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (todayClaimed) ...[
          const _InfoRow(
            icon: Icons.school_rounded,
            title: 'Quiz mode',
            value: 'Practice',
          ),
        ] else ...[
          const _InfoRow(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Reward goes to portfolio balance',
            value: 'Virtual cash',
          ),
          const SizedBox(height: 12),
          const _InfoRow(
            icon: Icons.today_rounded,
            title: 'Reward claim limit',
            value: 'Once per day',
          ),
        ],
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.read<QuizProvider>().startQuiz(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Start Quiz',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: AppTheme.primary, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
