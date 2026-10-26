import 'package:flutter/material.dart';
import '../theme_tokens.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../services/firestore_service.dart';
import 'cart_screen.dart';
import 'notifications_screen.dart';
import '../widgets/delivery_hub_sheet.dart';
import '../widgets/store_product_widgets.dart';

class ShopScreen extends StatefulWidget {
  final AppState appState;

  /// Category chip selected when the screen opens (e.g. 'Cameras').
  final String initialCategory;

  /// When set, the screen is a pushed department page: the app bar shows this
  /// title with a back button instead of the delivery-hub picker.
  final String? pageTitle;

  const ShopScreen({
    super.key,
    required this.appState,
    this.initialCategory = 'All',
    this.pageTitle,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  static const int _pageSize = 8;
  static const int _initialProductCount = 12;
  static const List<String> _categories = ['All', 'Cameras', 'Lenses', 'Drones', 'Laptops', 'AC', 'TV', 'CCTV'];
  static const List<String> _sortOptions = ['Featured', 'Price: Low to High', 'Price: High to Low', 'Biggest Discount'];

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // Created once so rebuilds (typing, filters) don't resubscribe to Firestore
  late final Stream<List<ProductModel>> _productsStream;

  String _searchQuery = '';
  late String _selectedCategory = widget.initialCategory;
  String _sortBy = 'Featured';

  // Paging over the live catalogue
  int _visibleProductCount = _initialProductCount;
  int _filteredProductTotal = 0;

  @override
  void initState() {
    super.initState();
    _productsStream = FirestoreService().streamProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 600) {
      _showMoreProducts();
    }
  }

  void _showMoreProducts() {
    if (_visibleProductCount >= _filteredProductTotal) return;
    setState(() => _visibleProductCount += _pageSize);
  }

  /// Any change to search, category or sort starts the list from the top page.
  void _updateFilters(VoidCallback change) {
    setState(() {
      change();
      _visibleProductCount = _initialProductCount;
    });
  }

  List<ProductModel> _applyFilters(List<ProductModel> products) {
    final q = _searchQuery.trim().toLowerCase();
    final result = products.where((p) {
      final matchesQuery = q.isEmpty ||
          p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
      return matchesQuery && productMatchesCategory(p, _selectedCategory);
    }).toList();

    switch (_sortBy) {
      case 'Price: Low to High':
        result.sort((a, b) => a.price.compareTo(b.price));
      case 'Price: High to Low':
        result.sort((a, b) => b.price.compareTo(a.price));
      case 'Biggest Discount':
        result.sort((a, b) => b.discountPercent.compareTo(a.discountPercent));
    }
    return result;
  }

  Widget _buildCountBadge(int count) {
    return Positioned(
      right: -4,
      top: -3,
      child: Container(
        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
        decoration: BoxDecoration(
          color: SvcColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          count > 9 ? '9+' : '$count',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              height: 1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SvcColors.canvas,
      appBar: AppBar(
        titleSpacing: widget.pageTitle != null ? 0 : 14,
        iconTheme: const IconThemeData(color: SvcColors.ink),
        title: widget.pageTitle != null
            ? Text(
                widget.pageTitle!,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: SvcColors.ink,
                ),
              )
            : InkWell(
          onTap: () => showDeliveryHubSheet(context, widget.appState),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_rounded,
                    color: SvcColors.primary, size: 20),
                const SizedBox(width: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Delivering to',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: SvcColors.muted,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.appState.selectedDeliveryHub,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                            color: SvcColors.ink,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            color: SvcColors.ink, size: 18),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        backgroundColor: SvcColors.surface,
        elevation: 0.5,
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded, color: SvcColors.ink),
                if (widget.appState.unreadNotificationCount > 0)
                  _buildCountBadge(widget.appState.unreadNotificationCount),
              ],
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => NotificationsScreen(appState: widget.appState)),
            ),
          ),
          IconButton(
            tooltip: 'Cart',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_outlined, color: SvcColors.ink),
                if (widget.appState.cartCount > 0)
                  _buildCountBadge(widget.appState.cartCount),
              ],
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => CartScreen(appState: widget.appState)),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: _productsStream,
        builder: (context, snapshot) {
          final hasProducts = snapshot.hasData && !snapshot.hasError;
          final filtered = hasProducts ? _applyFilters(snapshot.data!) : const <ProductModel>[];
          _filteredProductTotal = filtered.length;
          final visible = filtered.take(_visibleProductCount).toList();
          final remaining = filtered.length - visible.length;
          final hasActiveFilters = _searchQuery.trim().isNotEmpty || _selectedCategory != 'All';

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Search & Category Container
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                      color: SvcColors.surface,
                      child: Column(
                        children: [
                          // Search Input Box
                          Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: SvcColors.canvas,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: SvcColors.border),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 12),
                                const Icon(Icons.search_rounded,
                                    size: 20, color: SvcColors.muted),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (val) =>
                                        _updateFilters(() => _searchQuery = val),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: SvcColors.ink,
                                        fontWeight: FontWeight.w600),
                                    decoration: const InputDecoration(
                                      hintText:
                                          'Search camera bodies, drones, lenses, AC...',
                                      hintStyle: TextStyle(
                                          fontSize: 13,
                                          color: SvcColors.muted,
                                          fontWeight: FontWeight.normal),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                if (_searchQuery.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.close_rounded,
                                        size: 18, color: SvcColors.muted),
                                    onPressed: () {
                                      _searchController.clear();
                                      _updateFilters(() => _searchQuery = '');
                                    },
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Horizontal Categories Rail
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: _categories.map((cat) {
                                final isSelected = _selectedCategory == cat;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: InkWell(
                                    onTap: () =>
                                        _updateFilters(() => _selectedCategory = cat),
                                    borderRadius: BorderRadius.circular(20),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 180),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? SvcColors.primary
                                            : SvcColors.canvas,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected
                                              ? SvcColors.primary
                                              : SvcColors.border,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: SvcColors.primary
                                                      .withValues(alpha: 0.25),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Text(
                                        cat,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.w800
                                              : FontWeight.w600,
                                          color: isSelected
                                              ? Colors.white
                                              : SvcColors.ink,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Sub-header Bar: Count & Sort Dropdown
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              hasProducts
                                  ? 'Showing ${filtered.length} ${filtered.length == 1 ? 'product' : 'products'}'
                                  : '',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: SvcColors.ink,
                              ),
                            ),
                          ),

                          // Sort dropdown menu
                          PopupMenuButton<String>(
                            onSelected: (val) => _updateFilters(() => _sortBy = val),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4.5),
                              decoration: BoxDecoration(
                                color: SvcColors.surface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: SvcColors.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.sort_rounded,
                                      size: 14, color: SvcColors.ink),
                                  const SizedBox(width: 4),
                                  Text(
                                    _sortBy,
                                    style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        color: SvcColors.ink),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(Icons.arrow_drop_down,
                                      size: 16, color: SvcColors.muted),
                                ],
                              ),
                            ),
                            itemBuilder: (ctx) => _sortOptions
                                .map((s) => PopupMenuItem(
                                    value: s,
                                    child: Text(s,
                                        style: const TextStyle(fontSize: 12.5))))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (snapshot.hasError)
                SliverToBoxAdapter(
                  child: StoreFeedMessage.loadError(isNe: false, what: 'products'),
                )
              else if (!snapshot.hasData)
                const StoreProductSkeletonGrid()
              else if (filtered.isEmpty)
                SliverToBoxAdapter(
                  child: hasActiveFilters
                      ? StoreFeedMessage(
                          icon: Icons.search_off_rounded,
                          title: 'No products match',
                          subtitle: 'Try another search or category, or ask us to source it for you.',
                          actionLabel: 'Clear filters',
                          onAction: () {
                            _searchController.clear();
                            _updateFilters(() {
                              _searchQuery = '';
                              _selectedCategory = 'All';
                            });
                          },
                        )
                      : const StoreFeedMessage(
                          icon: Icons.inventory_2_outlined,
                          title: 'No products yet',
                          subtitle: 'New stock is on the way. Check back soon.',
                        ),
                )
              else ...[
                // 2-Column Store Grid (lazy: only visible cards are built)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  sliver: SliverGrid(
                    gridDelegate: StoreProductCard.gridDelegate(context),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => StoreProductCard(
                        product: visible[index],
                        appState: widget.appState,
                      ),
                      childCount: visible.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 22, 14, 30),
                    child: Center(
                      child: remaining > 0
                          ? OutlinedButton.icon(
                              onPressed: _showMoreProducts,
                              icon: const Icon(Icons.arrow_downward_rounded,
                                  size: 15, color: SvcColors.primary),
                              label: Text(
                                'Show More Products ($remaining left)',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: SvcColors.ink),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 8),
                                side: const BorderSide(color: SvcColors.border),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                backgroundColor: SvcColors.canvas,
                              ),
                            )
                          : const Text(
                              'You\'re all caught up',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color: SvcColors.muted,
                                  fontWeight: FontWeight.w500),
                            ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
