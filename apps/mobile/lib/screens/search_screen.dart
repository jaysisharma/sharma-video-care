import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repair_services_data.dart';
import '../models/models.dart';
import '../services/firestore_service.dart';
import '../services/localization_service.dart';
import '../state/app_state.dart';
import '../theme_tokens.dart';
import '../utils/format.dart';
import '../utils/search.dart';
import '../widgets/store_product_widgets.dart';
import '../widgets/used_product_cards.dart';
import 'service_request_screen.dart';
import 'source_screen.dart';

enum _SearchTab { all, products, preOwned, repairs }

/// Search across new store products, certified pre-owned gear and repair
/// services, with results grouped by type.
class SearchScreen extends StatefulWidget {
  final AppState appState;
  final String initialQuery;

  /// Data sources; default to live Firestore. Tests pass their own.
  final Stream<List<ProductModel>>? productsStream;
  final Stream<List<UsedProductModel>>? usedProductsStream;

  const SearchScreen({
    super.key,
    required this.appState,
    this.initialQuery = '',
    this.productsStream,
    this.usedProductsStream,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _recentKey = 'svc_recent_searches';
  static const _maxRecent = 6;
  static const _previewCount = 4;
  static const _popularSearches = [
    'Canon',
    'Sony',
    'DJI drone',
    'Lens',
    'MacBook',
    'AC repair',
    'Sensor cleaning',
    'CCTV',
  ];

  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  // Created once so typing doesn't resubscribe to Firestore
  late final Stream<List<ProductModel>> _productsStream;
  late final Stream<List<UsedProductModel>> _usedProductsStream;

  String _query = '';
  _SearchTab _tab = _SearchTab.all;
  List<String> _recent = const [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _query = widget.initialQuery.trim();
    _productsStream = widget.productsStream ?? FirestoreService().streamProducts();
    _usedProductsStream = widget.usedProductsStream ?? FirestoreService().streamUsedProducts();
    _loadRecent();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_recentKey) ?? const [];
      if (mounted) setState(() => _recent = saved);
    } catch (_) {
      // Recent searches are a convenience; ignore storage failures.
    }
  }

  Future<void> _saveRecent(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;
    final updated = [q, ..._recent.where((r) => r.toLowerCase() != q.toLowerCase())].take(_maxRecent).toList();
    setState(() => _recent = updated);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_recentKey, updated);
    } catch (_) {}
  }

  Future<void> _clearRecent() async {
    setState(() => _recent = const []);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_recentKey);
    } catch (_) {}
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() {
        _query = value.trim();
        _tab = _SearchTab.all;
      });
    });
  }

  /// Runs a search immediately (suggestion chip, recent search or keyboard submit).
  void _runSearch(String value) {
    _debounce?.cancel();
    _controller.text = value;
    _controller.selection = TextSelection.collapsed(offset: value.length);
    _focusNode.unfocus();
    setState(() {
      _query = value.trim();
      _tab = _SearchTab.all;
    });
    _saveRecent(value);
  }

  void _clearQuery() {
    _debounce?.cancel();
    _controller.clear();
    _focusNode.requestFocus();
    setState(() {
      _query = '';
      _tab = _SearchTab.all;
    });
  }

  void _openService(MarketplaceRepairService service) {
    _saveRecent(_query);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ServiceRequestScreen(
          appState: widget.appState,
          initialCategory: service.category,
          prefilledIssue:
              'Service Package: ${service.title} (Rs. ${service.price})\nTurnaround: ${service.turnaround}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNe = SvcLocalization.isNepali;
    return Scaffold(
      backgroundColor: SvcColors.canvas,
      appBar: AppBar(
        backgroundColor: SvcColors.surface,
        elevation: 0.5,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: SvcColors.ink),
        title: Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: SvcColors.canvas,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: SvcColors.border),
            ),
            child: Row(
              children: [
                const SizedBox(width: 10),
                const Icon(Icons.search_rounded, color: SvcColors.primary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    autofocus: widget.initialQuery.isEmpty,
                    textInputAction: TextInputAction.search,
                    onChanged: _onChanged,
                    onSubmitted: _runSearch,
                    style: const TextStyle(fontSize: 13.5, color: SvcColors.ink, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: isNe
                          ? 'क्यामेरा, लेन्स, ड्रोन, एसी वा मर्मत खोज्नुहोस्...'
                          : 'Search cameras, lenses, drones, AC or repairs...',
                      hintStyle: const TextStyle(fontSize: 12.5, color: SvcColors.muted, fontWeight: FontWeight.w500),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, _) => value.text.isEmpty
                      ? const SizedBox(width: 10)
                      : IconButton(
                          tooltip: isNe ? 'मेटाउनुहोस्' : 'Clear',
                          icon: const Icon(Icons.close_rounded, size: 18, color: SvcColors.muted),
                          onPressed: _clearQuery,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      // Streams stay subscribed for the whole screen (Firestore streams can only
      // be listened to once), which also preloads data while suggestions show.
      body: StreamBuilder<List<ProductModel>>(
        stream: _productsStream,
        builder: (context, productsSnap) => StreamBuilder<List<UsedProductModel>>(
          stream: _usedProductsStream,
          builder: (context, usedSnap) => _query.isEmpty
              ? _buildSuggestions(isNe)
              : _buildResults(productsSnap, usedSnap, isNe),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Before typing: recent + popular searches
  // ---------------------------------------------------------------------------

  Widget _buildSuggestions(bool isNe) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
      children: [
        if (_recent.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  isNe ? 'हालैका खोजहरू' : 'Recent searches',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: SvcColors.ink),
                ),
              ),
              TextButton(
                onPressed: _clearRecent,
                child: Text(
                  isNe ? 'मेटाउनुहोस्' : 'Clear',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: SvcColors.primary),
                ),
              ),
            ],
          ),
          for (final r in _recent)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history_rounded, size: 20, color: SvcColors.muted),
              title: Text(r, style: const TextStyle(fontSize: 13.5, color: SvcColors.ink, fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.north_west_rounded, size: 16, color: SvcColors.muted),
              onTap: () => _runSearch(r),
            ),
          const SizedBox(height: 14),
        ],
        Text(
          isNe ? 'लोकप्रिय खोजहरू' : 'Popular searches',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: SvcColors.ink),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in _popularSearches)
              ActionChip(
                label: Text(p),
                labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SvcColors.ink),
                avatar: const Icon(Icons.trending_up_rounded, size: 15, color: SvcColors.primary),
                backgroundColor: SvcColors.surface,
                side: const BorderSide(color: SvcColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onPressed: () => _runSearch(p),
              ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Results
  // ---------------------------------------------------------------------------

  Widget _buildResults(
    AsyncSnapshot<List<ProductModel>> productsSnap,
    AsyncSnapshot<List<UsedProductModel>> usedSnap,
    bool isNe,
  ) {
    final products = rankSearch(
      _query,
      productsSnap.data ?? const <ProductModel>[],
      (p) => [p.name, p.brand, p.categoryName, p.description],
    );
    final used = rankSearch(
      _query,
      usedSnap.data ?? const <UsedProductModel>[],
      (u) => [u.name, u.brand, u.model, u.categoryName, u.conditionDescription],
    );
    final services = rankSearch(
      _query,
      kMarketplaceServices,
      (s) => [s.title, s.category, s.shortDescription, '${s.category} repair service', ...s.features],
    );

    final loading = (!productsSnap.hasData && !productsSnap.hasError) || (!usedSnap.hasData && !usedSnap.hasError);
    final anyError = productsSnap.hasError || usedSnap.hasError;
    final total = products.length + used.length + services.length;

    if (total == 0) {
      if (loading) {
        return const Center(child: CircularProgressIndicator(strokeWidth: 2.4, color: SvcColors.primary));
      }
      if (productsSnap.hasError && usedSnap.hasError) {
        return ListView(
          padding: const EdgeInsets.only(top: 24),
          children: [StoreFeedMessage.loadError(isNe: isNe, what: isNe ? 'खोज नतिजा' : 'search results')],
        );
      }
      return _buildNoResults(isNe);
    }

    final counts = {
      _SearchTab.all: total,
      _SearchTab.products: products.length,
      _SearchTab.preOwned: used.length,
      _SearchTab.repairs: services.length,
    };
    bool show(_SearchTab t) => _tab == _SearchTab.all || _tab == t;
    final limit = _tab == _SearchTab.all ? _previewCount : null;

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        if (loading)
          const SliverToBoxAdapter(
            child: LinearProgressIndicator(minHeight: 2, color: SvcColors.primary, backgroundColor: Colors.transparent),
          ),
        SliverToBoxAdapter(child: _buildTabs(counts, isNe)),
        if (anyError)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Text(
                isNe
                    ? 'केही नतिजा लोड हुन सकेनन्। इन्टरनेट जडान जाँच गर्नुहोस्।'
                    : 'Some results couldn\'t load. Check your internet connection.',
                style: const TextStyle(fontSize: 11.5, color: Color(0xFFB45309), fontWeight: FontWeight.w600),
              ),
            ),
          ),

        // New store products
        if (show(_SearchTab.products) && products.isNotEmpty) ...[
          _sectionHeader(isNe ? 'नयाँ उत्पादनहरू' : 'Products', products.length, _SearchTab.products, isNe),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            sliver: SliverGrid(
              gridDelegate: StoreProductCard.gridDelegate(context),
              delegate: SliverChildBuilderDelegate(
                (context, i) => StoreProductCard(product: products[i], appState: widget.appState),
                childCount: limit == null ? products.length : products.length.clamp(0, limit),
              ),
            ),
          ),
        ],

        // Certified pre-owned
        if (show(_SearchTab.preOwned) && used.isNotEmpty) ...[
          _sectionHeader(isNe ? 'प्रमाणित सेकेन्ड-ह्यान्ड' : 'Certified Pre-Owned', used.length, _SearchTab.preOwned, isNe),
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
                (context, i) => UsedProductCard(item: used[i], appState: widget.appState),
                childCount: limit == null ? used.length : used.length.clamp(0, limit),
              ),
            ),
          ),
        ],

        // Repair services
        if (show(_SearchTab.repairs) && services.isNotEmpty) ...[
          _sectionHeader(isNe ? 'मर्मत सेवाहरू' : 'Repair Services', services.length, _SearchTab.repairs, isNe),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _buildServiceTile(services[i], isNe),
              childCount: limit == null ? services.length : services.length.clamp(0, limit),
            ),
          ),
        ],

        // Selected tab has nothing (e.g. "Pre-Owned (0)")
        if (_tab != _SearchTab.all && counts[_tab] == 0)
          SliverToBoxAdapter(child: _buildNoResults(isNe, inTab: true)),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _buildTabs(Map<_SearchTab, int> counts, bool isNe) {
    final labels = {
      _SearchTab.all: isNe ? 'सबै' : 'All',
      _SearchTab.products: isNe ? 'उत्पादन' : 'Products',
      _SearchTab.preOwned: isNe ? 'सेकेन्ड-ह्यान्ड' : 'Pre-Owned',
      _SearchTab.repairs: isNe ? 'मर्मत' : 'Repairs',
    };
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        children: [
          for (final tab in _SearchTab.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => setState(() => _tab = tab),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _tab == tab ? SvcColors.primary : SvcColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _tab == tab ? SvcColors.primary : SvcColors.border),
                  ),
                  child: Text(
                    '${labels[tab]} (${counts[tab]})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: _tab == tab ? FontWeight.w800 : FontWeight.w600,
                      color: _tab == tab ? Colors.white : SvcColors.ink,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, int count, _SearchTab tab, bool isNe) {
    final canExpand = _tab == _SearchTab.all && count > _previewCount;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: SvcColors.ink, letterSpacing: -0.2),
              ),
            ),
            if (canExpand)
              InkWell(
                onTap: () => setState(() => _tab = tab),
                child: Text(
                  isNe ? 'सबै $count हेर्नुहोस् →' : 'See all $count →',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: SvcColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceTile(MarketplaceRepairService service, bool isNe) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: InkWell(
        onTap: () => _openService(service),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SvcColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SvcColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: service.accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(service.icon, color: service.accentColor, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: SvcColors.ink, height: 1.25),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${service.category} • ${service.turnaround}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: SvcColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatRs(service.price),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: SvcColors.primaryDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isNe ? 'बुक गर्नुहोस् →' : 'Book →',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: SvcColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoResults(bool isNe, {bool inTab = false}) {
    final message = StoreFeedMessage(
      icon: Icons.search_off_rounded,
      title: isNe ? '"$_query" को लागि केही भेटिएन' : 'No results for "$_query"',
      subtitle: isNe
          ? 'अर्को शब्द प्रयोग गर्नुहोस्, वा चाहिएको सामान हामीलाई मगाउन भन्नुहोस्।'
          : 'Try a different word or a brand name, or ask us to source it for you.',
      actionLabel: isNe ? 'सामान मगाउनुहोस्' : 'Request Sourcing',
      onAction: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SourceRequestScreen(appState: widget.appState)),
      ),
    );
    if (inTab) return Padding(padding: const EdgeInsets.only(top: 12), child: message);
    return ListView(padding: const EdgeInsets.only(top: 24), children: [message]);
  }
}
