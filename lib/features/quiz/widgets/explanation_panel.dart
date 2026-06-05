import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fintell/core/models/quiz_models.dart';
import 'package:fintell/core/theme/app_theme.dart';

class ExplanationPanel extends StatelessWidget {
  final QuizAnswerResult result;

  const ExplanationPanel({super.key, required this.result});

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
          if (!result.correct && result.correctAnswerLabel.isNotEmpty) ...[
            Text(
              'Correct answer: ${result.correctAnswerLabel}',
              style: GoogleFonts.inter(
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
          ],
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
