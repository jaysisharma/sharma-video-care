import 'package:flutter/material.dart';
import '../theme_tokens.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../services/firestore_service.dart';
import 'cart_screen.dart';

class ShopScreen extends StatefulWidget {
  final AppState appState;

  const ShopScreen({super.key, required this.appState});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store & Gear Catalogue'),
        backgroundColor: SvcColors.surface,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart_outlined),
                if (widget.appState.cartCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: SvcColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${widget.appState.cartCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CartScreen(appState: widget.appState)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Category Filters
          Container(
            padding: const EdgeInsets.all(12),
            color: SvcColors.surface,
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search camera bodies, drones, lenses...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: SvcColors.canvas,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Camera', 'Lens', 'Drone', 'CCTV'].map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(cat, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? Colors.white : SvcColors.ink)),
                          selected: isSelected,
                          selectedColor: SvcColors.primary,
                          backgroundColor: SvcColors.canvas,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), // Crisp rectangular tag, NOT pill chips
                          side: BorderSide(color: isSelected ? SvcColors.primary : SvcColors.border),
                          onSelected: (_) => setState(() => _selectedCategory = cat),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Live Firestore Product List
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: FirestoreService().streamProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 40, color: SvcColors.danger),
                          const SizedBox(height: 12),
                          const Text(
                            'Failed to load products',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, color: SvcColors.muted),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final products = snapshot.data ?? [];
                final filtered = products.where((p) {
                  final matchesSearch = p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      p.brand.toLowerCase().contains(_searchQuery.toLowerCase());
                  final matchesCat = _selectedCategory == 'All' || p.categoryName == _selectedCategory;
                  return matchesSearch && matchesCat;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: SvcColors.canvas,
                              shape: BoxShape.circle,
                              border: Border.all(color: SvcColors.border),
                            ),
                            child: const Icon(Icons.inventory_2_outlined, size: 28, color: SvcColors.muted),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            products.isEmpty
                                ? 'No Products in Catalogue'
                                : 'No Matching Equipment Found',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: SvcColors.ink),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            products.isEmpty
                                ? 'Sharma Video Care store catalog will appear here when active products are published.'
                                : 'Try adjusting your search query or selecting "All" categories.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: SvcColors.muted),
                          ),
                          if (_searchQuery.isNotEmpty || _selectedCategory != 'All') ...[
                            const SizedBox(height: 16),
                            OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                  _selectedCategory = 'All';
                                });
                              },
                              child: const Text('Reset Filters'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final prod = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: SvcColors.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: SvcColors.border),
                      ),
                      elevation: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF2EDE4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: prod.imageUrl != null && prod.imageUrl!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            prod.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Icon(Icons.camera_alt, color: SvcColors.muted),
                                          ),
                                        )
                                      : const Icon(Icons.camera_alt, color: SvcColors.muted),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            prod.brand.toUpperCase(),
                                            style: const TextStyle(color: SvcColors.muted, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: prod.availabilityType == 'IN_STOCK' ? SvcColors.success.withAlpha(30) : SvcColors.warning.withAlpha(38),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              prod.availabilityType == 'IN_STOCK' ? 'In Stock' : 'Source on Request',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: prod.availabilityType == 'IN_STOCK' ? SvcColors.success : SvcColors.warning,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        prod.name,
                                        style: SvcTypography.cardTitle.copyWith(fontSize: 13),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Rs. ${prod.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                        style: SvcTypography.statValue.copyWith(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '🚚 Nepal Courier Delivery • ${prod.warrantyInfo}',
                                    style: const TextStyle(fontSize: 11, color: SvcColors.muted),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (prod.availabilityType == 'IN_STOCK')
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      widget.appState.addToCart(CartItemModel(
                                        productId: prod.id,
                                        productType: 'NEW',
                                        name: prod.name,
                                        unitPrice: prod.price,
                                        imageUrl: prod.imageUrl,
                                      ));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          duration: const Duration(seconds: 1),
                                          content: Text('Added "${prod.name}" to cart!'),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.add_shopping_cart, size: 14),
                                    label: const Text('Add', style: TextStyle(fontSize: 12)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: SvcColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      minimumSize: Size.zero,
                                    ),
                                  )
                                else
                                  OutlinedButton(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Go to "Source Gear" to request procurement quote.')),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      minimumSize: Size.zero,
                                    ),
                                    child: const Text('Source', style: TextStyle(fontSize: 11)),
                                  ),
                              ],
                            ),
                          ],
                        ),
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
