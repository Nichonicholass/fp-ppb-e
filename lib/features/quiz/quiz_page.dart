import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/services/quiz_service.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/providers/portfolio_provider.dart';
import '../../shared/providers/quiz_provider.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PortfolioProvider>().checkTodayRewardClaimed();
      }
    });
  }

  Future<void> _showExitConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Exit Quiz?',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            color: AppTheme.negative,
          ),
        ),
        content: Text(
          'Are you sure you want to exit the quiz? All your current progress will be lost.',
          style: GoogleFonts.inter(
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.negative,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Exit',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<QuizProvider>().resetQuiz();
    }
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final isQuizInProgress = quiz.hasSession && !quiz.isFinished;

    return PopScope(
      canPop: !isQuizInProgress,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        _showExitConfirmation(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quiz'),
          leading: isQuizInProgress
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: quiz.loading || quiz.submitting
                      ? null
                      : () => _showExitConfirmation(context),
                )
              : null,
          actions: [
            if (quiz.hasSession && quiz.isFinished)
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: quiz.loading || quiz.submitting
                    ? null
                    : () => context.read<QuizProvider>().resetQuiz(),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: quiz.loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (quiz.error != null) ...[
                        _ErrorBanner(message: quiz.error!),
                        const SizedBox(height: 16),
                      ],
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.05),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: !quiz.hasSession
                            ? const _StartQuizView(key: ValueKey('start'))
                            : (quiz.isFinished
                                ? const _QuizSummaryView(key: ValueKey('summary'))
                                : const _QuestionView(key: ValueKey('question'))),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _StartQuizView extends StatelessWidget {
  const _StartQuizView({super.key});

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
          _InfoRow(
            icon: Icons.school_rounded,
            title: 'Quiz mode',
            value: 'Practice',
          ),
        ] else ...[
          _InfoRow(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Reward goes to portfolio balance',
            value: 'Virtual cash',
          ),
          const SizedBox(height: 12),
          _InfoRow(
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

class _QuestionView extends StatelessWidget {
  const _QuestionView({super.key});

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final question = quiz.currentQuestion;
    if (question == null) {
      return const SizedBox.shrink();
    }
    final result = quiz.currentAnswerResult;
    final selectedIndex = quiz.selectedIndex;
    final displayIndex = quiz.isFinished ? quiz.totalQuestions : quiz.currentIndex + 1;
    final progress = quiz.totalQuestions > 0
        ? (displayIndex / quiz.totalQuestions).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Question $displayIndex of ${quiz.totalQuestions}',
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const Spacer(),
            _ScoreChip(score: quiz.score),
          ],
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: 8,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  height: 8,
                  width: constraints.maxWidth * progress,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, Color(0xFF6366F1)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            );
          },
          child: Column(
            key: ValueKey<int>(quiz.currentIndex),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  question.question,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              ...List.generate(question.options.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AnswerOption(
                    key: ValueKey(index),
                    label: question.options[index],
                    index: index,
                    selectedIndex: selectedIndex,
                    result: result,
                    disabled: quiz.submitting || result != null,
                    onTap: () => context.read<QuizProvider>().submitAnswer(index),
                  ),
                );
              }),
            ],
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: result != null
              ? Column(
                  children: [
                    const SizedBox(height: 8),
                    _ExplanationPanel(result: result),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => context.read<QuizProvider>().nextQuestion(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          quiz.currentIndex == quiz.totalQuestions - 1
                              ? 'View Summary'
                              : 'Next Question',
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _QuizSummaryView extends StatelessWidget {
  const _QuizSummaryView({super.key});

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final portfolio = context.watch<PortfolioProvider>();
    final sessionId = quiz.sessionId!;
    final reward = quiz.rewardAmount;

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

class _AnswerOption extends StatefulWidget {
  final String label;
  final int index;
  final int? selectedIndex;
  final QuizAnswerResult? result;
  final bool disabled;
  final VoidCallback onTap;

  const _AnswerOption({
    super.key,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.result,
    required this.disabled,
    required this.onTap,
  });

  @override
  State<_AnswerOption> createState() => _AnswerOptionState();
}

class _AnswerOptionState extends State<_AnswerOption> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final answerResult = widget.result;
    final isAnswered = answerResult != null;
    final isCorrect = answerResult != null && widget.index == answerResult.correctIndex;
    final isSelected = widget.selectedIndex == widget.index;
    final isWrongSelection = isAnswered && isSelected && !isCorrect;
    final isPendingSelection = !isAnswered && isSelected;

    final borderColor = isCorrect
        ? AppTheme.positive
        : isWrongSelection
            ? AppTheme.negative
            : isPendingSelection
                ? AppTheme.primary
                : AppTheme.divider;
    final bgColor = isCorrect
        ? AppTheme.positive.withValues(alpha: 0.10)
        : isWrongSelection
            ? AppTheme.negative.withValues(alpha: 0.10)
            : isPendingSelection
                ? AppTheme.primary.withValues(alpha: 0.08)
                : Colors.white;
    final icon = isCorrect
        ? Icons.check_circle_rounded
        : isWrongSelection
            ? Icons.cancel_rounded
            : Icons.circle_outlined;
    final iconColor = isCorrect
        ? AppTheme.positive
        : isWrongSelection
            ? AppTheme.negative
            : isPendingSelection
                ? AppTheme.primary
                : AppTheme.textTertiary;

    return GestureDetector(
      onTapDown: widget.disabled
          ? null
          : (_) => setState(() => _isPressed = true),
      onTapUp: widget.disabled
          ? null
          : (_) => setState(() => _isPressed = false),
      onTapCancel: widget.disabled
          ? null
          : () => setState(() => _isPressed = false),
      onTap: widget.disabled ? null : widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: borderColor,
              width: isSelected || isCorrect || isWrongSelection ? 2.0 : 1.0,
            ),
            boxShadow: isSelected && !isAnswered
                ? [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Row(
            children: [
              isPendingSelection
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                      ),
                    )
                  : Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.label,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExplanationPanel extends StatelessWidget {
  final QuizAnswerResult result;

  const _ExplanationPanel({required this.result});

  @override
  Widget build(BuildContext context) {
    final color = result.correct ? AppTheme.positive : AppTheme.negative;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                result.correct
                    ? Icons.lightbulb_rounded
                    : Icons.psychology_rounded,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 8),
              Text(
                result.correct ? 'Correct' : 'Answer Review',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            result.explanation,
            style: GoogleFonts.inter(
              fontSize: 13,
              height: 1.45,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreChip extends StatelessWidget {
  final int score;

  const _ScoreChip({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$score correct',
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryDark,
        ),
      ),
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

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.negative.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppTheme.negative,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.negative,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
