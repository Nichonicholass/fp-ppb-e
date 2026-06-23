import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/dummy_data/app_data.dart';
import '../../shared/providers/watchlist_provider.dart';
import '../../shared/providers/market_provider.dart';
import '../market/stock_detail_page.dart';

bool _isIdxStock(Stock stock) => stock.symbol.toUpperCase().endsWith('.JK');

String _formatStockPrice(Stock stock) {
  if (stock.price <= 0) return 'N/A';

  if (_isIdxStock(stock)) {
    final formatted = stock.price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

  return '\$${stock.price.toStringAsFixed(2)}';
}

String _sortLabel(WatchlistSort sort) {
  switch (sort) {
    case WatchlistSort.custom:
      return 'Custom';
    case WatchlistSort.ticker:
      return 'Ticker';
    case WatchlistSort.name:
      return 'Name';
    case WatchlistSort.price:
      return 'Price';
    case WatchlistSort.change:
      return 'Change';
    case WatchlistSort.peRatio:
      return 'PE';
    case WatchlistSort.roe:
      return 'ROE';
    case WatchlistSort.dateAdded:
      return 'Added';
  }
}

String _filterLabel(WatchlistFilter filter) {
  switch (filter) {
    case WatchlistFilter.all:
      return 'All';
    case WatchlistFilter.gainers:
      return 'Gainers';
    case WatchlistFilter.losers:
      return 'Losers';
    case WatchlistFilter.pinned:
      return 'Pinned';
  }
}

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {
  String _selectedListId = 'technology';
  WatchlistSort _sort = WatchlistSort.custom;
  WatchlistFilter _filter = WatchlistFilter.all;

  WatchlistGroup? _activeList(List<WatchlistGroup> lists) {
    if (lists.isEmpty) return null;
    for (final list in lists) {
      if (list.id == _selectedListId) return list;
    }
    return lists.first;
  }

  void _selectList(String id) {
    setState(() {
      _selectedListId = id;
      _sort = WatchlistSort.custom;
      _filter = WatchlistFilter.all;
    });
  }

  void _onRemove(String listId, WatchlistItem item, int index) {
    final provider = context.read<WatchlistProvider>();
    provider.removeStock(listId, item.stock.ticker);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Removed ${item.stock.ticker} from watchlist',
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
            onPressed: () => provider.insertStock(listId, index, item.stock),
          ),
        ),
      );
  }

  Future<void> _showListDialog({
    required String title,
    String? initialName,
    required void Function(String name) onSubmit,
  }) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _WatchlistNameDialog(
        title: title,
        initialName: initialName,
      ),
    );

    final cleanName = name?.trim();
    if (cleanName == null || cleanName.isEmpty) return;
    onSubmit(cleanName);
  }

  Future<void> _confirmDeleteList(WatchlistGroup list) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete watchlist?'),
          content: Text(
            '${list.name} and its saved stocks will be removed from this watchlist.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !mounted) return;
    final provider = context.read<WatchlistProvider>();
    provider.deleteList(list.id);
    final lists = provider.lists;
    if (lists.isNotEmpty) {
      setState(() {
        _selectedListId = lists.first.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WatchlistProvider>();
    final lists = provider.lists;
    final activeList = _activeList(lists);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
        actions: [
          IconButton(
            tooltip: 'Add stock',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.add_rounded,
                color: AppTheme.primary,
                size: 18,
              ),
            ),
            onPressed: activeList == null
                ? null
                : () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => _AddStockBottomSheet(
                        initialListId: activeList.id,
                      ),
                    );
                  },
          ),
          PopupMenuButton<String>(
            tooltip: 'Manage watchlists',
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (value) {
              if (value == 'create') {
                _showListDialog(
                  title: 'New Watchlist',
                  onSubmit: (name) {
                    final id = context.read<WatchlistProvider>().createList(name);
                    _selectList(id);
                  },
                );
              } else if (value == 'rename' && activeList != null) {
                _showListDialog(
                  title: 'Rename Watchlist',
                  initialName: activeList.name,
                  onSubmit: (name) {
                    context.read<WatchlistProvider>().renameList(activeList.id, name);
                  },
                );
              } else if (value == 'delete' && activeList != null) {
                _confirmDeleteList(activeList);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'create',
                child: ListTile(
                  leading: Icon(Icons.add_rounded),
                  title: Text('New watchlist'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'rename',
                enabled: activeList != null && provider.canEditList(activeList.id),
                child: const ListTile(
                  leading: Icon(Icons.edit_outlined),
                  title: Text('Rename current'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                enabled: activeList != null && provider.canDeleteList(activeList.id),
                child: const ListTile(
                  leading: Icon(Icons.delete_outline_rounded),
                  title: Text('Delete current'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: activeList == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _WatchlistSelector(
                  lists: lists,
                  activeListId: activeList.id,
                  onSelected: _selectList,
                ),
                _SortFilterBar(
                  sort: _sort,
                  filter: _filter,
                  onSortChanged: (sort) => setState(() => _sort = sort),
                  onFilterChanged: (filter) => setState(() => _filter = filter),
                ),
                Expanded(
                  child: _WatchlistContent(
                    list: activeList,
                    sort: _sort,
                    filter: _filter,
                    onRemove: (item, index) => _onRemove(activeList.id, item, index),
                  ),
                ),
              ],
            ),
    );
  }
}

class _WatchlistSelector extends StatelessWidget {
  final List<WatchlistGroup> lists;
  final String activeListId;
  final void Function(String id) onSelected;

  const _WatchlistSelector({
    required this.lists,
    required this.activeListId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        itemCount: lists.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final list = lists[index];
          final selected = list.id == activeListId;
          return ChoiceChip(
            selected: selected,
            label: Text('${list.name} (${list.items.length})'),
            onSelected: (_) => onSelected(list.id),
            backgroundColor: AppTheme.surface,
            selectedColor: AppTheme.primaryLight,
            labelStyle: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected ? AppTheme.primaryDark : AppTheme.textSecondary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(
                color: selected ? AppTheme.primary : AppTheme.surfaceVariant,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SortFilterBar extends StatelessWidget {
  final WatchlistSort sort;
  final WatchlistFilter filter;
  final void Function(WatchlistSort sort) onSortChanged;
  final void Function(WatchlistFilter filter) onFilterChanged;

  const _SortFilterBar({
    required this.sort,
    required this.filter,
    required this.onSortChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Row(
        children: [
          _ControlMenu<WatchlistSort>(
            icon: Icons.sort_rounded,
            label: _sortLabel(sort),
            values: WatchlistSort.values,
            valueLabel: _sortLabel,
            onSelected: onSortChanged,
          ),
          const SizedBox(width: 8),
          _ControlMenu<WatchlistFilter>(
            icon: Icons.filter_list_rounded,
            label: _filterLabel(filter),
            values: WatchlistFilter.values,
            valueLabel: _filterLabel,
            onSelected: onFilterChanged,
          ),
          const Spacer(),
          if (sort == WatchlistSort.custom && filter == WatchlistFilter.all)
            Text(
              'Drag to reorder',
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppTheme.textTertiary,
              ),
            ),
        ],
      ),
    );
  }
}

class _ControlMenu<T> extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<T> values;
  final String Function(T value) valueLabel;
  final void Function(T value) onSelected;

  const _ControlMenu({
    required this.icon,
    required this.label,
    required this.values,
    required this.valueLabel,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      onSelected: onSelected,
      itemBuilder: (context) => values
          .map(
            (value) => PopupMenuItem(
              value: value,
              child: Text(valueLabel(value)),
            ),
          )
          .toList(),
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.surfaceVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _WatchlistContent extends StatelessWidget {
  final WatchlistGroup list;
  final WatchlistSort sort;
  final WatchlistFilter filter;
  final void Function(WatchlistItem item, int index) onRemove;

  const _WatchlistContent({
    required this.list,
    required this.sort,
    required this.filter,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WatchlistProvider>();
    final items = provider.getSortedFilteredStocks(
      list.id,
      sort: sort,
      filter: filter,
    );

    if (items.isEmpty) {
      return _EmptyState(
        listName: list.name,
        filtered: filter != WatchlistFilter.all,
      );
    }

    final canReorder = sort == WatchlistSort.custom && filter == WatchlistFilter.all;

    return RefreshIndicator(
      onRefresh: () async {
        await Future.wait([
          context.read<MarketProvider>().fetchAll(),
          context.read<WatchlistProvider>().fetchWatchlistPrices(),
        ]);
      },
      color: AppTheme.primary,
      backgroundColor: Colors.white,
      child: canReorder
          ? ReorderableListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: items.length,
              onReorder: (oldIndex, newIndex) {
                context.read<WatchlistProvider>().reorderItem(
                      list.id,
                      oldIndex,
                      newIndex,
                    );
              },
              itemBuilder: (context, i) {
                final item = items[i];
                return Padding(
                  key: ValueKey('${list.id}_${item.stock.ticker}'),
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Dismissible(
                    key: ValueKey('${list.id}_${item.stock.ticker}_dismiss'),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => onRemove(item, i),
                    background: const _SwipeBackground(),
                    child: _WatchlistTile(listId: list.id, item: item),
                  ),
                );
              },
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) {
                final item = items[i];
                return Dismissible(
                  key: ValueKey('${list.id}_${item.stock.ticker}'),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => onRemove(item, i),
                  background: const _SwipeBackground(),
                  child: _WatchlistTile(listId: list.id, item: item),
                );
              },
            ),
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
          Icon(
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
  final String listName;
  final bool filtered;

  const _EmptyState({
    required this.listName,
    required this.filtered,
  });

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
            child: Icon(
              Icons.bookmark_outline_rounded,
              color: AppTheme.primary,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            filtered ? 'No matching stocks' : 'No stocks yet',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            filtered
                ? 'Try another filter for $listName'
                : 'Tap + to add stocks\nto $listName',
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
  final String listId;
  final WatchlistItem item;

  const _WatchlistTile({
    required this.listId,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final stock = item.stock;
    final isPositive = stock.changePercent >= 0;
    final tickerDisplay =
        stock.ticker.length > 4 ? stock.ticker.substring(0, 4) : stock.ticker;
    final isIDX = context.read<MarketProvider>().isIDX;

    return Material(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StockDetailPage(
                stock: stock,
                isIDX: isIDX,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            stock.ticker,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: item.pinned ? 'Unpin' : 'Pin',
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            item.pinned
                                ? Icons.push_pin_rounded
                                : Icons.push_pin_outlined,
                            size: 17,
                            color: item.pinned
                                ? AppTheme.primary
                                : AppTheme.textTertiary,
                          ),
                          onPressed: () {
                            context
                                .read<WatchlistProvider>()
                                .togglePinned(listId, stock.ticker);
                          },
                        ),
                      ],
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
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        _Tag(label: 'PE ${stock.peRatio}x'),
                        _Tag(label: 'ROE ${stock.roe}%'),
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
                    _formatStockPrice(stock),
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
        ),
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
  final String initialListId;
  const _AddStockBottomSheet({required this.initialListId});

  @override
  State<_AddStockBottomSheet> createState() => _AddStockBottomSheetState();
}

class _AddStockBottomSheetState extends State<_AddStockBottomSheet> {
  late String _selectedListId;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedListId = widget.initialListId;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  WatchlistGroup _targetList(List<WatchlistGroup> lists) {
    for (final list in lists) {
      if (list.id == _selectedListId) return list;
    }
    _selectedListId = lists.first.id;
    return lists.first;
  }

  @override
  Widget build(BuildContext context) {
    final marketProvider = context.watch<MarketProvider>();
    final watchlistProvider = context.watch<WatchlistProvider>();
    final lists = watchlistProvider.lists;
    final targetList = _targetList(lists);

    final allStocks = marketProvider.stocks;
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Target Watchlist',
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
                      value: targetList.id,
                      dropdownColor: Colors.white,
                      icon: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.primary,
                        size: 18,
                      ),
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                      items: lists
                          .map(
                            (list) => DropdownMenuItem(
                              value: list.id,
                              child: Text(list.name),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedListId = val;
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
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppTheme.textTertiary,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
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
          Expanded(
            child: marketProvider.isLoading
                ? Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  )
                : filteredStocks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
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
                              .isWatchedInSector(_selectedListId, stock.ticker);

                          return _BottomSheetStockTile(
                            stock: stock,
                            isAdded: isAlreadyAdded,
                            onAdd: () {
                              watchlistProvider.addStock(_selectedListId, stock);
                              Navigator.pop(context);

                              ScaffoldMessenger.of(context)
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Added ${stock.ticker} to ${targetList.name}',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: Colors.white,
                                      ),
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    backgroundColor: AppTheme.primaryDark,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatStockPrice(stock),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(width: 12),
              isAdded
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Added',
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
                        child: Icon(
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

class _WatchlistNameDialog extends StatefulWidget {
  final String title;
  final String? initialName;

  const _WatchlistNameDialog({
    required this.title,
    this.initialName,
  });

  @override
  State<_WatchlistNameDialog> createState() => _WatchlistNameDialogState();
}

class _WatchlistNameDialogState extends State<_WatchlistNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Watchlist name',
          prefixIcon: Icon(Icons.bookmarks_outlined),
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (value) => Navigator.pop(context, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
