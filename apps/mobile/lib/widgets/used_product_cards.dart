import 'package:flutter/material.dart';
import '../theme_tokens.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import '../data/used_products_data.dart';
import 'used_inspection_sheets.dart';
import 'product_image.dart';
import 'svc_snackbar.dart';

/// Pre-owned item tile for the two-column grid: square photo, grade tag,
/// brand and condition, name, full price and a compact add-to-cart button.
class UsedProductCard extends StatelessWidget {
  final UsedProductModel item;
  final AppState appState;

  const UsedProductCard({
    super.key,
    required this.item,
    required this.appState,
  });

  /// Tile height for a given tile width; the text block grows with the user's text size.
  static double extentFor(double tileWidth, TextScaler textScaler) {
    const fixed = 12 + 4 + 10 + 40 + 14; // paddings, gaps, add button
    return tileWidth + fixed + textScaler.scale(16 + 37) + 2; // brand line + two-line name
  }

  static const _conditionLabels = {
    'LIKE_NEW': 'Like new',
    'EXCELLENT': 'Excellent',
    'GOOD': 'Good',
    'FAIR': 'Fair',
  };

  @override
  Widget build(BuildContext context) {
    final grade = getGradeBadge(item.conditionGrade)['label'] as String;
    final condition = _conditionLabels[item.conditionGrade.toUpperCase()];

    return Material(
      color: SvcColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: SvcColors.border),
      ),
      child: InkWell(
        onTap: () => showUsedProductDetailModal(context, item, appState),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  SvcProductImage(source: item.imageUrl),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.94),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        grade,
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: SvcColors.ink),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    condition == null ? item.brand : '${item.brand} · $condition',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: SvcColors.muted, height: 1.3),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SvcColors.ink, height: 1.3),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            formatUsedPrice(item.price),
                            style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: SvcColors.ink),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _AddToCartButton(item: item, appState: appState),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  final UsedProductModel item;
  final AppState appState;

  const _AddToCartButton({required this.item, required this.appState});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final inCart = appState.getItemQuantity(item.id) > 0;
        return SizedBox(
          width: 40,
          height: 40,
          child: IconButton(
            tooltip: inCart ? 'In your cart' : 'Add to cart',
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(
              backgroundColor: inCart ? SvcColors.primary : SvcColors.surface,
              foregroundColor: inCart ? Colors.white : SvcColors.ink,
              side: inCart ? BorderSide.none : const BorderSide(color: SvcColors.borderStrong),
            ),
            icon: Icon(inCart ? Icons.check_rounded : Icons.add_shopping_cart_rounded, size: 18),
            onPressed: () {
              if (inCart) {
                SvcSnackbar.info(context, 'Already in your cart.');
                return;
              }
              // Pre-owned items are single units, so one tap adds the only one.
              appState.addToCart(CartItemModel(
                productId: item.id,
                productType: 'USED',
                name: item.name,
                unitPrice: item.price,
                imageUrl: item.imageUrl,
              ));
              SvcSnackbar.success(context, 'Added to cart');
            },
          ),
        );
      },
    );
  }
}
