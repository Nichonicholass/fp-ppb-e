import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/dummy_data/app_data.dart';
import '../../core/models/chat_session.dart';
import '../../shared/providers/ai_mentor_provider.dart';
import '../../shared/providers/portfolio_provider.dart';

class AiMentorPage extends StatefulWidget {
  const AiMentorPage({super.key});

  @override
  State<AiMentorPage> createState() => _AiMentorPageState();
}

class _AiMentorPageState extends State<AiMentorPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage([String? text]) {
    final content = (text ?? _controller.text).trim();
    if (content.isEmpty) return;
    _controller.clear();

    final portfolio = context.read<PortfolioProvider>();
    final portfolioContext = _buildPortfolioContext(portfolio);

    context.read<AiMentorProvider>().sendMessage(
          content,
          portfolioContext: portfolioContext.isNotEmpty ? portfolioContext : null,
        );
  }

  String _buildPortfolioContext(PortfolioProvider p) {
    if (p.holdings.isEmpty) return '';
    final holdingsSummary = p.holdings.map((h) => '${h.stock.ticker} x${h.shares}').join(', ');
    return 'Total portfolio value: \$${p.portfolioValue.toStringAsFixed(2)}, '
        'Cash balance: \$${p.balance.toStringAsFixed(2)}, '
        'Holdings: $holdingsSummary';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mentor = context.watch<AiMentorProvider>();

    if (mentor.messages.isNotEmpty || mentor.isLoading) _scrollToBottom();

    return Scaffold(
      drawer: const _ChatHistoryDrawer(),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fintell AI',
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                Text(
                  mentor.currentSession?.title ?? 'Financial Mentor',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppTheme.positive,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            tooltip: 'New chat',
            onPressed: () => context.read<AiMentorProvider>().startNewSession(),
          ),
        ],
      ),
      body: Column(
        children: [
          _SuggestedQuestions(onTap: _sendMessage),
          if (mentor.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.red.shade50,
              child: Text(
                mentor.error!,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.red.shade700),
              ),
            ),
          Expanded(
            child: mentor.messages.isEmpty && !mentor.isLoading
                ? const _EmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    itemCount: mentor.messages.length + (mentor.isLoading ? 1 : 0),
                    itemBuilder: (ctx, i) {
                      if (i == mentor.messages.length) return const _TypingIndicator();
                      return _ChatBubble(message: mentor.messages[i]);
                    },
                  ),
          ),
          _InputBar(controller: _controller, onSend: () => _sendMessage()),
        ],
      ),
    );
  }
}

// ─── History Drawer ──────────────────────────────────────────────────────────

class _ChatHistoryDrawer extends StatelessWidget {
  const _ChatHistoryDrawer();

  @override
  Widget build(BuildContext context) {
    return Consumer<AiMentorProvider>(
      builder: (context, mentor, _) {
        return Drawer(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Chat History',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_rounded, color: Colors.white),
                        tooltip: 'New chat',
                        onPressed: () {
                          context.read<AiMentorProvider>().startNewSession();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                // Session list
                Expanded(
                  child: mentor.sessions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded,
                                  size: 40, color: AppTheme.textTertiary),
                              const SizedBox(height: 12),
                              Text(
                                'No chats yet',
                                style: GoogleFonts.inter(
                                    fontSize: 14, color: AppTheme.textTertiary),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: mentor.sessions.length,
                          itemBuilder: (ctx, i) {
                            final session = mentor.sessions[i];
                            final isActive = mentor.currentSession?.id == session.id;
                            return _SessionTile(
                              session: session,
                              isActive: isActive,
                              onTap: () {
                                context.read<AiMentorProvider>().switchSession(session);
                                Navigator.pop(context);
                              },
                              onDelete: () => _confirmDelete(context, mentor, session),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, AiMentorProvider mentor, ChatSession session) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete chat?', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
        content: Text(
          '"${session.title}"',
          style: GoogleFonts.inter(fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              mentor.deleteSession(session.id);
            },
            child: Text('Delete', style: GoogleFonts.inter(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final ChatSession session;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SessionTile({
    required this.session,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: isActive ? AppTheme.primaryLight : Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 15,
                color: isActive ? Colors.white : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      color: isActive ? AppTheme.primaryDark : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(session.updatedAt),
                    style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textTertiary),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 17),
              color: AppTheme.textTertiary,
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sessionDay = DateTime(date.year, date.month, date.day);

    if (sessionDay == today) {
      return 'Today · ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    if (sessionDay == yesterday) return 'Yesterday';

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

// ─── Empty State ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            'How can I help you?',
            style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask me anything about investing\nand personal finance.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─── Suggested Questions ─────────────────────────────────────────────────────

class _SuggestedQuestions extends StatelessWidget {
  final void Function(String) onTap;
  const _SuggestedQuestions({required this.onTap});

  static const _questions = [
    'What is diversification?',
    'Explain dollar-cost averaging',
    'Best stocks for beginners?',
    'How to read a balance sheet?',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.divider)),
      ),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _questions.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (ctx, i) => GestureDetector(
            onTap: () => onTap(_questions[i]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _questions[i],
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.primaryDark,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Chat Bubble ─────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? AppTheme.primary : AppTheme.surface,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isUser ? Colors.white : AppTheme.textPrimary,
                      height: 1.55,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message.time,
                  style: GoogleFonts.inter(fontSize: 10, color: AppTheme.textTertiary),
                ),
              ],
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

// ─── Typing Indicator ─────────────────────────────────────────────────────────

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(delay: 0),
                const SizedBox(width: 4),
                _Dot(delay: 150),
                const SizedBox(width: 4),
                _Dot(delay: 300),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: 7,
        height: 7,
        decoration: const BoxDecoration(
          color: AppTheme.textTertiary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ─── Input Bar ───────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              style: GoogleFonts.inter(fontSize: 14),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              decoration: const InputDecoration(hintText: 'Ask Fintell AI anything...'),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}
