import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../auth/auth_page.dart';

class OnboardingPage extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingPage({super.key, required this.onFinish});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'Welcome to Fintell',
      description: 'Your intelligent companion for mastering the financial markets and building your portfolio.',
      icon: Icons.account_balance_wallet_rounded,
    ),
    OnboardingData(
      title: 'Learn & Earn',
      description: 'Take interactive quizzes to expand your financial knowledge and earn virtual coins.',
      icon: Icons.quiz_rounded,
    ),
    OnboardingData(
      title: 'Virtual Trading',
      description: 'Practice trading real stocks with your virtual balance without risking actual money.',
      icon: Icons.trending_up_rounded,
    ),
    OnboardingData(
      title: 'AI Mentor',
      description: 'Get personalized insights and have your questions answered by our advanced AI financial mentor.',
      icon: Icons.auto_awesome_rounded,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: widget.onFinish,
                child: Text(
                  'Skip',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
            
            // PageView
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            data.icon,
                            size: 64,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          data.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          data.description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            height: 1.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicators & Button
            Padding(
              padding: const EdgeInsets.all(32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 8),
                        height: 8,
                        width: _currentPage == index ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.primary
                              : AppTheme.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  
                  // Next / Get Started
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;

  OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
  });
}
