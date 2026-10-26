import 'package:flutter/material.dart';
import '../models/models.dart';
import '../screens/cart_screen.dart';
import '../services/localization_service.dart';
import '../state/app_state.dart';
import '../theme_tokens.dart';
import '../utils/format.dart';
import 'product_cart_stepper_button.dart';
import 'product_image.dart';
import 'svc_snackbar.dart';

/// Shared pieces for showing new-store products (home feed, Top Deals, shop).
/// Everything here reads real Firestore fields only: discounts come from
/// `originalPrice`, stock from `availabilityType` / `stockQuantity`.

// Words that identify each filter chip in a product's free-text categoryName.
// Short keywords (<4 chars) must match a whole word so "ac" doesn't hit "accessories".
const Map<String, List<String>> _categoryKeywords = {
  'Cameras': ['camera'],
  'Lenses': ['lens', 'lenses'],
  'Drones': ['drone'],
  'Laptops': ['laptop', 'computer', 'macbook'],
  'Audio': ['audio', 'microphone', 'mic', 'headphone', 'speaker'],
  'Accessories': ['accessor', 'gimbal', 'flash', 'light', 'memory', 'storage', 'tripod'],
  'AC': ['ac', 'air', 'conditioner'],
  'TV': ['tv', 'television', 'display'],
  'CCTV': ['cctv', 'surveillance', 'security'],
};

bool productMatchesCategory(ProductModel product, String category) {
  final keywords = _categoryKeywords[category];
  if (keywords == null) return true; // 'All' or unknown chip
  final words = product.categoryName.toLowerCase().split(RegExp(r'[^a-z0-9]+'));
  return words.any((w) => keywords.any((k) => k.length < 4 ? w == k : w.startsWith(k)));
}

/// Short stock line for a product, or null when there's nothing worth saying.
({String text, Color color})? productStockLabel(ProductModel p, bool isNe) {
  if (p.isOutOfStock) {
    return (text: isNe ? 'स्टक सकियो' : 'Out of stock', color: const Color(0xFFDC2626));
  }
  if (p.availabilityType == 'SOURCE_ON_REQUEST' || p.availabilityType == 'SPECIAL_ORDER') {
    return (text: isNe ? 'अर्डरमा ल्याइन्छ' : 'On request', color: const Color(0xFFD97706));
  }
  if (p.stockQuantity > 0 && p.stockQuantity <= 3) {
    return (
      text: isNe ? '${p.stockQuantity} मात्र बाँकी' : 'Only ${p.stockQuantity} left',
      color: const Color(0xFFDC2626),
    );
  }
  return null;
}

/// Price on its own line, scaled down rather than clipped on narrow cards.
class StorePriceText extends StatelessWidget {
  final int price;
  final double fontSize;

  const StorePriceText({super.key, required this.price, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        formatRs(price),
        maxLines: 1,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF0F172A),
        ),
      ),
    );
  }
}

/// Cart stepper, or a "Sold out" label when the product can't be bought.
class StoreAddToCartButton extends StatelessWidget {
  final ProductModel product;
  final AppState appState;
  final double height;

  const StoreAddToCartButton({
    super.key,
    required this.product,
    required this.appState,
    this.height = 30,
  });

  @override
  Widget build(BuildContext context) {
    if (product.isOutOfStock) {
      return Text(
        SvcLocalization.isNepali ? 'उपलब्ध छैन' : 'Sold out',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: SvcColors.muted),
      );
    }
    return ProductCartStepperButton(
      appState: appState,
      productId: product.id,
      productType: 'NEW',
      name: product.name,
      unitPrice: product.price,
      imageUrl: product.imageUrl,
      height: height,
      compact: true,
    );
  }
}

class StoreProductCard extends StatelessWidget {
  static const double _imageHeight = 132;

  final ProductModel product;
  final AppState appState;

  const StoreProductCard({super.key, required this.product, required this.appState});

  /// Tile height that fits the card's content at the given text scale.
  static double extentFor(TextScaler scaler) {
    double line(double size, double height) => scaler.scale(size) * height;
    final priceBlock = line(14.5, 1.3) + line(10.5, 1.3); // price + struck-through price
    return _imageHeight +
        18 + // body padding
        line(10, 1.4) + // brand
        3 +
        line(12.5, 1.25) * 2 + // two-line name
        8 +
        (priceBlock > 32 ? priceBlock : 32) + // price block beside the cart button
        2;
  }

  static SliverGridDelegate gridDelegate(BuildContext context) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 12,
      mainAxisExtent: extentFor(MediaQuery.textScalerOf(context)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNe = SvcLocalization.isNepali;
    final prod = product;
    final stock = productStockLabel(prod, isNe);
    return Material(
      color: SvcColors.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showStoreProductDetailSheet(context, prod, appState),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo with discount and stock badges
              SizedBox(
                height: _imageHeight,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(
                      color: const Color(0xFFF1F5F9),
                      child: SvcProductImage(source: prod.imageUrl, placeholderIconSize: 34),
                    ),
                    if (prod.isOutOfStock) ColoredBox(color: Colors.white.withValues(alpha: 0.55)),
                    if (prod.hasDiscount)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: _ImageBadge(
                          text: '-${prod.discountPercent}%',
                          background: const Color(0xFFDC2626),
                          foreground: Colors.white,
                        ),
                      ),
                    if (stock != null)
                      Positioned(
                        left: 8,
                        bottom: 8,
                        right: 8,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: _ImageBadge(
                            text: stock.text,
                            background: Colors.white,
                            foreground: stock.color,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Brand, name, price and cart button
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prod.brand.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: SvcColors.muted,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        prod.name,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: SvcColors.ink,
                          height: 1.25,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                StorePriceText(price: prod.price, fontSize: 14.5),
                                if (prod.hasDiscount)
                                  Text(
                                    formatRs(prod.originalPrice!),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      color: Color(0xFF94A3B8),
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (!prod.isOutOfStock) ...[
                            const SizedBox(width: 6),
                            StoreAddToCartButton(product: prod, appState: appState),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small pill drawn over a product photo (discount, stock).
class _ImageBadge extends StatelessWidget {
  final String text;
  final Color background;
  final Color foreground;

  const _ImageBadge({required this.text, required this.background, required this.foreground});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 4, offset: const Offset(0, 1)),
        ],
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: foreground),
      ),
    );
  }
}

/// Grey placeholder tiles shown while the catalogue loads. Returns a sliver.
class StoreProductSkeletonGrid extends StatelessWidget {
  const StoreProductSkeletonGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
      sliver: SliverGrid(
        gridDelegate: StoreProductCard.gridDelegate(context),
        delegate: SliverChildBuilderDelegate(
          (context, index) => Container(
            decoration: BoxDecoration(
              color: SvcColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SvcColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: StoreProductCard._imageHeight,
                  decoration: const BoxDecoration(
                    color: SvcColors.surfaceSubtle,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                  ),
                ),
                for (final widthFactor in const [0.4, 0.9, 0.6])
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                    child: FractionallySizedBox(
                      widthFactor: widthFactor,
                      child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: SvcColors.surfaceSubtle,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          childCount: 4,
        ),
      ),
    );
  }
}

/// Card used for a feed's error and empty states.
class StoreFeedMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const StoreFeedMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  /// The standard "couldn't load" message.
  factory StoreFeedMessage.loadError({required bool isNe, required String what}) {
    return StoreFeedMessage(
      icon: Icons.cloud_off_rounded,
      title: isNe ? '$what लोड गर्न सकिएन' : 'Couldn\'t load $what',
      subtitle: isNe
          ? 'इन्टरनेट जडान जाँच गर्नुहोस्। जडान फर्किएपछि आफैं लोड हुनेछ।'
          : 'Check your internet connection. The list will refresh once you\'re back online.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: SvcColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SvcColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34, color: SvcColors.muted),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: SvcColors.ink),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: SvcColors.muted, height: 1.35),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: SvcColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: SvcColors.primary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

void showStoreProductDetailSheet(BuildContext context, ProductModel prod, AppState appState) {
  final isNe = SvcLocalization.isNepali;
  final stock = productStockLabel(prod, isNe);
  final chip = stock ??
      (prod.availabilityType == 'IN_STOCK'
          ? (text: isNe ? 'स्टकमा छ' : 'In stock', color: const Color(0xFF15803D))
          : null);

  void addToCart() {
    appState.addToCart(CartItemModel(
      productId: prod.id,
      productType: 'NEW',
      name: prod.name,
      unitPrice: prod.price,
      imageUrl: prod.imageUrl,
    ));
  }

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: SvcColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 180,
                  width: double.infinity,
                  child: SvcProductImage(source: prod.imageUrl, placeholderIconSize: 40),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      prod.brand.toUpperCase(),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: SvcColors.primary),
                    ),
                  ),
                  if (chip != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: chip.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        chip.text.toUpperCase(),
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: chip.color),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                prod.name,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 6),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  Text(
                    formatRs(prod.price),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: SvcColors.primaryDark),
                  ),
                  if (prod.hasDiscount) ...[
                    Text(
                      formatRs(prod.originalPrice!),
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), decoration: TextDecoration.lineThrough),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '-${prod.discountPercent}%',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
              if (prod.description.isNotEmpty) ...[
                Text(
                  prod.description,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.35),
                ),
                const SizedBox(height: 10),
              ],
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: SvcColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: SvcColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            prod.warrantyInfo,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.assignment_return_outlined, color: SvcColors.primary, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            prod.returnPolicyInfo,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              if (prod.isOutOfStock)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(isNe ? 'हाल उपलब्ध छैन' : 'Currently unavailable'),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          addToCart();
                          Navigator.pop(ctx);
                          SvcSnackbar.show(
                            context,
                            isNe ? '"${prod.name}" झोलामा थपियो' : 'Added "${prod.name}" to cart',
                            type: SnackType.success,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: const BorderSide(color: SvcColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          isNe ? 'झोलामा थप्नुहोस्' : 'Add to Cart',
                          style: const TextStyle(color: SvcColors.primary, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Don't bump the quantity if it's already in the cart
                          if (appState.getItemQuantity(prod.id) == 0) addToCart();
                          Navigator.pop(ctx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => CartScreen(appState: appState)),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SvcColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(
                          isNe ? 'अहिले किन्नुहोस्' : 'Buy Now',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      );
    },
  );
}
