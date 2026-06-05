import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/portfolio_provider.dart';
import '../../../shared/providers/quiz_provider.dart';

class QuizModule {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final String lessonText;
  final List<String> keyTakeaways;

  const QuizModule({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.lessonText,
    required this.keyTakeaways,
  });
}

class QuizModulesHub extends StatelessWidget {
  const QuizModulesHub({super.key});

  static const List<QuizModule> modules = [
    QuizModule(
      id: 'budgeting',
      title: 'Budgeting Basics',
      description: 'Learn how to plan and track your income and expenses to achieve financial stability.',
      icon: Icons.account_balance_wallet_rounded,
      gradientColors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
      lessonText: 'A budget is a roadmap for your money. By using rules like the 50/30/20 rule (50% needs, 30% wants, 20% savings), you ensure that your essential expenses are covered while still building your savings and enjoying your life. Tracking every expense helps prevent overspending.',
      keyTakeaways: [
        'A budget tracks income vs. expenses.',
        'The 50/30/20 rule divides money into Needs, Wants, and Savings.',
        'Tracking prevents accidental overspending.'
      ],
    ),
    QuizModule(
      id: 'saving',
      title: 'The Art of Saving',
      description: 'Build a solid emergency fund and secure your financial safety net.',
      icon: Icons.savings_rounded,
      gradientColors: [Color(0xFF10B981), Color(0xFF059669)],
      lessonText: 'Saving is about keeping money safe for future needs. An emergency fund is the cornerstone of personal finance, representing 3 to 6 months of living expenses. It protects you from high-interest debt when unexpected events, like medical emergencies or job loss, happen.',
      keyTakeaways: [
        'An emergency fund is a financial safety net.',
        'Save 3 to 6 months of living expenses.',
        'Keeps you out of debt when emergencies strike.'
      ],
    ),
    QuizModule(
      id: 'stock_market',
      title: 'Stock Market Intro',
      description: 'Demystify shares, corporate ownership, and how public listings work.',
      icon: Icons.show_chart_rounded,
      gradientColors: [Color(0xFFF59E0B), Color(0xFFD97706)],
      lessonText: 'Buying a stock means purchasing a tiny fraction of ownership in a company. When the company grows and earns profits, the value of your shares increases, and they may pay out dividends. Companies go public through an Initial Public Offering (IPO) to raise capital from everyday investors.',
      keyTakeaways: [
        'Stocks represent partial company ownership.',
        'Dividends are payouts of company profits.',
        'IPOs let companies sell shares to the public.'
      ],
    ),
    QuizModule(
      id: 'investing_basics',
      title: 'Investing 101',
      description: 'Differentiate saving from investing and understand asset classes.',
      icon: Icons.trending_up_rounded,
      gradientColors: [Color(0xFFEC4899), Color(0xFFDB2777)],
      lessonText: 'While saving preserves capital with low risk, investing aims to build long-term wealth by purchasing assets like stocks, bonds, or real estate. Investing involves higher risk and volatility, but historically delivers much higher returns than a standard bank savings account.',
      keyTakeaways: [
        'Saving preserves cash; investing grows wealth.',
        'Investing involves risk and market fluctuations.',
        'Stocks and real estate are common investment assets.'
      ],
    ),
    QuizModule(
      id: 'risk_return',
      title: 'Risk & Return',
      description: 'Learn the core balance between financial risk and potential rewards.',
      icon: Icons.balance_rounded,
      gradientColors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
      lessonText: 'The risk-return tradeoff is a fundamental financial principle: higher potential returns always require accepting higher risk of loss. Low-risk investments like government bonds offer safety but lower returns, whereas stocks offer higher potential gains along with higher price volatility.',
      keyTakeaways: [
        'Risk and return are directly related.',
        'High potential return requires high risk tolerance.',
        'Bonds are lower risk; stocks are higher risk.'
      ],
    ),
    QuizModule(
      id: 'diversification',
      title: 'Diversification',
      description: 'Spread your eggs across multiple baskets to mitigate unsystematic risk.',
      icon: Icons.grid_view_rounded,
      gradientColors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
      lessonText: 'Diversification is the practice of spreading your investments across various assets, sectors, and geographic regions. By doing so, a decline in one single company or sector won\'t devastate your entire portfolio. It is the most effective way to reduce company-specific (unsystematic) risk.',
      keyTakeaways: [
        'Diversification reduces company-specific risk.',
        'Avoid putting all your funds in one place.',
        'Spreads capital across assets and industries.'
      ],
    ),
    QuizModule(
      id: 'inflation',
      title: 'Inflation Explained',
      description: 'See how inflation erodes purchasing power and how to hedge against it.',
      icon: Icons.toll_rounded,
      gradientColors: [Color(0xFFEF4444), Color(0xFFDC2626)],
      lessonText: 'Inflation is the gradual increase in prices over time, which reduces the purchasing power of your money. If your savings interest rate is lower than inflation, you are effectively losing money. Investing in assets like equities and real estate has historically been an excellent inflation hedge.',
      keyTakeaways: [
        'Inflation erodes the purchasing power of money.',
        'Cash in savings accounts loses value to inflation.',
        'Stocks and real estate historically beat inflation.'
      ],
    ),
    QuizModule(
      id: 'compound_interest',
      title: 'Compound Interest',
      description: 'Discover the exponential power of earning interest on your interest.',
      icon: Icons.auto_awesome_rounded,
      gradientColors: [Color(0xFF14B8A6), Color(0xFF0D9488)],
      lessonText: 'Compound interest is when you earn interest on both your original principal and the interest accumulated over time. This creates a snowball effect where your wealth grows exponentially. The Rule of 72 helps estimate doubling time: divide 72 by your annual interest rate.',
      keyTakeaways: [
        'Earn interest on principal AND prior interest.',
        'Creates exponential wealth growth over time.',
        'The Rule of 72 estimates investment doubling time.'
      ],
    ),
    QuizModule(
      id: 'pe_ratio',
      title: 'Valuation & P/E',
      description: 'Learn how to evaluate if a stock is cheap or expensive.',
      icon: Icons.analytics_rounded,
      gradientColors: [Color(0xFF6B7280), Color(0xFF4B5563)],
      lessonText: 'The Price-to-Earnings (P/E) ratio compares a company\'s stock price to its earnings per share. A high P/E ratio indicates that investors expect high growth in the future or that the stock is currently overvalued. A low P/E can mean a company is undervalued or in trouble.',
      keyTakeaways: [
        'P/E compares stock price to its earnings.',
        'High P/E suggests high growth or overvaluation.',
        'Low P/E can mean undervaluation or distress.'
      ],
    ),
    QuizModule(
      id: 'roe',
      title: 'ROE Profitability',
      description: 'Analyze how efficiently a company turns equity into earnings.',
      icon: Icons.pie_chart_rounded,
      gradientColors: [Color(0xFFF43F5E), Color(0xFFE11D48)],
      lessonText: 'Return on Equity (ROE) measures a corporation\'s profitability by showing how much profit a company generates with the money shareholders have invested. An ROE of 15-20% is generally considered strong, indicating highly efficient corporate management.',
      keyTakeaways: [
        'ROE measures efficiency of shareholder capital usage.',
        'Calculated as Net Income divided by Equity.',
        'Higher ROE signifies superior profit generation.'
      ],
    ),
    QuizModule(
      id: 'mutual_funds',
      title: 'Mutual Funds',
      description: 'Explore pooled investment vehicles managed by finance professionals.',
      icon: Icons.groups_rounded,
      gradientColors: [Color(0xFF78716C), Color(0xFF57534E)],
      lessonText: 'A mutual fund pools money from many individual investors to purchase a broad, diversified portfolio of stocks, bonds, or other securities. These portfolios are managed by professional fund managers, making them an excellent hands-off choice for beginners seeking instant diversification.',
      keyTakeaways: [
        'Mutual funds pool money from multiple investors.',
        'Managed by financial professionals.',
        'Provides instant, affordable diversification.'
      ],
    ),
    QuizModule(
      id: 'cryptocurrency',
      title: 'Crypto & Blockchain',
      description: 'Understand digital assets and decentralized ledger technology.',
      icon: Icons.currency_bitcoin_rounded,
      gradientColors: [Color(0xFF84CC16), Color(0xFF65A30D)],
      lessonText: 'Cryptocurrencies are digital, decentralized currencies built on blockchain technology. Unlike traditional money, they are not issued or backed by any government or central bank. They offer high potential returns but come with extreme volatility and unique security risks.',
      keyTakeaways: [
        'Decentralized digital currencies.',
        'Powered securely by blockchain technology.',
        'Carries extreme price volatility and unique risks.'
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final portfolio = context.watch<PortfolioProvider>();
    final completedCount = portfolio.completedModuleIds.length;
    final totalModules = modules.length;
    final progressPercentage = totalModules > 0 ? completedCount / totalModules : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Sleek Dashboard Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Learning Progress',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$completedCount of $totalModules Modules',
                        style: GoogleFonts.inter(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.3), width: 1),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.monetization_on_rounded, color: Colors.amber, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          '${completedCount * 200} Coins',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progressPercentage,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  color: AppTheme.primary,
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Learning Modules',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tap a module to read the material and test your skills.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        // 2. Bento Grid of Modules
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: modules.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            final module = modules[index];
            final isCompleted = portfolio.isModuleCompleted(module.id);

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showModuleDetails(context, module, isCompleted),
                borderRadius: BorderRadius.circular(20),
                child: Ink(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCompleted
                          ? Colors.green.withValues(alpha: 0.25)
                          : AppTheme.surfaceVariant.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gradient Icon Container
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: module.gradientColors,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(module.icon, color: Colors.white, size: 22),
                      ),
                      const Spacer(),
                      Text(
                        module.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        module.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          height: 1.3,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      // Status Badge
                      isCompleted
                          ? Row(
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  'Completed',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                const Icon(Icons.monetization_on_rounded, color: Colors.amber, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '+200 Coins',
                                  style: GoogleFonts.inter(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.amber,
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showModuleDetails(BuildContext context, QuizModule module, bool isCompleted) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: module.gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(module.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module.title,
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isCompleted ? 'Completed' : 'Learn & Earn',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isCompleted ? Colors.green : Colors.amber,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Lesson Title
              Text(
                'Key Lesson Material',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                module.lessonText,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.5,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              // Takeaways
              ...module.keyTakeaways.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2.0),
                        child: Icon(Icons.arrow_right_alt_rounded, color: module.gradientColors[0], size: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: GoogleFonts.inter(
                            fontSize: 12.5,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Actions
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close bottom sheet
                    context.read<QuizProvider>().startQuiz(
                          topic: module.id,
                          alreadyClaimed: isCompleted,
                        );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    isCompleted ? 'Practice Quiz' : 'Take Quiz & Earn Coins',
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
    );
  }
}
