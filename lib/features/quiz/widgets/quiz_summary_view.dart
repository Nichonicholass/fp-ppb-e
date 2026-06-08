import 'dart:math' as math;

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/portfolio_provider.dart';
import '../../../shared/providers/quiz_provider.dart';

class QuizSummaryView extends StatefulWidget {
  const QuizSummaryView({super.key});

  @override
  State<QuizSummaryView> createState() => _QuizSummaryViewState();
}

class _QuizSummaryViewState extends State<QuizSummaryView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _chestController;
  late final Animation<double> _chestFloat;
  late final ConfettiController _confettiController;
  OverlayEntry? _confettiOverlayEntry;

  @override
  void initState() {
    super.initState();
    _chestController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _chestFloat = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _chestController, curve: Curves.easeInOut),
    );
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    final quiz = context.read<QuizProvider>();
    if (quiz.score > 0) {
      _confettiController.play();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showConfettiOverlay();
        }
      });
    }
  }

  void _showConfettiOverlay() {
    _confettiOverlayEntry = OverlayEntry(
      builder: (context) => IgnorePointer(
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: -math.pi / 4,
                blastDirectionality: BlastDirectionality.directional,
                emissionFrequency: 0.03,
                numberOfParticles: 5,
                maxBlastForce: 25,
                minBlastForce: 10,
                minimumSize: const Size(10, 8),
                maximumSize: const Size(14, 12),
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.amber,
                ],
                gravity: 0.2,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: -3 * math.pi / 4,
                blastDirectionality: BlastDirectionality.directional,
                emissionFrequency: 0.03,
                numberOfParticles: 5,
                maxBlastForce: 25,
                minBlastForce: 10,
                minimumSize: const Size(12, 10),
                maximumSize: const Size(16, 14),
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.amber,
                ],
                gravity: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insert(_confettiOverlayEntry!);
  }

  @override
  void dispose() {
    _chestController.dispose();
    _confettiController.dispose();
    _confettiOverlayEntry?.remove();
    _confettiOverlayEntry = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final portfolio = context.watch<PortfolioProvider>();
    final sessionId = quiz.sessionId;
    if (sessionId == null) {
      return const SizedBox.shrink();
    }
    final reward = quiz.rewardAmount;
    final maxReward = quiz.maxRewardAmount;

    final isCompleted = portfolio.isModuleCompleted(sessionId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SizedBox(
            height: 190,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/treasure-chest-background.png',
                      width: 160,
                      height: 160,
                      fit: BoxFit.contain,
                    ),
                    AnimatedBuilder(
                      animation: _chestFloat,
                      builder: (context, child) {
                        final offset = -10 * math.sin(_chestFloat.value * math.pi);
                        return Transform.translate(
                          offset: Offset(0, offset),
                          child: child,
                        );
                      },
                      child: Image.asset(
                        'assets/treasure-chest.png',
                        width: 90,
                        height: 90,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  reward > 0 && !(quiz.rewardAlreadyClaimed || isCompleted)
                      ? 'Reward Waiting!'
                      : 'Quiz Complete!',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Score card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Module Quiz Complete',
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
                'Earned Reward: \$${reward.toStringAsFixed(0)} Coins',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Max Reward: \$${maxReward.toStringAsFixed(0)} Coins',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.76),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (quiz.rewardClaimed)
          const _ClaimStatusPanel(
            icon: Icons.check_circle_rounded,
            title: 'Reward Claimed!',
            message: 'Your virtual coins have been added to your Portfolio balance.',
            color: AppTheme.positive,
          )
        else if (quiz.rewardAlreadyClaimed || isCompleted)
          const _ClaimStatusPanel(
            icon: Icons.event_busy_rounded,
            title: 'Reward already claimed',
            message: 'You have already collected the module reward. You can keep practicing to test your knowledge!',
            color: AppTheme.textSecondary,
          )
        else if (reward <= 0)
          const _ClaimStatusPanel(
            icon: Icons.info_rounded,
            title: 'No correct answers',
            message: 'Get at least one question right to claim your reward coins.',
            color: AppTheme.textSecondary,
          ),
        if (reward > 0 &&
            !quiz.rewardClaimed &&
            !(quiz.rewardAlreadyClaimed || isCompleted)) ...[
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: quiz.canClaimReward
                  ? () => context.read<QuizProvider>().claimReward(
                        () => portfolio.claimModuleReward(
                          moduleId: sessionId,
                          score: quiz.score,
                          totalQuestions: quiz.totalQuestions,
                          rewardPerCorrect: QuizProvider.rewardPerCorrectAnswer,
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
                      'Claim \$${reward.toStringAsFixed(0)} Coins',
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
                : () => context.read<QuizProvider>().startQuiz(topic: sessionId, alreadyClaimed: isCompleted),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primary,
              side: const BorderSide(color: AppTheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Retake Quiz',
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
              'Back to Modules Hub',
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
