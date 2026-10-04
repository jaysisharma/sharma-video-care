import 'package:flutter/material.dart';
import '../theme_tokens.dart';
import '../state/app_state.dart';

import '../services/firestore_service.dart';

class ServiceRequestScreen extends StatefulWidget {
  final AppState appState;
  final String? initialCategory;

  const ServiceRequestScreen({
    super.key,
    required this.appState,
    this.initialCategory,
  });

  @override
  State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedCategory;
  final _modelController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController(text: 'Station Road, Near Railway Station');
  final _wardController = TextEditingController(text: 'Ward 4');

  String _timeSlot = 'Morning (10:00 AM - 01:00 PM)';
  bool _agreedToPricingRule = false;
  bool _submitting = false;

  final List<String> _categories = [
    'Camera',
    'Lens',
    'Drone',
    'CCTV',
    'TV & Display',
    'Installation & Setup',
    'Custom Service',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory ?? _categories[0];
    final user = widget.appState.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
    }
  }

  @override
  void didUpdateWidget(covariant ServiceRequestScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final user = widget.appState.currentUser;
    if (user != null && _nameController.text.isEmpty) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
    }
  }

  @override
  void dispose() {
    _modelController.dispose();
    _descriptionController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _wardController.dispose();
    super.dispose();
  }

  void _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToPricingRule) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: SvcColors.danger,
          content: Text('Please acknowledge the free inspection & diagnosis pricing rule.'),
        ),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final user = widget.appState.currentUser;
      final customerId = user?.id ?? 'guest-${DateTime.now().millisecondsSinceEpoch}';

      await FirestoreService().createServiceRequest(
        customerId: customerId,
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        title: '$_selectedCategory: ${_modelController.text.trim()}',
        description: _descriptionController.text.trim(),
        city: 'Janakpur',
        streetAddress: '${_streetController.text.trim()}, ${_wardController.text.trim()}',
        preferredDate: DateTime.now().add(const Duration(days: 1)).toIso8601String().split('T')[0],
        preferredTimeSlot: _timeSlot,
        serviceType: _selectedCategory,
      );

      if (!mounted) return;
      setState(() => _submitting = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: SvcColors.success),
            SizedBox(width: 8),
            Text('Request Booked!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your service request for "${_modelController.text}" has been recorded for the Janakpur service center.',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: SvcColors.primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Remember: Inspection and technician visit are Rs. 0. Final quote will be produced after diagnosis.',
                style: TextStyle(fontSize: 12, color: SvcColors.primaryDark, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to previous
            },
            child: const Text('Go to Home', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: SvcColors.danger, content: Text('Error booking request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Repair & Inspection'),
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
              // Mandatory pricing notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SvcColors.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFCDAC1)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: SvcColors.primary, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Inspection required — final price after physical diagnosis. Free visit in Janakpur.',
                        style: TextStyle(color: SvcColors.primaryDark, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                '1. Equipment Information',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Service Category',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'Brand & Model Name *',
                  hintText: 'e.g. Sony A7 IV, DJI Mini 4 Pro, Samsung 55 OLED',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please specify the model' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Defect Symptoms & Problem Description *',
                  hintText: 'Describe error codes, physical impact, water damage, or what stopped working...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                validator: (val) => val == null || val.trim().isEmpty ? 'Please describe the issue' : null,
              ),
              const SizedBox(height: 24),

              const Text(
                '2. Janakpur Inspection Location',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Name *',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number *',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: TextFormField(
                      controller: _wardController,
                      decoration: const InputDecoration(
                        labelText: 'Ward / Tole *',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _streetController,
                      decoration: const InputDecoration(
                        labelText: 'Street Address in Janakpur *',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      ),
                      validator: (val) => val == null || val.trim().isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _timeSlot,
                decoration: const InputDecoration(
                  labelText: 'Preferred Time Window',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                items: [
                  'Morning (10:00 AM - 01:00 PM)',
                  'Afternoon (01:00 PM - 05:00 PM)',
                  'Evening (05:00 PM - 07:00 PM)',
                ].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
                onChanged: (val) => setState(() => _timeSlot = val!),
              ),
              const SizedBox(height: 20),

              // Mandatory acknowledgement
              CheckboxListTile(
                value: _agreedToPricingRule,
                onChanged: (val) => setState(() => _agreedToPricingRule = val ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'I agree that inspection and initial technician visit in Janakpur are free, and that the final price will be quoted after physical diagnosis.',
                  style: TextStyle(fontSize: 12, color: SvcColors.ink, height: 1.3),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SvcColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _submitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Submit Repair Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
