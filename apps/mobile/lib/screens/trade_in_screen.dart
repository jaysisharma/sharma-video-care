import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme_tokens.dart';
import '../state/app_state.dart';
import '../services/localization_service.dart';
import '../services/firestore_service.dart';
import '../services/cloudinary_service.dart';
import '../data/trade_in_data.dart';
import '../widgets/svc_snackbar.dart';

class TradeInScreen extends StatefulWidget {
  final AppState appState;

  const TradeInScreen({super.key, required this.appState});

  @override
  State<TradeInScreen> createState() => _TradeInScreenState();
}

class _TradeInScreenState extends State<TradeInScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedCategory = 'camera';
  late TradeInEquipment _selectedEquipment;

  String _cosmeticId = 'mint';
  String _functionalId = 'flawless';
  String _shutterId = 'low';
  final List<String> _selectedAccessories = ['box', 'charger'];

  bool _isCustom = false;
  final _customModelController = TextEditingController();
  final _customBaseController = TextEditingController(text: '80000');

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController(text: 'Janakpur');
  final _notesController = TextEditingController();

  final Map<String, bool> _photosAttached = {
    'front': false,
    'sensor': false,
    'serial': false,
  };
  final Map<String, String> _photoUrls = {};
  final Set<String> _uploadingSlots = {};

  bool _submitting = false;

  final List<Map<String, String>> _categories = [
    {'id': 'camera', 'label': 'Cameras', 'labelNe': 'क्यामेरा'},
    {'id': 'lens', 'label': 'Lenses', 'labelNe': 'लेन्स'},
    {'id': 'laptop', 'label': 'Laptops', 'labelNe': 'ल्यापटप'},
    {'id': 'drone', 'label': 'Drones', 'labelNe': 'ड्रोन'},
    {'id': 'mobile', 'label': 'Mobile', 'labelNe': 'मोबाइल'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedEquipment = kTradeInEquipments.firstWhere(
      (e) => e.category == _selectedCategory,
      orElse: () => kTradeInEquipments[0],
    );

    final user = widget.appState.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
    }
  }

  @override
  void dispose() {
    _customModelController.dispose();
    _customBaseController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _onCategoryChanged(String catId) {
    setState(() {
      _selectedCategory = catId;
      _isCustom = false;
      final matched = kTradeInEquipments.where((e) => e.category == catId).toList();
      if (matched.isNotEmpty) {
        _selectedEquipment = matched.first;
      }
    });
  }

  TradeInValuationResult get _currentValuation {
    final customBase = int.tryParse(_customBaseController.text) ?? 80000;
    return calculateTradeInValuation(
      equipment: _selectedEquipment,
      cosmeticId: _cosmeticId,
      functionalId: _functionalId,
      shutterId: _shutterId,
      selectedAccessoryIds: _selectedAccessories,
      isCustom: _isCustom,
      customBase: customBase,
    );
  }

  void _submitTradeIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      final user = widget.appState.currentUser;
      final customerId = user?.id ?? 'guest-${DateTime.now().millisecondsSinceEpoch}';
      final valuation = _currentValuation;

      final modelName = _isCustom
          ? _customModelController.text.trim()
          : '${_selectedEquipment.brand} ${_selectedEquipment.model}';

      await FirestoreService().db.collection('tradeInRequests').add({
        'customerId': customerId,
        'customerName': _nameController.text.trim(),
        'customerPhone': _phoneController.text.trim(),
        'equipmentModel': modelName,
        'category': _selectedCategory,
        'estimatedCashMin': valuation.minCash,
        'estimatedCashMax': valuation.maxCash,
        'estimatedCreditMin': valuation.minCredit,
        'estimatedCreditMax': valuation.maxCredit,
        'cosmeticGrade': _cosmeticId,
        'functionalGrade': _functionalId,
        'shutterTier': _selectedEquipment.shutterApplicable ? _shutterId : 'N/A',
        'includedAccessories': _selectedAccessories,
        'city': _cityController.text.trim(),
        'notes': _notesController.text.trim(),
        'photos': _photoUrls,
        'photoUrls': _photoUrls.values.toList(),
        'status': 'PENDING_PHYSICAL_INSPECTION',
        'createdAt': DateTime.now().toUtc().toIso8601String(),
      });

      if (!mounted) return;
      setState(() => _submitting = false);

      final certId = 'QS-TI-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.verified, color: SvcColors.success, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pre-Approved Trade-In Certificate',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: SvcColors.ink),
                        ),
                        Text(
                          'Certificate ID: $certId',
                          style: const TextStyle(fontSize: 11.5, color: SvcColors.muted, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Certificate Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      modelName.toUpperCase(),
                      style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Guaranteed Cash Buyout', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5)),
                            const SizedBox(height: 2),
                            Text(
                              'Rs. ${valuation.minCash} – ${valuation.maxCash}',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF34D399).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            '+10% Store Credit\nRs. ${valuation.minCredit} – ${valuation.maxCredit}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF34D399), fontSize: 10.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFF334155), height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Station Road Janakpur Lab', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11)),
                        Text('Valid: 7 Days', style: TextStyle(color: Color(0xFFFBBF24), fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.flash_on, color: Color(0xFF16A34A), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Bring this certificate ID to our Janakpur desk for a 15-minute express physical test and instant bank transfer or gear swap.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF15803D), height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SvcColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Save & Done', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      SvcSnackbar.show(context, 'Something went wrong. Please try again.', type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNe = SvcLocalization.isNepali;
    final availableModels = kTradeInEquipments.where((e) => e.category == _selectedCategory).toList();
    final valuation = _currentValuation;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNe ? 'सामान बेच्नुहोस् / तत्काल मूल्याङ्कन' : 'Sell Old Gear / Trade-In',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: SvcColors.surface,
        elevation: 0.5,
        actions: [
          IconButton(
            tooltip: isNe ? 'Switch to English' : 'नेपालीमा हेर्नुहोस्',
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: SvcColors.canvas,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: SvcColors.border),
              ),
              child: Text(
                isNe ? 'EN' : 'नेपाली',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SvcColors.primary),
              ),
            ),
            onPressed: () {
              setState(() {
                SvcLocalization.toggleLanguage();
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Callout
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF334155)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: SvcColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: SvcColors.primary.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            isNe ? 'तत्काल क्याश वा स्टोर क्रेडिट' : 'INSTANT CASH OR UPGRADE',
                            style: const TextStyle(
                              color: SvcColors.primary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.currency_exchange, color: SvcColors.primary, size: 20),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      isNe ? 'आफ्नो पुरानो उपकरणको सही मूल्य पाउनुहोस्' : 'Instant Trade-In Valuation Calculator',
                      style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isNe
                          ? 'ल्यापटप, क्यामेरा, ड्रोन वा लेन्स बेचेर तुरुन्तै नगद पाउनुहोस् वा नयाँ सामानमा साट्नुहोस्।'
                          : 'Get verified market buyout pricing backed by QuickySewa inspection lab.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Category Selector Tabs
              Text(
                isNe ? '१. उपकरण वर्ग छान्नुहोस्' : '1. Select Category',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: SvcColors.ink),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = cat['id'] == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(isNe ? cat['labelNe']! : cat['label']!),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) _onCategoryChanged(cat['id']!);
                        },
                        selectedColor: SvcColors.primarySoft,
                        backgroundColor: SvcColors.surface,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? SvcColors.primaryDark : SvcColors.ink,
                        ),
                        side: BorderSide(
                          color: isSelected ? SvcColors.primary : SvcColors.border,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),

              // Model Selector
              Text(
                isNe ? '२. उपकरण मोडेल चयन गर्नुहोस्' : '2. Select Model',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: SvcColors.ink),
              ),
              const SizedBox(height: 8),
              if (!_isCustom) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: SvcColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: SvcColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<TradeInEquipment>(
                      value: availableModels.contains(_selectedEquipment)
                          ? _selectedEquipment
                          : (availableModels.isNotEmpty ? availableModels.first : null),
                      isExpanded: true,
                      onChanged: (eq) {
                        if (eq != null) setState(() => _selectedEquipment = eq);
                      },
                      items: availableModels.map((eq) {
                        return DropdownMenuItem<TradeInEquipment>(
                          value: eq,
                          child: Text(
                            '${eq.brand} - ${eq.model}',
                            style: const TextStyle(fontSize: 13, color: SvcColors.ink),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => setState(() => _isCustom = true),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: Text(
                      isNe ? '+ मेरो मोडेल सूचीमा छैन (अन्य उपकरण)' : "+ Can't find my model? Enter custom",
                      style: const TextStyle(fontSize: 12, color: SvcColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ] else ...[
                TextFormField(
                  controller: _customModelController,
                  decoration: InputDecoration(
                    labelText: isNe ? 'उपकरणको नाम र मोडेल' : 'Equipment Brand & Model',
                    hintText: 'e.g. Sony FX3 Cinema Line',
                    filled: true,
                    fillColor: SvcColors.surface,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () => setState(() => _isCustom = false),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                    child: Text(
                      isNe ? '← सूचीबाट छान्नुहोस्' : '← Pick from list',
                      style: const TextStyle(fontSize: 12, color: SvcColors.primary),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 18),

              // Step 3: Condition Checklist
              Text(
                isNe ? '३. बाहिरी अवस्था (Cosmetic Condition)' : '3. Cosmetic Condition',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: SvcColors.ink),
              ),
              const SizedBox(height: 8),
              Column(
                children: kCosmeticConditions.map((cos) {
                  final isSelected = cos.id == _cosmeticId;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => setState(() => _cosmeticId = cos.id),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? SvcColors.primarySoft : SvcColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? SvcColors.primary : SvcColors.border,
                            width: isSelected ? 1.6 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isSelected ? SvcColors.primary : SvcColors.muted,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isNe ? cos.labelNe : cos.label,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  Text(
                                    isNe ? cos.descNe : cos.desc,
                                    style: const TextStyle(fontSize: 11, color: SvcColors.muted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Functional Condition
              Text(
                isNe ? '४. प्राविधिक अवस्था (Functional Status)' : '4. Functional Status',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: SvcColors.ink),
              ),
              const SizedBox(height: 8),
              Column(
                children: kFunctionalConditions.map((func) {
                  final isSelected = func.id == _functionalId;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => setState(() => _functionalId = func.id),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? SvcColors.primarySoft : SvcColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? SvcColors.primary : SvcColors.border,
                            width: isSelected ? 1.6 : 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isSelected ? SvcColors.primary : SvcColors.muted,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isNe ? func.labelNe : func.label,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  Text(
                                    isNe ? func.descNe : func.desc,
                                    style: const TextStyle(fontSize: 11, color: SvcColors.muted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // Shutter count if applicable
              if (_selectedEquipment.shutterApplicable) ...[
                Text(
                  isNe ? '५. सटर क्लिक गणना (Shutter Count)' : '5. Shutter Actuations',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: SvcColors.ink),
                ),
                const SizedBox(height: 8),
                Column(
                  children: kShutterTiers.map((shut) {
                    final isSelected = shut.id == _shutterId;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => setState(() => _shutterId = shut.id),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? SvcColors.primarySoft : SvcColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? SvcColors.primary : SvcColors.border,
                              width: isSelected ? 1.6 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: isSelected ? SvcColors.primary : SvcColors.muted,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  isNe ? shut.labelNe : shut.label,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
              ],

              // Accessories Included
              Text(
                isNe ? 'सक्कली सामानहरू (Original Accessories)' : 'Included Accessories (Adds Bonus Value)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: SvcColors.ink),
              ),
              const SizedBox(height: 8),
              Column(
                children: kTradeInAccessories.map((acc) {
                  final isChecked = _selectedAccessories.contains(acc.id);
                  return CheckboxListTile(
                    value: isChecked,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedAccessories.add(acc.id);
                        } else {
                          _selectedAccessories.remove(acc.id);
                        }
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(
                      isNe ? acc.nameNe : acc.name,
                      style: const TextStyle(fontSize: 13, color: SvcColors.ink),
                    ),
                    subtitle: Text(
                      '+Rs. ${acc.bonusAmount}',
                      style: const TextStyle(fontSize: 11, color: SvcColors.success, fontWeight: FontWeight.bold),
                    ),
                    activeColor: SvcColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // 6. Photo Appraisal Upload Section
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: SvcColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.add_a_photo_outlined, size: 18, color: SvcColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isNe ? 'फोटो प्रमाणीकरण (Photo Appraisal)' : 'Photo Appraisal (Fast-Track Payout)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: SvcColors.ink),
                              ),
                              Text(
                                isNe ? '३ फोटो जोड्नुहोस् र तत्काल निश्चित प्रमाणीकरण पाउनुहोस्।' : 'Attach 3 photos for an instant pre-approved certificate.',
                                style: const TextStyle(fontSize: 11, color: SvcColors.muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildPhotoSlot('front', 'Front & Mount', Icons.camera_front_outlined)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildPhotoSlot('sensor', 'Sensor / Display', Icons.center_focus_strong_outlined)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildPhotoSlot('serial', 'Serial Plate', Icons.qr_code_2_outlined)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Live Valuation Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: SvcColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: SvcColors.primary.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: SvcColors.primary.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isNe ? 'अनुमानित बजार भुक्तानी' : 'Estimated Instant Valuation',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SvcColors.muted),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rs. ${valuation.minCash} – ${valuation.maxCash}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: SvcColors.primaryDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isNe ? 'नगद भुक्तानी (Bank / Cash Payout)' : 'Direct Instant Cash Buyout',
                      style: const TextStyle(fontSize: 12, color: SvcColors.muted),
                    ),
                    const SizedBox(height: 14),

                    // Store Credit Upgrade Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_upward, color: SvcColors.success, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isNe ? 'स्टोर क्रेडिट साटासाट (+१०% थप बोनस)' : 'Store Credit Upgrade (+10% Bonus):',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                                ),
                                Text(
                                  'Rs. ${valuation.minCredit} – ${valuation.maxCredit}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: SvcColors.success),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Contact Info for Pickup/Inspection
              Text(
                isNe ? 'सम्पर्क विवरण (Contact & Inspection)' : 'Contact & Drop-Off / Inspection Details',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: SvcColors.ink),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: isNe ? 'तपाईंको नाम' : 'Your Full Name',
                  filled: true,
                  fillColor: SvcColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: isNe ? 'फोन नम्बर' : 'Phone Number',
                  filled: true,
                  fillColor: SvcColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: isNe ? 'शहर / ठेगाना' : 'City / Location in Nepal',
                  filled: true,
                  fillColor: SvcColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: isNe ? 'थप जानकारी (वैकल्पिक)' : 'Additional Notes (Optional)',
                  hintText: 'Any specific lens/accessories or purchase date',
                  filled: true,
                  fillColor: SvcColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: _submitting ? null : _submitTradeIn,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SvcColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.handshake_outlined, size: 18),
                label: Text(
                  isNe ? 'मूल्याङ्कन अनुरोध पठाउनुहोस्' : 'Submit Valuation & Request Inspection',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSlot(String key, String label, IconData icon) {
    final isUploaded = _photosAttached[key] ?? false;
    final isUploading = _uploadingSlots.contains(key);
    final photoUrl = _photoUrls[key];

    return InkWell(
      onTap: isUploading
          ? null
          : () async {
              if (isUploaded && photoUrl != null) {
                final action = await showModalBottomSheet<String>(
                  context: context,
                  builder: (ctx) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.add_a_photo_outlined, color: SvcColors.primary),
                          title: Text('Replace $label photo'),
                          onTap: () => Navigator.pop(ctx, 'replace'),
                        ),
                        ListTile(
                          leading: const Icon(Icons.delete_outline, color: SvcColors.danger),
                          title: Text('Remove $label photo'),
                          onTap: () => Navigator.pop(ctx, 'remove'),
                        ),
                      ],
                    ),
                  ),
                );

                if (action == 'remove') {
                  if (!mounted) return;
                  setState(() {
                    _photoUrls.remove(key);
                    _photosAttached[key] = false;
                  });
                  SvcSnackbar.show(context, '$label photo removed.', type: SnackType.info);
                  return;
                } else if (action != 'replace') {
                  return;
                }
              }

              if (!mounted) return;
              setState(() => _uploadingSlots.add(key));
              try {
                final url = await CloudinaryService().showImagePickerModal(
                  context,
                  folder: 'video_care/trade_in',
                  title: 'Upload $label Photo',
                );
                if (url != null && mounted) {
                  setState(() {
                    _photoUrls[key] = url;
                    _photosAttached[key] = true;
                  });
                  SvcSnackbar.show(context, '$label photo uploaded to Cloudinary!', type: SnackType.success);
                }
              } finally {
                if (mounted) {
                  setState(() => _uploadingSlots.remove(key));
                }
              }
            },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 76,
        decoration: BoxDecoration(
          color: isUploaded ? const Color(0xFFECFDF5) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isUploaded ? const Color(0xFF10B981) : SvcColors.border,
            width: isUploaded ? 1.5 : 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: isUploading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(SvcColors.primary)),
                ),
              )
            : isUploaded && photoUrl != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: CloudinaryService().getOptimizedUrl(photoUrl, width: 160, height: 160),
                        fit: BoxFit.cover,
                        placeholder: (ctx, _) => Container(color: Colors.grey.shade100),
                        errorWidget: (ctx, _, __) => const Center(
                          child: Icon(Icons.check_circle_rounded, color: Color(0xFF047857), size: 22),
                        ),
                      ),
                      Container(color: Colors.black.withValues(alpha: 0.25)),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFF059669),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check, size: 12, color: Colors.white),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        left: 4,
                        right: 4,
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: SvcColors.muted,
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: SvcColors.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

