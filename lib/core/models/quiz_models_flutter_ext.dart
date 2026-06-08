import 'package:flutter/material.dart';
import 'quiz_models.dart';

extension QuizModuleFlutterExt on QuizModule {
  IconData get icon {
    switch (iconName) {
      case 'wallet':
      case 'account_balance_wallet':
        return Icons.account_balance_wallet_rounded;
      case 'savings':
        return Icons.savings_rounded;
      case 'chart':
      case 'show_chart':
        return Icons.show_chart_rounded;
      case 'trending':
      case 'trending_up':
        return Icons.trending_up_rounded;
      case 'balance':
        return Icons.balance_rounded;
      case 'grid':
      case 'grid_view':
        return Icons.grid_view_rounded;
      case 'toll':
        return Icons.toll_rounded;
      case 'stars':
      case 'auto_awesome':
        return Icons.auto_awesome_rounded;
      case 'analytics':
        return Icons.analytics_rounded;
      case 'pie_chart':
        return Icons.pie_chart_rounded;
      case 'groups':
        return Icons.groups_rounded;
      case 'bitcoin':
      case 'crypto':
      case 'currency_bitcoin':
        return Icons.currency_bitcoin_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  List<Color> get gradientColors {
    if (gradientColorsValues.isEmpty) {
      return [const Color(0xFF6366F1), const Color(0xFF4F46E5)];
    }
    return gradientColorsValues.map((val) => Color(val)).toList();
  }
}
