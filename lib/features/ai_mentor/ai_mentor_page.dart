import 'package:firebase_auth/firebase_auth.dart';
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
    final holdingsSummary =
        p.holdings.map((h) => '${h.stock.ticker} x${h.shares}').join(', ');
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
    final hasChat = mentor.messages.isNotEmpty || mentor.isLoading;

    if (hasChat) _scrollToBottom();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.background,
      drawer: const _ChatHistoryDrawer(),
      appBar: hasChat
          ? AppBar(
              backgroundColor: AppTheme.background,
              elevation: 0,
              scrolledUnderElevation: 0.5,
              shadowColor: AppTheme.divider,
              leading: Builder(
                builder: (ctx) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  color: AppTheme.textSecondary,
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
              ),
              title: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 17),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fintell AI',
                          style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary)),
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
                  color: AppTheme.textSecondary,
                  tooltip: 'New chat',
                  onPressed: () =>
                      context.read<AiMentorProvider>().startNewSession(),
                ),
              ],
            )
          : null,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: hasChat
            ? _buildChatBody(context, mentor)
            : _LandingView(
                key: const ValueKey('landing'),
                scaffoldKey: _scaffoldKey,
                controller: _controller,
                onSend: (t) => _sendMessage(t),
                error: mentor.error,
              ),
      ),
    );
  }

  Widget _buildChatBody(BuildContext context, AiMentorProvider mentor) {
    return Column(
      key: const ValueKey('chat'),
      children: [
        if (mentor.error != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.red.shade50,
            child: Text(
              mentor.error!,
              style:
                  GoogleFonts.inter(fontSize: 12, color: Colors.red.shade700),
            ),
          ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount:
                mentor.messages.length + (mentor.isLoading ? 1 : 0),
            itemBuilder: (ctx, i) {
              if (i == mentor.messages.length) {
                final streaming = mentor.streamingText;
                if (streaming != null && streaming.isNotEmpty) {
                  return _ChatBubble(
                    message: ChatMessage(
                        text: streaming, isUser: false, time: ''),
                  );
                }
                return const _TypingIndicator();
              }
              return _ChatBubble(message: mentor.messages[i]);
            },
          ),
        ),
        _InputBar(controller: _controller, onSend: () => _sendMessage()),
      ],
    );
  }
}

// ─── Landing View (Gemini-style, light) ───────────────────────────────────────

class _LandingView extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final TextEditingController controller;
  final void Function(String) onSend;
  final String? error;

  const _LandingView({
    super.key,
    required this.scaffoldKey,
    required this.controller,
    required this.onSend,
    this.error,
  });

  static const _suggestions = [
    (Icons.pie_chart_rounded, 'Coba analisis portofolio saya'),
    (Icons.trending_up_rounded, 'Saham apa yang cocok untuk pemula?'),
    (Icons.bar_chart_rounded, 'Jelaskan strategi dollar-cost averaging'),
    (Icons.lightbulb_rounded, 'Bagaimana cara membaca laporan keuangan?'),
  ];

  static String _firstName(User? user) {
    final name = user?.displayName ?? '';
    if (name.isNotEmpty) return name.split(' ').first;
    final email = user?.email ?? '';
    if (email.isNotEmpty) return email.split('@').first;
    return 'there';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = _firstName(user);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Top bar ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  color: AppTheme.textSecondary,
                  onPressed: () => scaffoldKey.currentState?.openDrawer(),
                ),
                IconButton(
                  icon: const Icon(Icons.add_comment_outlined),
                  color: AppTheme.textSecondary,
                  tooltip: 'New chat',
                  onPressed: () =>
                      context.read<AiMentorProvider>().startNewSession(),
                ),
              ],
            ),
          ),

          // ── Centered scrollable content ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 48),

                  // AI avatar
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.25),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(height: 24),

                  // Greeting
                  Text(
                    'Hello, $name!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'What would you like to learn\nabout investing today?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Suggestion cards
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.5,
                    children: _suggestions.map((s) {
                      final (icon, text) = s;
                      return _SuggestionCard(
                        icon: icon,
                        text: text,
                        onTap: () => onSend(text),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // ── Error bar ──
          if (error != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.red.shade50,
              child: Text(
                error!,
                style: GoogleFonts.inter(
                    fontSize: 12, color: Colors.red.shade700),
              ),
            ),

          // ── Input bar (Gemini-style pill, light) ──
          _LandingInputBar(controller: controller, onSend: onSend),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  const _SuggestionCard(
      {required this.icon, required this.text, required this.onTap});

  @override
  State<_SuggestionCard> createState() => _SuggestionCardState();
}

class _SuggestionCardState extends State<_SuggestionCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _hovered ? AppTheme.primaryLight : AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered ? AppTheme.primary : AppTheme.divider,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(widget.icon, color: AppTheme.primary, size: 20),
              const Spacer(),
              Text(
                widget.text,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: AppTheme.textPrimary,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Landing Input Bar (pill, light) ─────────────────────────────────────────

class _LandingInputBar extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onSend;

  const _LandingInputBar(
      {required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 12 + bottomPadding),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 6, 8, 6),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppTheme.divider),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppTheme.textPrimary),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (v) {
                  final t = v.trim();
                  if (t.isNotEmpty) onSend(t);
                },
                decoration: InputDecoration(
                  hintText: 'Ask Fintell AI...',
                  hintStyle: GoogleFonts.inter(
                      fontSize: 14, color: AppTheme.textTertiary),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10),
                  filled: false,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                final t = controller.text.trim();
                if (t.isNotEmpty) onSend(t);
              },
              child: Container(
                width: 38,
                height: 38,
                margin: const EdgeInsets.only(bottom: 2),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_upward_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── History Drawer (light) ───────────────────────────────────────────────────

class _ChatHistoryDrawer extends StatelessWidget {
  const _ChatHistoryDrawer();

  @override
  Widget build(BuildContext context) {
    return Consumer<AiMentorProvider>(
      builder: (context, mentor, _) {
        return Drawer(
          backgroundColor: AppTheme.background,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 14),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppTheme.divider),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.auto_awesome_rounded,
                            color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Chat History',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_rounded),
                        color: AppTheme.textSecondary,
                        tooltip: 'New chat',
                        onPressed: () {
                          context
                              .read<AiMentorProvider>()
                              .startNewSession();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: mentor.sessions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline_rounded,
                                  size: 40,
                                  color: AppTheme.textTertiary),
                              const SizedBox(height: 12),
                              Text(
                                'No chats yet',
                                style: GoogleFonts.inter(
                                    fontSize: 14,
                                    color: AppTheme.textTertiary),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(vertical: 8),
                          itemCount: mentor.sessions.length,
                          itemBuilder: (ctx, i) {
                            final session = mentor.sessions[i];
                            final isActive =
                                mentor.currentSession?.id == session.id;
                            return _SessionTile(
                              session: session,
                              isActive: isActive,
                              onTap: () {
                                context
                                    .read<AiMentorProvider>()
                                    .switchSession(session);
                                Navigator.pop(context);
                              },
                              onDelete: () =>
                                  _confirmDelete(context, mentor, session),
                              onRename: () =>
                                  _confirmRename(context, mentor, session),
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

  void _confirmDelete(BuildContext context, AiMentorProvider mentor,
      ChatSession session) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: Text('Delete chat?',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        content: Text(
          '"${session.title}"',
          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondary),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              mentor.deleteSession(session.id);
            },
            child: Text('Delete',
                style: GoogleFonts.inter(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmRename(BuildContext context, AiMentorProvider mentor,
      ChatSession session) {
    final controller = TextEditingController(text: session.title);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.background,
        title: Text('Rename chat',
            style: GoogleFonts.inter(
                fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 60,
          style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter new name...',
            hintStyle: GoogleFonts.inter(color: AppTheme.textTertiary),
            counterStyle: GoogleFonts.inter(
                fontSize: 11, color: AppTheme.textTertiary),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primary),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.divider),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: GoogleFonts.inter(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                mentor.renameSession(session.id, newName);
              }
              Navigator.pop(ctx);
            },
            child: Text('Save',
                style: GoogleFonts.inter(
                    color: AppTheme.primary, fontWeight: FontWeight.w600)),
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
  final VoidCallback onRename;

  const _SessionTile({
    required this.session,
    required this.isActive,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: isActive ? AppTheme.primaryLight : Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primary : AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                size: 15,
                color:
                    isActive ? Colors.white : AppTheme.textSecondary,
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
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isActive
                          ? AppTheme.primaryDark
                          : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(session.updatedAt),
                    style: GoogleFonts.inter(
                        fontSize: 11, color: AppTheme.textTertiary),
                  ),
                ],
              ),
            ),
            // Rename button
            IconButton(
              icon: const Icon(Icons.drive_file_rename_outline_rounded, size: 17),
              color: AppTheme.textTertiary,
              onPressed: onRename,
              tooltip: 'Rename',
              padding: EdgeInsets.zero,
              constraints:
                  const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            // Delete button
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 17),
              color: AppTheme.textTertiary,
              onPressed: onDelete,
              tooltip: 'Delete',
              padding: EdgeInsets.zero,
              constraints:
                  const BoxConstraints(minWidth: 32, minHeight: 32),
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
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}

// ─── Chat Bubble (light) ──────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF059669)]),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? AppTheme.primary : AppTheme.surface,
                    border: isUser
                        ? null
                        : Border.all(color: AppTheme.divider),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft:
                          Radius.circular(isUser ? 16 : 4),
                      bottomRight:
                          Radius.circular(isUser ? 4 : 16),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isUser
                          ? Colors.white
                          : AppTheme.textPrimary,
                      height: 1.55,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message.time,
                  style: GoogleFonts.inter(
                      fontSize: 10, color: AppTheme.textTertiary),
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

// ─── Typing Indicator (light) ─────────────────────────────────────────────────

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)]),
              borderRadius: BorderRadius.circular(9),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border.all(color: AppTheme.divider),
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
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
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
        decoration: BoxDecoration(
          color: AppTheme.textTertiary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ─── Chat Input Bar (light) ───────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _InputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding:
          EdgeInsets.fromLTRB(16, 10, 16, 12 + bottomPadding),
      decoration: BoxDecoration(
        color: AppTheme.background,
        border: const Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 6, 8, 6),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppTheme.textPrimary),
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Ask Fintell AI anything...',
                  hintStyle: GoogleFonts.inter(
                      fontSize: 14, color: AppTheme.textTertiary),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10),
                  filled: false,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSend,
              child: Container(
                width: 38,
                height: 38,
                margin: const EdgeInsets.only(bottom: 2),
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_upward_rounded,
                    color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
