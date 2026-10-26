import 'package:flutter/material.dart';
import '../theme_tokens.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../services/firestore_service.dart';
import '../widgets/delivery_hub_sheet.dart';
import '../widgets/used_product_cards.dart';
import '../widgets/used_filter_sheet.dart';
import '../widgets/used_inspection_sheets.dart';
import '../widgets/store_product_widgets.dart';
import '../data/used_products_data.dart';
import 'notifications_screen.dart';
import 'cart_screen.dart';
import 'trade_in_screen.dart';
import 'source_screen.dart';

class UsedProductsScreen extends StatefulWidget {
  final AppState appState;

  const UsedProductsScreen({super.key, required this.appState});

  @override
  State<UsedProductsScreen> createState() => _UsedProductsScreenState();
}

class _UsedProductsScreenState extends State<UsedProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedGrade = 'All';
  String _sortBy = 'Featured';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedCategory != 'All') count++;
    if (_selectedGrade != 'All') count++;
    if (_sortBy != 'Featured') count++;
    return count;
  }

  void _openFilterSheet() {
    UsedFilterSheet.show(
      context: context,
      currentCategory: _selectedCategory,
      currentGrade: _selectedGrade,
      currentSortBy: _sortBy,
      onApply: (cat, gr, sort) {
        setState(() {
          _selectedCategory = cat;
          _selectedGrade = gr;
          _sortBy = sort;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SvcColors.canvas,
      appBar: AppBar(
        titleSpacing: 14,
        title: InkWell(
          onTap: () => showDeliveryHubSheet(context, widget.appState),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_rounded, color: SvcColors.primary, size: 20),
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
                        const Icon(Icons.keyboard_arrow_down_rounded, color: SvcColors.ink, size: 18),
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
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: SvcColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${widget.appState.unreadNotificationCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NotificationsScreen(appState: widget.appState),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Cart',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_outlined, color: SvcColors.ink),
                if (widget.appState.cartCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: SvcColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${widget.appState.cartCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CartScreen(appState: widget.appState),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: StreamBuilder<List<UsedProductModel>>(
        stream: FirestoreService().streamUsedProducts(),
        builder: (context, snapshot) {
          final allItems = snapshot.data ?? const <UsedProductModel>[];

          final query = _searchController.text.toLowerCase().trim();
          final filtered = allItems.where((item) {
            final matchesQuery = query.isEmpty ||
                item.name.toLowerCase().contains(query) ||
                item.brand.toLowerCase().contains(query) ||
                (item.model?.toLowerCase().contains(query) ?? false);

            final matchesCategory = _selectedCategory == 'All' ||
                item.categoryName.toLowerCase() == _selectedCategory.toLowerCase();

            final matchesGrade = _selectedGrade == 'All' ||
                item.conditionGrade.toUpperCase() == _selectedGrade.toUpperCase();

            return matchesQuery && matchesCategory && matchesGrade;
          }).toList();

          if (_sortBy == 'Price: Low to High') {
            filtered.sort((a, b) => a.price.compareTo(b.price));
          } else if (_sortBy == 'Price: High to Low') {
            filtered.sort((a, b) => b.price.compareTo(a.price));
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Sleek Search Bar with Integrated Filter & Trade-In Buttons
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                  child: Row(
                    children: [
                      // Search Input
                      Expanded(
                        child: SizedBox(
                          height: 42,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (_) => setState(() {}),
                            decoration: InputDecoration(
                              hintText: 'Search pre-owned gear...',
                              hintStyle: const TextStyle(fontSize: 13, color: SvcColors.muted),
                              prefixIcon: const Icon(Icons.search, size: 18, color: SvcColors.muted),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, size: 16, color: SvcColors.muted),
                                      onPressed: () {
                                        _searchController.clear();
                                        setState(() {});
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: SvcColors.surface,
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: SvcColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: SvcColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: SvcColors.primary, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Dedicated Filter Button
                      InkWell(
                        onTap: _openFilterSheet,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          height: 42,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: _activeFilterCount > 0 ? const Color(0xFF0F172A) : SvcColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _activeFilterCount > 0 ? const Color(0xFF0F172A) : SvcColors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.tune_rounded,
                                size: 17,
                                color: _activeFilterCount > 0 ? Colors.white : SvcColors.ink,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'Filter',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: _activeFilterCount > 0 ? Colors.white : SvcColors.ink,
                                ),
                              ),
                              if (_activeFilterCount > 0) ...[
                                const SizedBox(width: 5),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: SvcColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    '$_activeFilterCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Streamlined Category Filter Bar with Grid/List Toggle
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                  child: Row(
                    children: [
                      // Horizontal Categories
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: kUsedCategories.map((cat) {
                              final isSelected = cat == _selectedCategory;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: InkWell(
                                  onTap: () => setState(() => _selectedCategory = cat),
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected ? SvcColors.primary : SvcColors.surface,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected ? SvcColors.primary : SvcColors.border,
                                      ),
                                    ),
                                    child: Text(
                                      cat,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? Colors.white : SvcColors.ink,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Active Filter Badges (Only displayed when specific filters are set)
              if (_selectedGrade != 'All' || _sortBy != 'Featured')
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (_selectedGrade != 'All')
                          Chip(
                            label: Text(
                              'Grade: ${_selectedGrade.replaceAll('_', ' ')}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () => setState(() => _selectedGrade = 'All'),
                            backgroundColor: const Color(0xFFF1F5F9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            visualDensity: VisualDensity.compact,
                          ),
                        if (_sortBy != 'Featured')
                          Chip(
                            label: Text(
                              'Sort: $_sortBy',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            deleteIcon: const Icon(Icons.close, size: 14),
                            onDeleted: () => setState(() => _sortBy = 'Featured'),
                            backgroundColor: const Color(0xFFF1F5F9),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            visualDensity: VisualDensity.compact,
                          ),
                      ],
                    ),
                  ),
                ),

              // 4. Compact Trade-In & Inspection Trust Strip
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 2, 14, 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: SvcColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified, size: 14, color: SvcColors.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: InkWell(
                            onTap: () => showInspectionStandardsSheet(context),
                            child: const Text(
                              'Lab Inspected • 90-Day Gold Warranty',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: SvcColors.ink),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TradeInScreen(appState: widget.appState),
                              ),
                            );
                          },
                          child: const Text(
                            'Sell / Trade-In →',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF047857),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 5. Product Grid / List
              if (snapshot.hasError)
                SliverToBoxAdapter(
                  child: StoreFeedMessage.loadError(isNe: false, what: 'pre-owned gear'),
                )
              else if (!snapshot.hasData)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: SvcColors.primary),
                    ),
                  ),
                )
              else if (allItems.isEmpty)
                SliverToBoxAdapter(
                  child: StoreFeedMessage(
                    icon: Icons.inventory_2_outlined,
                    title: 'No pre-owned gear listed right now',
                    subtitle: 'New inspected listings are added often. You can also trade in your gear or ask us to source something.',
                    actionLabel: 'Trade In Your Gear',
                    onAction: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TradeInScreen(appState: widget.appState)),
                    ),
                  ),
                )
              else if (filtered.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.filter_list_off_rounded, size: 36, color: SvcColors.muted),
                          const SizedBox(height: 10),
                          const Text(
                            'No gear matching filters',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: SvcColors.ink),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Try resetting your filters or custom sourcing',
                            style: TextStyle(color: SvcColors.muted, fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _selectedCategory = 'All';
                                _selectedGrade = 'All';
                                _sortBy = 'Featured';
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: SvcColors.border),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Reset All Filters'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: UsedProductCard.extentFor(
                        (MediaQuery.sizeOf(context).width - 28 - 12) / 2,
                        MediaQuery.textScalerOf(context),
                      ),
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => UsedProductCard(
                        item: filtered[index],
                        appState: widget.appState,
                      ),
                      childCount: filtered.length,
                    ),
                  ),
                ),

              // 6. Minimal Sourcing link
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SourceRequestScreen(appState: widget.appState),
                          ),
                        );
                      },
                      icon: const Icon(Icons.search, size: 14, color: SvcColors.muted),
                      label: const Text(
                        "Can't find your gear? Request Custom Sourcing →",
                        style: TextStyle(fontSize: 11.5, color: SvcColors.muted, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
