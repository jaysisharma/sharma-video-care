import 'package:flutter/material.dart';
import '../theme_tokens.dart';
import '../state/app_state.dart';

import '../services/firestore_service.dart';

class SourceRequestScreen extends StatefulWidget {
  final AppState appState;

  const SourceRequestScreen({super.key, required this.appState});

  @override
  State<SourceRequestScreen> createState() => _SourceRequestScreenState();
}

class _SourceRequestScreenState extends State<SourceRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemController = TextEditingController();
  final _brandController = TextEditingController();
  final _qtyController = TextEditingController(text: '1');
  final _budgetController = TextEditingController();
  final _cityController = TextEditingController(text: 'Janakpur');
  final _notesController = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _itemController.dispose();
    _brandController.dispose();
    _qtyController.dispose();
    _budgetController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      final user = widget.appState.currentUser;
      final customerId = user?.id ?? 'guest-${DateTime.now().millisecondsSinceEpoch}';
      final customerName = user?.name ?? 'Guest User';
      final customerPhone = user?.phone ?? '';

      await FirestoreService().createSourceRequest(
        customerId: customerId,
        customerName: customerName,
        customerPhone: customerPhone,
        itemName: '${_brandController.text.trim()} ${_itemController.text.trim()} (Qty: ${_qtyController.text.trim()})',
        budget: _budgetController.text.trim(),
        city: _cityController.text.trim(),
        notes: _notesController.text.trim(),
      );

      if (!mounted) return;
      setState(() => _submitting = false);

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: SvcColors.success),
              SizedBox(width: 8),
              Text('Sourcing Request Sent!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Our procurement desk is searching distributor networks for "${_itemController.text}".'),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5FAF7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Zero Deposit Guarantee: No customer deposit is collected upfront. You only decide after reviewing our quotation.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF165935)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: SvcColors.danger, content: Text('Error creating request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Source on Request'),
        backgroundColor: SvcColors.surface,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5FAF7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFD1EADE)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: SvcColors.success, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Zero Advance Deposit: Tell us what you need. We source internally and issue an official quotation upon availability.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF165935), height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              TextFormField(
                controller: _itemController,
                decoration: const InputDecoration(
                  labelText: 'Item / Product Name *',
                  hintText: 'e.g. Sony FX3 Cinema Body, Canon 100mm Macro',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _brandController,
                      decoration: const InputDecoration(
                        labelText: 'Brand / Exact Model',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _qtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Quantity *',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Target Budget (NPR)',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'Destination City *',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes / Specific Accessories Needed',
                  hintText: 'Color, mount type, urgency...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SvcColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _submitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Submit Sourcing Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
