import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'shared/providers/nav_provider.dart';
import 'shared/providers/auth_provider.dart';
import 'shared/providers/market_provider.dart';
import 'shared/providers/portfolio_provider.dart';
import 'shared/providers/quiz_provider.dart';
import 'shared/providers/watchlist_provider.dart';
import 'features/auth/auth_page.dart';
import 'features/market/market_page.dart';
import 'features/portfolio/portfolio_page.dart';
import 'features/watchlist/watchlist_page.dart';
import 'features/goals/goals_page.dart';
import 'features/quiz/quiz_page.dart';
import 'features/ai_mentor/ai_mentor_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData) return const MainShell();
          return const AuthPage();
        },
      ),
    );
  }
}

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const List<Widget> _pages = [
    MarketPage(),
    PortfolioPage(),
    WatchlistPage(),
    GoalsPage(),
    QuizPage(),
    AiMentorPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavProvider>();
    final quiz = context.watch<QuizProvider>();
    final isQuizInProgress = quiz.hasSession && !quiz.isFinished;
    return Scaffold(
      body: IndexedStack(
        index: nav.currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: isQuizInProgress ? null : const _FintellBottomNav(),
    );
  }
}

class _FintellBottomNav extends StatelessWidget {
  const _FintellBottomNav();

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavProvider>();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: nav.currentIndex,
        onTap: nav.setIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Portfolio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_rounded),
            label: 'Watchlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag_rounded),
            label: 'Goals',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_rounded),
            label: 'Quiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_rounded),
            label: 'AI Mentor',
          ),
        ],
      ),
    );
  }
}
