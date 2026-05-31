import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/dummy_data/app_data.dart';
import '../../shared/providers/watchlist_provider.dart';
import '../../shared/providers/market_provider.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _sectors = ['Technology', 'Finance', 'Healthcare'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _sectors.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _onRemove(String sector, Stock stock, int index) {
    final provider = context.read<WatchlistProvider>();
    provider.removeStock(sector, stock.ticker);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Removed ${stock.ticker} from watchlist',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppTheme.primary,
            onPressed: () => provider.insertStock(sector, index, stock),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppTheme.primary,
                size: 18,
              ),
            ),
            onPressed: () {
              final activeSector = _sectors[_tabController.index];
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => _AddStockBottomSheet(
                  initialSector: activeSector,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 2.5,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle:
              GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400),
          tabs: const [
            Tab(text: 'Technology'),
            Tab(text: 'Finance'),
            Tab(text: 'Healthcare'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _sectors
            .map(
              (sector) => _SectorList(
                sector: sector,
                onRemove: (stock, index) => _onRemove(sector, stock, index),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SectorList extends StatelessWidget {
  final String sector;
  final void Function(Stock stock, int index) onRemove;

  const _SectorList({required this.sector, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final stocks = context.watch<WatchlistProvider>().getStocks(sector);

    if (stocks.isEmpty) {
      return _EmptyState(sector: sector);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: stocks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) {
        final stock = stocks[i];
        return Dismissible(
          key: ValueKey('${sector}_${stock.ticker}'),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onRemove(stock, i),
          background: const _SwipeBackground(),
          child: _WatchlistTile(stock: stock),
        );
      },
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.delete_outline_rounded,
            color: AppTheme.negative,
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            'Remove',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.negative,
            ),
          ),
        ],
      ),
    );
  }
}


class _EmptyState extends StatelessWidget {
  final String sector;
  const _EmptyState({required this.sector});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.bookmark_outline_rounded,
              color: AppTheme.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No stocks yet',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap + to add $sector stocks\nto your watchlist',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _WatchlistTile extends StatelessWidget {
  final Stock stock;
  const _WatchlistTile({required this.stock});

  @override
  Widget build(BuildContext context) {
    final isPositive = stock.changePercent >= 0;
    final tickerDisplay =
        stock.ticker.length > 4 ? stock.ticker.substring(0, 4) : stock.ticker;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
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
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  stock.name,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    _Tag(label: 'PE ${stock.peRatio}x'),
                    const SizedBox(width: 6),
                    _Tag(label: 'ROE ${stock.roe}%'),
                    const SizedBox(width: 6),
                    _Tag(label: stock.sector),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${stock.price.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? const Color(0xFFD1FAE5)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${isPositive ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? AppTheme.positive : AppTheme.negative,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}

class _AddStockBottomSheet extends StatefulWidget {
  final String initialSector;
  const _AddStockBottomSheet({required this.initialSector});

  @override
  State<_AddStockBottomSheet> createState() => _AddStockBottomSheetState();
}

class _AddStockBottomSheetState extends State<_AddStockBottomSheet> {
  late String _selectedSector;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const _sectors = ['Technology', 'Finance', 'Healthcare'];

  @override
  void initState() {
    super.initState();
    _selectedSector = widget.initialSector;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final marketProvider = context.watch<MarketProvider>();
    final watchlistProvider = context.watch<WatchlistProvider>();

    final allStocks = marketProvider.stocks;

    // Filter stocks based on search query
    final filteredStocks = allStocks.where((stock) {
      final q = _searchQuery.toLowerCase();
      return stock.ticker.toLowerCase().contains(q) ||
          stock.name.toLowerCase().contains(q);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add Stock',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Sector selector row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Target Sector',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedSector,
                      dropdownColor: Colors.white,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.primary,
                        size: 18,
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                      items: _sectors
                          .map((sector) => DropdownMenuItem(
                                value: sector,
                                child: Text(sector),
                              ))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedSector = val;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Search input field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search stock name or ticker...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppTheme.textTertiary,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          color: AppTheme.textTertiary,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Stock list content
          Expanded(
            child: marketProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  )
                : filteredStocks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              color: AppTheme.textTertiary,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No stocks found',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: filteredStocks.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 8),
                        itemBuilder: (ctx, index) {
                          final stock = filteredStocks[index];
                          final isAlreadyAdded = watchlistProvider
                              .isWatchedInSector(_selectedSector, stock.ticker);

                          return _BottomSheetStockTile(
                            stock: stock,
                            isAdded: isAlreadyAdded,
                            onAdd: () {
                              watchlistProvider.addStock(_selectedSector, stock);
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Added ${stock.ticker} to $_selectedSector watchlist',
                                      style: GoogleFonts.inter(
                                          fontSize: 13, color: Colors.white),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: AppTheme.primaryDark,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.fromLTRB(
                                        16, 0, 16, 12),
                                    duration: const Duration(seconds: 3),
                                  ),
                                );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetStockTile extends StatelessWidget {
  final Stock stock;
  final bool isAdded;
  final VoidCallback onAdd;

  const _BottomSheetStockTile({
    required this.stock,
    required this.isAdded,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final tickerDisplay =
        stock.ticker.length > 4 ? stock.ticker.substring(0, 4) : stock.ticker;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceVariant),
      ),
      child: Row(
        children: [
          // Logo Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: stock.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
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

          // Ticker & Name
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
                Text(
                  stock.name,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Price & Status Badge/Button
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '\$${stock.price.toStringAsFixed(2)}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              isAdded
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '✓ Added',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    )
                  : InkWell(
                      onTap: onAdd,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: AppTheme.primary,
                          size: 18,
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
