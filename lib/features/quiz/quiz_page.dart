import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/providers/portfolio_provider.dart';
import '../../shared/providers/quiz_provider.dart';
import '../../shared/providers/nav_provider.dart';
import '../../core/services/notification_service.dart';
import 'widgets/error_banner.dart';
import 'widgets/question_view.dart';
import 'widgets/quiz_summary_view.dart';
import 'widgets/quiz_modules_hub.dart';

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
        context.read<QuizProvider>().loadModules();
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
    final nav = context.watch<NavProvider>();
    final quiz = context.watch<QuizProvider>();
    final isQuizInProgress = quiz.hasSession && !quiz.isFinished;
    final isQuizTabActive = nav.currentIndex == 4;
    final shouldBlockPop = isQuizInProgress && isQuizTabActive;

    return PopScope(
      canPop: !shouldBlockPop,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (shouldBlockPop) {
          _showExitConfirmation(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isQuizInProgress ? 'Quiz Session' : 'Fintell Academy',
            style: GoogleFonts.inter(fontWeight: FontWeight.w800),
          ),
          leading: isQuizInProgress
              ? IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: quiz.loading || quiz.submitting
                      ? null
                      : () => _showExitConfirmation(context),
                )
              : null,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_active_rounded),
              tooltip: 'Demo Quiz Reminder',
              onPressed: () {
                NotificationService().scheduleQuizReminder();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Reminder scheduled! It will appear in 5 seconds. You can minimize the app now.',
                      style: GoogleFonts.inter(),
                    ),
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 3),
                  ),
                );
              },
            ),
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
                        ErrorBanner(message: quiz.error!),
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
                            ? const QuizModulesHub(key: ValueKey('modules_hub'))
                            : (quiz.isFinished
                                ? const QuizSummaryView(key: ValueKey('summary'))
                                : const QuestionView(key: ValueKey('question'))),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
