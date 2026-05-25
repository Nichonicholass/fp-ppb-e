import 'package:flutter/material.dart';

class Stock {
  final String ticker;
  final String name;
  final double price;
  final double changePercent;
  final double peRatio;
  final double roe;
  final String sector;
  final Color color;

  const Stock({
    required this.ticker,
    required this.name,
    required this.price,
    required this.changePercent,
    required this.peRatio,
    required this.roe,
    required this.sector,
    required this.color,
  });
}

class OwnedStock {
  final Stock stock;
  final int shares;
  final double avgPrice;

  const OwnedStock({
    required this.stock,
    required this.shares,
    required this.avgPrice,
  });

  double get currentValue => stock.price * shares;
  double get costBasis => avgPrice * shares;
  double get gainLoss => currentValue - costBasis;
  double get gainLossPercent => ((stock.price - avgPrice) / avgPrice) * 100;
}

class Goal {
  final String title;
  final String subtitle;
  final double target;
  final double current;
  final IconData icon;
  final Color color;
  final String deadline;

  const Goal({
    required this.title,
    required this.subtitle,
    required this.target,
    required this.current,
    required this.icon,
    required this.color,
    required this.deadline,
  });

  double get progress => (current / target).clamp(0.0, 1.0);
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String time;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
  });
}

class MarketIndex {
  final String name;
  final double value;
  final double changePercent;

  const MarketIndex({
    required this.name,
    required this.value,
    required this.changePercent,
  });
}

class AppData {
  static const double virtualBalance = 52450.00;
  static const double totalInvested = 49239.50;
  static const double portfolioReturn = 3210.50;
  static const double portfolioReturnPercent = 6.51;

  static const List<MarketIndex> indices = [
    MarketIndex(name: 'S&P 500', value: 5306.04, changePercent: 0.48),
    MarketIndex(name: 'NASDAQ', value: 16920.79, changePercent: 0.82),
    MarketIndex(name: 'DOW', value: 39069.53, changePercent: 0.20),
  ];

  static const List<Stock> popularStocks = [
    Stock(
      ticker: 'AAPL',
      name: 'Apple Inc.',
      price: 189.30,
      changePercent: 1.24,
      peRatio: 29.5,
      roe: 160.1,
      sector: 'Technology',
      color: Color(0xFF6366F1),
    ),
    Stock(
      ticker: 'MSFT',
      name: 'Microsoft Corp.',
      price: 415.60,
      changePercent: 0.87,
      peRatio: 37.2,
      roe: 38.5,
      sector: 'Technology',
      color: Color(0xFF0EA5E9),
    ),
    Stock(
      ticker: 'GOOGL',
      name: 'Alphabet Inc.',
      price: 177.85,
      changePercent: -0.34,
      peRatio: 25.8,
      roe: 28.3,
      sector: 'Technology',
      color: Color(0xFFEA4335),
    ),
    Stock(
      ticker: 'AMZN',
      name: 'Amazon.com Inc.',
      price: 185.09,
      changePercent: 2.15,
      peRatio: 59.4,
      roe: 19.7,
      sector: 'Consumer Disc.',
      color: Color(0xFFFF9900),
    ),
    Stock(
      ticker: 'NVDA',
      name: 'NVIDIA Corp.',
      price: 877.35,
      changePercent: 4.89,
      peRatio: 68.1,
      roe: 91.8,
      sector: 'Technology',
      color: Color(0xFF76B900),
    ),
    Stock(
      ticker: 'META',
      name: 'Meta Platforms',
      price: 505.28,
      changePercent: 1.53,
      peRatio: 28.9,
      roe: 35.4,
      sector: 'Comm. Services',
      color: Color(0xFF1877F2),
    ),
    Stock(
      ticker: 'TSLA',
      name: 'Tesla Inc.',
      price: 174.48,
      changePercent: -1.82,
      peRatio: 44.3,
      roe: 21.1,
      sector: 'Consumer Disc.',
      color: Color(0xFFCC0000),
    ),
    Stock(
      ticker: 'BRK.B',
      name: 'Berkshire Hathaway',
      price: 407.54,
      changePercent: 0.35,
      peRatio: 21.4,
      roe: 15.2,
      sector: 'Finance',
      color: Color(0xFF8B4513),
    ),
    Stock(
      ticker: 'JPM',
      name: 'JPMorgan Chase',
      price: 197.45,
      changePercent: 0.65,
      peRatio: 11.8,
      roe: 16.9,
      sector: 'Finance',
      color: Color(0xFF003087),
    ),
    Stock(
      ticker: 'JNJ',
      name: 'Johnson & Johnson',
      price: 144.78,
      changePercent: -0.21,
      peRatio: 16.3,
      roe: 23.8,
      sector: 'Healthcare',
      color: Color(0xFFD32F2F),
    ),
  ];

  static List<OwnedStock> get ownedStocks => [
        OwnedStock(stock: popularStocks[0], shares: 50, avgPrice: 165.20),
        OwnedStock(stock: popularStocks[1], shares: 30, avgPrice: 380.00),
        OwnedStock(stock: popularStocks[4], shares: 15, avgPrice: 620.50),
        OwnedStock(stock: popularStocks[5], shares: 20, avgPrice: 460.00),
      ];

  static const List<Stock> watchlistTech = [
    Stock(
      ticker: 'AAPL',
      name: 'Apple Inc.',
      price: 189.30,
      changePercent: 1.24,
      peRatio: 29.5,
      roe: 160.1,
      sector: 'Technology',
      color: Color(0xFF6366F1),
    ),
    Stock(
      ticker: 'MSFT',
      name: 'Microsoft Corp.',
      price: 415.60,
      changePercent: 0.87,
      peRatio: 37.2,
      roe: 38.5,
      sector: 'Technology',
      color: Color(0xFF0EA5E9),
    ),
    Stock(
      ticker: 'NVDA',
      name: 'NVIDIA Corp.',
      price: 877.35,
      changePercent: 4.89,
      peRatio: 68.1,
      roe: 91.8,
      sector: 'Technology',
      color: Color(0xFF76B900),
    ),
    Stock(
      ticker: 'GOOGL',
      name: 'Alphabet Inc.',
      price: 177.85,
      changePercent: -0.34,
      peRatio: 25.8,
      roe: 28.3,
      sector: 'Technology',
      color: Color(0xFFEA4335),
    ),
  ];

  static const List<Stock> watchlistFinance = [
    Stock(
      ticker: 'BRK.B',
      name: 'Berkshire Hathaway',
      price: 407.54,
      changePercent: 0.35,
      peRatio: 21.4,
      roe: 15.2,
      sector: 'Finance',
      color: Color(0xFF8B4513),
    ),
    Stock(
      ticker: 'JPM',
      name: 'JPMorgan Chase',
      price: 197.45,
      changePercent: 0.65,
      peRatio: 11.8,
      roe: 16.9,
      sector: 'Finance',
      color: Color(0xFF003087),
    ),
    Stock(
      ticker: 'V',
      name: 'Visa Inc.',
      price: 278.30,
      changePercent: 0.92,
      peRatio: 30.1,
      roe: 44.7,
      sector: 'Finance',
      color: Color(0xFF1A1F71),
    ),
    Stock(
      ticker: 'MA',
      name: 'Mastercard Inc.',
      price: 468.15,
      changePercent: 1.04,
      peRatio: 35.8,
      roe: 178.3,
      sector: 'Finance',
      color: Color(0xFFEB001B),
    ),
  ];

  static const List<Stock> watchlistHealth = [
    Stock(
      ticker: 'JNJ',
      name: 'Johnson & Johnson',
      price: 144.78,
      changePercent: -0.21,
      peRatio: 16.3,
      roe: 23.8,
      sector: 'Healthcare',
      color: Color(0xFFD32F2F),
    ),
    Stock(
      ticker: 'UNH',
      name: 'UnitedHealth Group',
      price: 519.45,
      changePercent: -0.88,
      peRatio: 22.1,
      roe: 26.5,
      sector: 'Healthcare',
      color: Color(0xFF0038A8),
    ),
    Stock(
      ticker: 'PFE',
      name: 'Pfizer Inc.',
      price: 28.64,
      changePercent: -1.45,
      peRatio: 12.5,
      roe: 8.7,
      sector: 'Healthcare',
      color: Color(0xFF0050A0),
    ),
  ];

  static const List<Goal> goals = [
    Goal(
      title: 'Emergency Fund',
      subtitle: '6 months of expenses saved',
      target: 30000,
      current: 18500,
      icon: Icons.security_rounded,
      color: Color(0xFF10B981),
      deadline: 'Dec 2025',
    ),
    Goal(
      title: 'Vacation to Japan',
      subtitle: 'Tokyo & Osaka trip',
      target: 8000,
      current: 5200,
      icon: Icons.flight_rounded,
      color: Color(0xFF6366F1),
      deadline: 'Aug 2025',
    ),
    Goal(
      title: 'New Laptop',
      subtitle: 'MacBook Pro M3',
      target: 2500,
      current: 2500,
      icon: Icons.laptop_mac_rounded,
      color: Color(0xFF0EA5E9),
      deadline: 'Achieved!',
    ),
    Goal(
      title: 'Down Payment',
      subtitle: 'House down payment fund',
      target: 100000,
      current: 12000,
      icon: Icons.home_rounded,
      color: Color(0xFFF59E0B),
      deadline: 'Dec 2028',
    ),
  ];

  static const List<ChatMessage> chatHistory = [
    ChatMessage(
      text: 'Hello! I\'m Fintell AI, your personal financial mentor. How can I help you today? 💚',
      isUser: false,
      time: '09:00',
    ),
    ChatMessage(
      text: 'Hi! Can you explain what PE Ratio means and why it matters?',
      isUser: true,
      time: '09:01',
    ),
    ChatMessage(
      text: 'Great question! The Price-to-Earnings (PE) Ratio measures how much investors pay for \$1 of a company\'s earnings.\n\n📌 Formula: Stock Price ÷ Earnings Per Share\n\n• Low PE (< 15) → may be undervalued\n• High PE (> 30) → investors expect high future growth\n\nFor example, NVDA\'s PE of 68.1x reflects massive AI growth expectations!',
      isUser: false,
      time: '09:01',
    ),
    ChatMessage(
      text: 'What about ROE? I see it on the Market page.',
      isUser: true,
      time: '09:03',
    ),
    ChatMessage(
      text: 'ROE (Return on Equity) shows how efficiently a company turns shareholders\' money into profit.\n\n📌 Formula: Net Income ÷ Shareholders\' Equity × 100%\n\n• ROE > 15% is generally good\n• AAPL\'s ROE of 160% is extraordinary — they generate massive profits relative to equity\n\nHigh-ROE companies are often great long-term compounders! 📈',
      isUser: false,
      time: '09:03',
    ),
    ChatMessage(
      text: 'Is NVDA a good buy right now?',
      isUser: true,
      time: '09:05',
    ),
    ChatMessage(
      text: 'Based on the fundamentals in our data:\n\n✅ ROE of 91.8% — excellent capital efficiency\n✅ Strong revenue growth driven by AI chip demand\n⚠️ High PE of 68.1x — priced for perfection\n⚠️ Volatile: +4.89% in a single day\n\n💡 For a simulation portfolio, NVDA offers high growth potential with higher risk. Consider limiting it to 10–15% of your portfolio.\n\nRemember: This is for educational purposes. Always do your own research! 🎓',
      isUser: false,
      time: '09:05',
    ),
  ];
}
