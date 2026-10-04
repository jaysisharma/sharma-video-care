import 'package:flutter/material.dart';
import '../theme_tokens.dart';
import '../models/models.dart';
import '../state/app_state.dart';

import '../services/firestore_service.dart';

class UsedProductsScreen extends StatelessWidget {
  final AppState appState;

  const UsedProductsScreen({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certified Second-Hand Gear'),
        backgroundColor: SvcColors.surface,
        elevation: 0.5,
      ),
      body: StreamBuilder<List<UsedProductModel>>(
        stream: FirestoreService().streamUsedProducts(),
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
                    const Text('Error loading certified pre-owned gear', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('${snapshot.error}', style: const TextStyle(fontSize: 12, color: SvcColors.muted)),
                  ],
                ),
              ),
            );
          }

          final items = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Exclusive SVC policy notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5FAF7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD1EADE)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.verified, color: SvcColors.success, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Exclusively Sharma Video Care Pre-Owned: No peer-to-peer listings. Every unit is inspected in our lab and backed by our service warranty.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF165935), height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (items.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
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
                          child: const Icon(Icons.verified_outlined, size: 28, color: SvcColors.muted),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Certified Used Units in Stock',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: SvcColors.ink),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'All pre-owned cameras and drones undergo strict multi-point bench tests before being listed here. Check back soon or request custom sourcing.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: SvcColors.muted),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...items.map(
                  (item) => Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    color: SvcColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: SvcColors.border),
                    ),
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF2EDE4),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: item.imageUrl != null && item.imageUrl!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          item.imageUrl!,
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
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: SvcColors.primarySoft,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Grade: ${item.conditionGrade.replaceAll('_', ' ')}',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: SvcColors.primaryDark,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Icon(Icons.check_circle, size: 14, color: SvcColors.success),
                                        const Text(' Tested', style: TextStyle(fontSize: 11, color: SvcColors.success)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Rs. ${item.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: SvcColors.ink),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          Text(
                            item.conditionDescription,
                            style: const TextStyle(fontSize: 12, color: SvcColors.muted),
                          ),
                          if (item.knownDefects.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF9EF),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFF8ECCF)),
                              ),
                              child: Text(
                                'Disclosed Mark: ${item.knownDefects[0]}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF8E5A17)),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '🛡️ ${item.warrantyDetails}',
                                style: const TextStyle(fontSize: 11, color: SvcColors.muted),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  appState.addToCart(CartItemModel(
                                    productId: item.id,
                                    productType: 'USED',
                                    name: item.name,
                                    unitPrice: item.price,
                                    imageUrl: item.imageUrl,
                                  ));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      duration: const Duration(seconds: 1),
                                      content: Text('Added "${item.name}" to cart!'),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add_shopping_cart, size: 14),
                                label: const Text('Add to Cart', style: TextStyle(fontSize: 12)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SvcColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  minimumSize: Size.zero,
                                ),
                              ),
                            ],
                          ),
                        ],
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
