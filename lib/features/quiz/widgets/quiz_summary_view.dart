import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/portfolio_provider.dart';
import '../../../shared/providers/quiz_provider.dart';

class QuizSummaryView extends StatelessWidget {
  const QuizSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final portfolio = context.watch<PortfolioProvider>();
    final sessionId = quiz.sessionId;
    final reward = quiz.rewardAmount;

    // Safety guard to prevent Null check operator exception during animations/hot reloads
    if (sessionId == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
              Text(
                'Quiz Complete',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.82),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${quiz.score}/${quiz.totalQuestions}',
                style: GoogleFonts.inter(
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Reward: \$${reward.toStringAsFixed(0)}',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (quiz.rewardClaimed)
          const _ClaimStatusPanel(
            icon: Icons.check_circle_rounded,
            title: 'Reward added',
            message: 'Your virtual cash is now available in Portfolio.',
            color: AppTheme.positive,
          )
        else if (quiz.rewardAlreadyClaimed || portfolio.todayRewardClaimed)
          const _ClaimStatusPanel(
            icon: Icons.event_busy_rounded,
            title: 'Daily reward already claimed',
            message: 'You can still play quizzes, then claim again tomorrow.',
            color: AppTheme.textSecondary,
          )
        else if (reward <= 0)
          const _ClaimStatusPanel(
            icon: Icons.info_rounded,
            title: 'No reward this round',
            message: 'Try another quiz and collect cash for correct answers.',
            color: AppTheme.textSecondary,
          ),
        if (reward > 0 &&
            !quiz.rewardClaimed &&
            !(quiz.rewardAlreadyClaimed || portfolio.todayRewardClaimed)) ...[
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: quiz.canClaimReward
                  ? () => context.read<QuizProvider>().claimReward(
                        () => portfolio.claimQuizReward(
                          sessionId: sessionId,
                          score: quiz.score,
                          totalQuestions: quiz.totalQuestions,
                        ),
                      )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.surfaceVariant,
                disabledForegroundColor: AppTheme.textSecondary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: quiz.claimingReward
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Claim \$${reward.toStringAsFixed(0)}',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: quiz.loading
                ? null
                : () => context.read<QuizProvider>().startQuiz(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary,
              side: const BorderSide(color: AppTheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Play Again',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: TextButton(
            onPressed: quiz.loading
                ? null
                : () => context.read<QuizProvider>().resetQuiz(),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Back to Start',
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

class _ClaimStatusPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;

  const _ClaimStatusPanel({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    height: 1.4,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
