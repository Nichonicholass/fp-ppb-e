import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:fintell/core/models/quiz_models.dart';
import 'package:fintell/core/theme/app_theme.dart';

class AnswerOption extends StatefulWidget {
  final String label;
  final int index;
  final int? selectedIndex;
  final QuizAnswerResult? result;
  final bool disabled;
  final VoidCallback onTap;

  const AnswerOption({
    super.key,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.result,
    required this.disabled,
    required this.onTap,
  });

  @override
  State<AnswerOption> createState() => _AnswerOptionState();
}

class _AnswerOptionState extends State<AnswerOption> {
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
                  ? SizedBox(
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
