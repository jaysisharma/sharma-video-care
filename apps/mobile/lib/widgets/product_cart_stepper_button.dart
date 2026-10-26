import 'package:flutter/material.dart';
import '../theme_tokens.dart';
import '../models/models.dart';
import '../state/app_state.dart';
import 'svc_snackbar.dart';

class ProductCartStepperButton extends StatelessWidget {
  final AppState appState;
  final String productId;
  final String productType; // 'NEW' | 'USED'
  final String name;
  final int unitPrice;
  final String? imageUrl;
  final double height;
  final bool compact;

  const ProductCartStepperButton({
    super.key,
    required this.appState,
    required this.productId,
    required this.productType,
    required this.name,
    required this.unitPrice,
    this.imageUrl,
    this.height = 30,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        final qty = appState.getItemQuantity(productId);

        if (qty == 0) {
          return InkWell(
            onTap: () {
              appState.addToCart(CartItemModel(
                productId: productId,
                productType: productType,
                name: name,
                unitPrice: unitPrice,
                imageUrl: imageUrl,
              ));
              SvcSnackbar.show(context, 'Added "$name" to cart!', type: SnackType.success);
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: height,
              padding: compact
                  ? const EdgeInsets.symmetric(horizontal: 8)
                  : const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: SvcColors.primary,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: SvcColors.primary.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 1.5),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, size: 14, color: Colors.white),
                  if (!compact) ...[
                    const SizedBox(width: 2),
                    const Text(
                      'Add',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        // Stepper: - 1 +
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 1.5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Minus Button
              InkWell(
                onTap: () {
                  appState.updateQuantity(productId, qty - 1);
                },
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(8)),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: compact ? 6 : 8, vertical: 4),
                  child: const Icon(Icons.remove, size: 13, color: Colors.white),
                ),
              ),
              // Quantity Number
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  '$qty',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              // Plus Button
              InkWell(
                onTap: () {
                  appState.updateQuantity(productId, qty + 1);
                },
                borderRadius:
                    const BorderRadius.horizontal(right: Radius.circular(8)),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: compact ? 6 : 8, vertical: 4),
                  child: const Icon(Icons.add, size: 13, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
