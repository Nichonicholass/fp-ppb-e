import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/dummy_data/app_data.dart';
import '../../core/services/storage_service.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/market_provider.dart';
import '../../shared/providers/portfolio_provider.dart';
import 'stock_detail_page.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _formattedDate() {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final market = context.watch<MarketProvider>();
    final filtered = _query.isEmpty
        ? market.stocks
        : market.stocks
            .where((s) =>
                s.ticker.toLowerCase().contains(_query) ||
                s.name.toLowerCase().contains(_query))
            .toList();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: market.fetchAll,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader(context)),
              SliverToBoxAdapter(child: _buildMarketOverview(market)),
              SliverToBoxAdapter(child: _buildSearchBar()),
              SliverToBoxAdapter(child: _buildSectionHeader(context, market)),
              // Stale-data warning banner
              if (market.isFromCache)
                SliverToBoxAdapter(
                  child: _StaleBanner(cachedAt: market.cachedAt),
                ),
              if (market.isLoading && !market.hasData)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (market.error != null && !market.hasData)
                SliverFillRemaining(
                  child: _ErrorState(
                    message: market.error,
                    onRetry: market.fetchAll,
                  ),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off_rounded,
                            size: 48, color: AppTheme.textSecondary),
                        const SizedBox(height: 12),
                        Text(
                          'No stocks match "$_query"',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _StockListTile(
                      stock: filtered[i],
                      isIDX: market.isIDX,
                    ),
                    childCount: filtered.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';
    final displayName = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : email.split('@').first;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_greeting()}, $displayName 👋',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formattedDate(),
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showProfileSheet(context),
            child: CircleAvatar(
              backgroundColor: AppTheme.primaryLight,
              radius: 22,
              backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null
                  ? Text(
                      initial,
                      style: GoogleFonts.inter(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileSheet(BuildContext context) {
    bool isUploading = false;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final user = FirebaseAuth.instance.currentUser;
          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  user?.email ?? '',
                  style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 20),
                if (isUploading)
                  const Center(child: CircularProgressIndicator())
                else
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null && user != null) {
                        setModalState(() => isUploading = true);
                        try {
                          final storageService = StorageService();
                          final file = File(pickedFile.path);
                          final url = await storageService.uploadProfilePicture(user.uid, file);
                          
                          // Update auth profile
                          if (ctx.mounted) {
                            await ctx.read<AuthProvider>().updateProfilePicture(url);
                          }
                          await user.reload(); // Reload to get the new photoUrl
                          
                          if (mounted) setState(() {});
                          
                          if (ctx.mounted) {
                            Navigator.pop(context); // Close bottom sheet
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Success'),
                                content: const Text('Profile picture updated successfully!'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  )
                                ],
                              ),
                            );
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            Navigator.pop(context); // Close bottom sheet
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Upload Failed'),
                                content: Text('Error: $e\n\nPastikan bucket "profiles" di Supabase sudah dibuat dan diset ke Public.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  )
                                ],
                              ),
                            );
                          }
                        } finally {
                          if (ctx.mounted) {
                            setModalState(() => isUploading = false);
                          }
                        }
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.camera_alt_rounded, color: AppTheme.primary, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            'Update Profile Picture',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    Navigator.pop(context);
                    await context.read<AuthProvider>().signOut();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.logout_rounded, color: AppTheme.negative, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          'Sign Out',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.negative,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMarketOverview(MarketProvider market) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market Overview',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 92,
            child: (market.isLoading && market.indices.isEmpty)
                ? ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(right: 20),
                    itemCount: 3,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) => const _IndexCardSkeleton(),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(right: 20),
                    itemCount: market.indices.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (ctx, i) => _IndexCard(index: market.indices[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppTheme.textSecondary, size: 20),
          hintText: 'Search stocks, ETFs...',
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  color: AppTheme.textSecondary,
                  onPressed: _searchController.clear,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, MarketProvider market) {
    final portfolio = context.watch<PortfolioProvider>();
    final rate = market.usdToIdrRate;
    // Format IDR balance: $10000 * 17000 = Rp 170.000.000
    final balanceIdr = portfolio.balance * rate;
    final balanceIdrStr = balanceIdr.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.'
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _query.isEmpty ? 'Popular Stocks' : 'Results',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              _MarketToggle(
                selected: market.mode,
                onChanged: (mode) => context.read<MarketProvider>().switchMode(mode),
              ),
            ],
          ),
          // Balance in IDR — only shown for IDX mode
          if (market.isIDX) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_balance_wallet_rounded,
                          size: 11, color: AppTheme.primary),
                      const SizedBox(width: 5),
                      Text(
                        'Saldo: Rp $balanceIdrStr',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Harga dalam IDR',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MarketToggle extends StatelessWidget {
  final MarketMode selected;
  final ValueChanged<MarketMode> onChanged;

  const _MarketToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleTab(
            label: 'Global',
            isSelected: selected == MarketMode.luarNegeri,
            onTap: () => onChanged(MarketMode.luarNegeri),
            isFirst: true,
          ),
          _ToggleTab(
            label: 'IDX',
            isSelected: selected == MarketMode.dalamNegeri,
            onTap: () => onChanged(MarketMode.dalamNegeri),
            isFirst: false,
          ),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isFirst;

  const _ToggleTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: isFirst ? const Radius.circular(10) : Radius.zero,
            right: !isFirst ? const Radius.circular(10) : Radius.zero,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _IndexCard extends StatelessWidget {
  final MarketIndex index;
  const _IndexCard({required this.index});

  @override
  Widget build(BuildContext context) {
    final isPositive = index.changePercent >= 0;
    return Container(
      width: 148,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            index.name,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            index.value.toStringAsFixed(2),
            style: GoogleFonts.inter(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 12,
                color: isPositive ? AppTheme.positive : AppTheme.negative,
              ),
              const SizedBox(width: 2),
              Text(
                '${isPositive ? '+' : ''}${index.changePercent.toStringAsFixed(2)}%',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? AppTheme.positive : AppTheme.negative,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _IndexCardSkeleton extends StatefulWidget {
  const _IndexCardSkeleton();
  @override
  State<_IndexCardSkeleton> createState() => _IndexCardSkeletonState();
}

class _IndexCardSkeletonState extends State<_IndexCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.4, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _bar(double w, double h) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: Container(
          width: 148,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _bar(60, 10),
              _bar(80, 18),
              _bar(50, 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _StockListTile extends StatelessWidget {
  final Stock stock;
  final bool isIDX;
  const _StockListTile({required this.stock, required this.isIDX});

  String _formatPrice(double price) {
    if (isIDX) {
      // IDX prices are in IDR (native)
      final formatted = price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]}.',
      );
      return 'Rp $formatted';
    }
    return '\$${price.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final isPositive = stock.changePercent >= 0;
    final tickerDisplay = stock.ticker.length > 4 ? stock.ticker.substring(0, 4) : stock.ticker;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => StockDetailPage(stock: stock, isIDX: isIDX),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: stock.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  tickerDisplay,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: stock.color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.ticker,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stock.name,
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                _MetricChip(label: 'PE', value: '${stock.peRatio}x'),
                const SizedBox(height: 4),
                _MetricChip(label: 'ROE', value: '${stock.roe}%'),
              ],
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatPrice(stock.price),
                  style: GoogleFonts.inter(
                    fontSize: isIDX ? 12 : 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isPositive ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isPositive ? AppTheme.positive : AppTheme.negative,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;
  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;
  const _ErrorState({required this.onRetry, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: AppTheme.textSecondary),
          const SizedBox(height: 12),
          Text(
            'Failed to load market data',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message!,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Retry',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StaleBanner extends StatelessWidget {
  final DateTime? cachedAt;

  const _StaleBanner({required this.cachedAt});

  @override
  Widget build(BuildContext context) {
    String timeStr = 'beberapa waktu lalu';
    if (cachedAt != null) {
      final difference = DateTime.now().difference(cachedAt!);
      if (difference.inMinutes < 1) {
        timeStr = 'baru saja';
      } else if (difference.inMinutes < 60) {
        timeStr = '${difference.inMinutes} menit yang lalu';
      } else if (difference.inHours < 24) {
        timeStr = '${difference.inHours} jam yang lalu';
      } else {
        timeStr = '${difference.inDays} hari yang lalu';
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7), // Amber 100
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFCD34D), width: 1), // Amber 300
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_off_rounded,
            color: Color(0xFFD97706), // Amber 600
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mode Offline / Data Lama',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF78350F), // Amber 900
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Koneksi internet gagal. Menampilkan data cache ($timeStr).',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF92400E), // Amber 800
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

