import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'shared/providers/nav_provider.dart';
import 'shared/providers/auth_provider.dart';
import 'shared/providers/market_provider.dart';
import 'shared/providers/portfolio_provider.dart';
import 'shared/providers/quiz_provider.dart';
import 'shared/providers/watchlist_provider.dart';
import 'shared/providers/ai_mentor_provider.dart';
import 'features/auth/auth_page.dart';
import 'features/splash/onboarding_page.dart';
import 'features/market/market_page.dart';
import 'features/portfolio/portfolio_page.dart';
import 'features/watchlist/watchlist_page.dart';
import 'features/quiz/quiz_page.dart';
import 'features/ai_mentor/ai_mentor_page.dart';

import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MarketProvider()),
        ChangeNotifierProvider(create: (_) => PortfolioProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => WatchlistProvider()),
        ChangeNotifierProvider(create: (_) => AiMentorProvider()),
      ],
      child: const FintellApp(),
    ),
  );
}

class FintellApp extends StatelessWidget {
  const FintellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fintell',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashWrapper(),
    );
  }
}

class SplashWrapper extends StatefulWidget {
  const SplashWrapper({super.key});

  @override
  State<SplashWrapper> createState() => _SplashWrapperState();
}

class _SplashWrapperState extends State<SplashWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return Scaffold(
        backgroundColor: AppTheme.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.show_chart_rounded, size: 48, color: AppTheme.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'Fintell',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) return const MainShell();
        return const UnAuthWrapper();
      },
    );
  }
}

class UnAuthWrapper extends StatefulWidget {
  const UnAuthWrapper({super.key});

  @override
  State<UnAuthWrapper> createState() => _UnAuthWrapperState();
}

class _UnAuthWrapperState extends State<UnAuthWrapper> {
  bool _showOnboarding = true;

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return OnboardingPage(
        onFinish: () => setState(() => _showOnboarding = false),
      );
    }
    return const AuthPage();
  }
}

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const List<Widget> _pages = [
    MarketPage(),
    PortfolioPage(),
    AiMentorPage(),
    WatchlistPage(),
    QuizPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavProvider>();
    final quiz = context.watch<QuizProvider>();
    final isQuizInProgress = quiz.hasSession && !quiz.isFinished;
    final isQuizTabActive = nav.currentIndex == 4;
    final shouldHideBottomNav = isQuizInProgress && isQuizTabActive;

    return Scaffold(
      body: IndexedStack(
        index: nav.currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: shouldHideBottomNav ? null : const _FintellBottomNav(),
    );
  }
}

class _FintellBottomNav extends StatelessWidget {
  const _FintellBottomNav();

  static const _items = [
    (Icons.bar_chart_rounded, 'Market', 0),
    (Icons.account_balance_wallet_rounded, 'Portfolio', 1),
    // index 2 = AI Mentor (center button)
    (Icons.bookmark_rounded, 'Watchlist', 3),
    (Icons.quiz_rounded, 'Quiz', 4),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavProvider>();
    final isAiActive = nav.currentIndex == 2;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Regular nav items (2 left + 2 right) ──
              Row(
                children: [
                  // Left 2 items
                  ..._items.take(2).map((item) {
                    final (icon, label, idx) = item;
                    final active = nav.currentIndex == idx;
                    return Expanded(
                      child: _NavItem(
                        icon: icon,
                        label: label,
                        active: active,
                        onTap: () => nav.setIndex(idx),
                      ),
                    );
                  }),
                  // Center spacer for the floating button
                  const Expanded(child: SizedBox()),
                  // Right 2 items
                  ..._items.skip(2).map((item) {
                    final (icon, label, idx) = item;
                    final active = nav.currentIndex == idx;
                    return Expanded(
                      child: _NavItem(
                        icon: icon,
                        label: label,
                        active: active,
                        onTap: () => nav.setIndex(idx),
                      ),
                    );
                  }),
                ],
              ),

              // ── Center AI Mentor floating button ──
              Positioned(
                bottom: 14,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: () => nav.setIndex(2),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: isAiActive
                            ? const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF047857)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : const LinearGradient(
                                colors: [Color(0xFF34D399), Color(0xFF10B981)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: isAiActive ? 0.55 : 0.38),
                            blurRadius: isAiActive ? 20 : 14,
                            spreadRadius: isAiActive ? 2 : 0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),

              // ── AI Mentor label below center button ──
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'AI Mentor',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: isAiActive
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isAiActive
                          ? const Color(0xFF10B981)
                          : Colors.grey.shade500,
                    ),
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

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF10B981) : Colors.grey.shade500;
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF10B981).withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
