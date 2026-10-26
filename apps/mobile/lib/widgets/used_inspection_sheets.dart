import 'package:flutter/material.dart';
import 'product_image.dart';
import '../theme_tokens.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../data/used_products_data.dart';
import 'svc_snackbar.dart';

void showInspectionStandardsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.verified, color: SvcColors.success, size: 22),
              SizedBox(width: 8),
              Text(
                'QuickySewa 45-Point Inspection Standard',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: SvcColors.ink),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildCheckItem('Zero Hot/Dead Pixels', 'Sensor checked with dark-frame raw capture.'),
          _buildCheckItem('Shutter Count Verified', 'Confirmed directly from factory firmware logs.'),
          _buildCheckItem('Optical Collimator Pass', 'No fungus, haze, or element misalignment.'),
          _buildCheckItem('Battery & Circuit Test', 'Genuine battery capacity minimum 85%+ verified.'),
          _buildCheckItem('90-Day Lab Warranty', 'Full coverage by our Janakpur technical team.'),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildCheckItem(String title, String subtitle) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, size: 16, color: Color(0xFF16A34A)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: SvcColors.ink)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: SvcColors.muted)),
            ],
          ),
        ),
      ],
    ),
  );
}

void showUsedProductDetailModal(BuildContext context, UsedProductModel item, AppState appState) {
  final badge = getGradeBadge(item.conditionGrade);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 6),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                children: [
                  // Photo
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 220,
                      color: const Color(0xFFF8FAFC),
                      width: double.infinity,
                      child: SvcProductImage(source: item.imageUrl, placeholderIconSize: 48),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // In-Lab Photo Verified Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_camera_rounded, size: 13, color: Color(0xFF16A34A)),
                        SizedBox(width: 6),
                        Text(
                          'Actual Unit Photographed on Janakpur Lab Bench',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: badge['bg'] as Color,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: badge['border'] as Color),
                        ),
                        child: Text(
                          badge['label'] as String,
                          style: TextStyle(
                            color: badge['text'] as Color,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.shield_outlined, size: 12, color: SvcColors.muted),
                            SizedBox(width: 4),
                            Text('90-Day Lab Warranty', style: TextStyle(fontSize: 10.5, color: SvcColors.muted, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Title
                  Text(
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: SvcColors.ink),
                  ),
                  const SizedBox(height: 8),

                  // Price
                  Text(
                    formatUsedPrice(item.price),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                  ),
                  const Divider(height: 24),

                  // Overview
                  const Text('Condition & Test Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: SvcColors.ink)),
                  const SizedBox(height: 6),
                  Text(item.conditionDescription, style: const TextStyle(fontSize: 12, color: SvcColors.muted, height: 1.4)),
                  const SizedBox(height: 6),
                  Text('• ${item.testNotes}', style: const TextStyle(fontSize: 12, color: SvcColors.ink, height: 1.35)),

                  if (item.knownDefects.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF9EF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFF8ECCF)),
                      ),
                      child: Text(
                        'Disclosed mark: ${item.knownDefects.join(", ")}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF8E5A17)),
                      ),
                    ),
                  ],

                  if (item.includedAccessories.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text('Included Accessories', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: SvcColors.ink)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: item.includedAccessories.map((acc) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: SvcColors.border),
                          ),
                          child: Text(acc, style: const TextStyle(fontSize: 11, color: SvcColors.ink)),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // Sticky Add to Cart
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: SvcColors.border)),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    appState.addToCart(CartItemModel(
                      productId: item.id,
                      productType: 'USED',
                      name: item.name,
                      unitPrice: item.price,
                      imageUrl: item.imageUrl,
                    ));
                    Navigator.pop(ctx);
                    SvcSnackbar.show(context, 'Added "${item.name}" to cart!', type: SnackType.success);
                  },
                  icon: const Icon(Icons.add_shopping_cart, size: 16),
                  label: Text('Add to Cart • ${formatUsedPrice(item.price)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SvcColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
