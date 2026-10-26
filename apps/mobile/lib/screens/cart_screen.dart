import 'package:flutter/material.dart';
import '../widgets/product_image.dart';
import '../models/models.dart';
import '../theme_tokens.dart';
import '../state/app_state.dart';

import '../services/firestore_service.dart';
import '../widgets/svc_snackbar.dart';
import '../widgets/payment_proof_sheet.dart';
import '../utils/format.dart';

class CartScreen extends StatefulWidget {
  final AppState appState;

  const CartScreen({super.key, required this.appState});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String _paymentMethod = 'COD';
  final _recipientController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController(text: 'Janakpur');
  final _streetController = TextEditingController();
  bool _agreedToTerms = false;
  bool _placingOrder = false;

  @override
  void initState() {
    super.initState();
    final user = widget.appState.currentUser;
    if (user != null) {
      _recipientController.text = user.name;
      _phoneController.text = user.phone;
    }
  }

  @override
  void dispose() {
    _recipientController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  Future<void> _showOrderPlaced({required String orderId, required String customerId, required int total}) async {
    final isBank = _paymentMethod == 'BANK_TRANSFER';
    final payNow = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: SvcColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.check_circle_rounded, color: SvcColors.success, size: 36),
        title: const Text('Order placed', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
          isBank
              ? 'Pay ${formatRs(total)} by bank transfer, then submit the transaction number so we can confirm your order.'
              : 'Pay ${formatRs(total)} in cash when your order is delivered. We will call you to confirm.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: SvcColors.inkSecondary, height: 1.45),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          if (isBank)
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              style: TextButton.styleFrom(foregroundColor: SvcColors.ink),
              child: const Text('Pay later'),
            ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, isBank),
            style: ElevatedButton.styleFrom(
              backgroundColor: SvcColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(isBank ? 'Pay now' : 'Done', style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (payNow == true && mounted) {
      await showPaymentProofSheet(context, orderId: orderId, customerId: customerId, amount: total);
    }
  }

  void _showCheckoutSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: SvcColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Complete Checkout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                const Text('Shipping Destination (Nepal)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                TextField(
                  controller: _recipientController,
                  decoration: const InputDecoration(labelText: 'Recipient Name', isDense: true, border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Phone Number', isDense: true, border: OutlineInputBorder()),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        decoration: const InputDecoration(labelText: 'City', isDense: true, border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _streetController,
                        decoration: const InputDecoration(labelText: 'Street Address', isDense: true, border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text('Payment Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                RadioGroup<String>(
                  groupValue: _paymentMethod,
                  onChanged: (val) => setSheetState(() => _paymentMethod = val!),
                  child: const Column(
                    children: [
                      RadioListTile<String>(
                        value: 'COD',
                        title: Text('Cash on Delivery (COD)', style: TextStyle(fontSize: 13)),
                        subtitle: Text('Pay to courier upon physical delivery across Nepal', style: TextStyle(fontSize: 11)),
                      ),
                      RadioListTile<String>(
                        value: 'BANK_TRANSFER',
                        title: Text('Bank transfer', style: TextStyle(fontSize: 13)),
                        subtitle: Text('Pay to our bank account, then submit the transaction number', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                CheckboxListTile(
                  value: _agreedToTerms,
                  onChanged: (val) => setSheetState(() => _agreedToTerms = val ?? false),
                  title: const Text(
                    'I accept the delivery, return and warranty terms.',
                    style: TextStyle(fontSize: 11, height: 1.3),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _placingOrder
                        ? null
                        : () async {
                            if (!_agreedToTerms) {
                              SvcSnackbar.show(context, 'Please accept delivery and warranty terms.', type: SnackType.warning);
                              return;
                            }

                            setSheetState(() => _placingOrder = true);
                            final nav = Navigator.of(context);
                            final messenger = ScaffoldMessenger.of(context);
                            try {
                              final user = widget.appState.currentUser;
                              final customerId = user?.id ?? FirestoreService.newGuestId();

                              final total = widget.appState.cartTotal;
                              final orderId = await FirestoreService().createOrder(
                                customerId: customerId,
                                customerName: _recipientController.text.trim(),
                                customerPhone: _phoneController.text.trim(),
                                city: _cityController.text.trim(),
                                streetAddress: _streetController.text.trim(),
                                paymentMethod: _paymentMethod,
                                items: widget.appState.cartItems,
                                subtotal: widget.appState.cartSubtotal,
                                deliveryFee: widget.appState.deliveryFee,
                                total: widget.appState.cartTotal,
                              );

                              widget.appState.addNotification(
                                NotificationItemModel(
                                  id: 'notif-order-$orderId',
                                  title: 'Order placed',
                                  message: _paymentMethod == 'COD'
                                      ? 'Pay ${formatRs(total)} in cash when your order is delivered.'
                                      : 'Pay ${formatRs(total)} by bank transfer and submit the transaction number.',
                                  category: 'orders',
                                  timestamp: DateTime.now(),
                                  isRead: false,
                                  actionRoute: 'shop',
                                  actionLabel: 'View orders',
                                ),
                              );

                              setSheetState(() => _placingOrder = false);
                              nav.pop(); // Close sheet
                              widget.appState.clearCart();
                              if (!mounted) return;
                              await _showOrderPlaced(orderId: orderId, customerId: customerId, total: total);
                            } catch (e) {
                              setSheetState(() => _placingOrder = false);
                              SvcSnackbar.showOn(messenger, 'Couldn\'t place your order. Please try again.', type: SnackType.error);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SvcColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: _placingOrder
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('Place order · ${formatRs(widget.appState.cartTotal)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.appState,
      builder: (context, _) {
        final items = widget.appState.cartItems;

        if (items.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Shopping Cart')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_bag_outlined, size: 64, color: SvcColors.muted),
                  const SizedBox(height: 16),
                  const Text('Your cart is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Browse new gear or certified used cameras.', style: TextStyle(color: SvcColors.muted)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: SvcColors.primary, foregroundColor: Colors.white),
                    child: const Text('Go Shopping'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text('Cart (${widget.appState.cartCount})'),
            actions: [
              TextButton(
                onPressed: () => widget.appState.clearCart(),
                child: const Text('Clear', style: TextStyle(color: SvcColors.danger)),
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2EDE4),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: item.imageUrl != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: SvcProductImage(source: item.imageUrl, placeholderIconSize: 22),
                                )
                              : const Icon(Icons.camera_alt, color: SvcColors.muted),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 2),
                              const SizedBox(height: 4),
                              Text('Rs. ${item.unitPrice}', style: const TextStyle(color: SvcColors.muted, fontSize: 12)),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, size: 20),
                              onPressed: () => widget.appState.updateQuantity(item.productId, item.quantity - 1),
                            ),
                            Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, size: 20),
                              onPressed: () => widget.appState.updateQuantity(item.productId, item.quantity + 1),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Summary bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SvcColors.surface,
                  border: const Border(top: BorderSide(color: SvcColors.border)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, -2)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal', style: TextStyle(color: SvcColors.muted, fontSize: 13)),
                        Text('Rs. ${widget.appState.cartSubtotal}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Courier Delivery (Nepal)', style: TextStyle(color: SvcColors.muted, fontSize: 13)),
                        Text('Rs. ${widget.appState.deliveryFee}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Due', style: SvcTypography.cardTitle),
                        Text(
                          'Rs. ${widget.appState.cartTotal}',
                          style: SvcTypography.statValue.copyWith(fontSize: 18, color: SvcColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _showCheckoutSheet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SvcColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Proceed to Checkout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
