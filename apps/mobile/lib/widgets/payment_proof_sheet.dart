import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../theme_tokens.dart';
import '../utils/format.dart';
import 'cloudinary_upload_card.dart';
import 'svc_snackbar.dart';

/// Bank-transfer payment: shows where to pay and collects the transaction
/// reference and an optional photo of the slip for staff to verify.
Future<bool?> showPaymentProofSheet(
  BuildContext context, {
  required String orderId,
  required String customerId,
  required int amount,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: SvcColors.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _PaymentProofSheet(orderId: orderId, customerId: customerId, amount: amount),
  );
}

class _PaymentProofSheet extends StatefulWidget {
  final String orderId;
  final String customerId;
  final int amount;

  const _PaymentProofSheet({required this.orderId, required this.customerId, required this.amount});

  @override
  State<_PaymentProofSheet> createState() => _PaymentProofSheetState();
}

class _PaymentProofSheetState extends State<_PaymentProofSheet> {
  final _referenceController = TextEditingController();
  late final Future<Map<String, String>?> _bank = FirestoreService().getPaymentSettings();
  String? _slipUrl;
  bool _submitting = false;

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_referenceController.text.trim().isEmpty) {
      SvcSnackbar.warning(context, 'Please enter the transaction or voucher number.');
      return;
    }
    setState(() => _submitting = true);
    try {
      await FirestoreService().submitPaymentProof(
        orderId: widget.orderId,
        customerId: widget.customerId,
        amount: widget.amount,
        referenceNumber: _referenceController.text,
        proofImageUrl: _slipUrl,
      );
      if (!mounted) return;
      SvcSnackbar.success(context, 'Payment submitted. We will confirm it shortly.');
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Payment proof failed: $e');
      if (mounted) SvcSnackbar.error(context, "Couldn't submit your payment. Please try again.");
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Pay by bank transfer',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: SvcColors.ink)),
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context, false),
                ),
              ],
            ),
            Text('Amount to pay: ${formatRs(widget.amount)}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SvcColors.ink)),
            const SizedBox(height: 14),
            FutureBuilder<Map<String, String>?>(
              future: _bank,
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
                }
                final bank = snap.data;
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: SvcColors.primarySoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SvcColors.primaryBorder),
                  ),
                  child: bank == null
                      ? const Text(
                          'We will call you with our bank details. You can submit the transaction number here after paying.',
                          style: TextStyle(fontSize: 14, color: SvcColors.ink, height: 1.45),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (final (label, key) in const [
                              ('Bank', 'bankName'),
                              ('Account name', 'accountName'),
                              ('Account number', 'accountNumber'),
                              ('Branch', 'branch'),
                            ])
                              if ((bank[key] ?? '').isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: SelectableText.rich(TextSpan(children: [
                                    TextSpan(text: '$label: ', style: const TextStyle(color: SvcColors.inkSecondary)),
                                    TextSpan(
                                      text: bank[key],
                                      style: const TextStyle(fontWeight: FontWeight.w700, color: SvcColors.ink),
                                    ),
                                  ])),
                                ),
                          ],
                        ),
                );
              },
            ),
            const SizedBox(height: 18),
            const Text('Transaction or voucher number',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: SvcColors.ink)),
            const SizedBox(height: 6),
            TextField(
              controller: _referenceController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: 'e.g. 2610ABC123',
                filled: true,
                fillColor: SvcColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 14),
            CloudinaryUploadCard(
              label: 'Photo of payment slip (optional)',
              folder: 'payment_slips',
              icon: Icons.receipt_long_outlined,
              onUploaded: (url) => _slipUrl = url,
              onRemoved: () => _slipUrl = null,
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SvcColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                child: _submitting
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4))
                    : const Text('Submit payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
