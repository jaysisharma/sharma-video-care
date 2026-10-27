import 'package:flutter/material.dart';
import '../theme_tokens.dart';
import '../state/app_state.dart';
import '../services/localization_service.dart';
import '../data/estimator_data.dart';
import 'service_request_screen.dart';

class EstimatorScreen extends StatefulWidget {
  final AppState appState;
  final String? initialDeviceSlug;

  const EstimatorScreen({
    super.key,
    required this.appState,
    this.initialDeviceSlug,
  });

  @override
  State<EstimatorScreen> createState() => _EstimatorScreenState();
}

class _EstimatorScreenState extends State<EstimatorScreen> {
  late EstimatorDevice _selectedDevice;
  String? _selectedBrand;
  EstimatorSymptom? _selectedSymptom;

  @override
  void initState() {
    super.initState();
    if (widget.initialDeviceSlug != null) {
      _selectedDevice = kEstimatorDevices.firstWhere(
        (d) => d.slug == widget.initialDeviceSlug,
        orElse: () => kEstimatorDevices[0],
      );
    } else {
      _selectedDevice = kEstimatorDevices[0];
    }
    _selectedBrand = _selectedDevice.popularBrands.first;
    _selectedSymptom = _selectedDevice.symptoms.isNotEmpty ? _selectedDevice.symptoms.first : null;
  }

  void _onSelectDevice(EstimatorDevice device) {
    setState(() {
      _selectedDevice = device;
      _selectedBrand = device.popularBrands.first;
      _selectedSymptom = device.symptoms.isNotEmpty ? device.symptoms.first : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isNe = SvcLocalization.isNepali;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNe ? 'मर्मत खर्च अनुमान' : 'Repair Cost Estimator',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF130D09), Color(0xFF1F150E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF332015)),
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
                          isNe ? 'अन्तरक्रियात्मक क्याल्कुलेटर' : 'BENCH-TESTED ACCURACY',
                          style: const TextStyle(
                            color: SvcColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.calculate_outlined, color: SvcColors.primary, size: 20),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isNe ? 'तत्काल मर्मत खर्च पत्ता लगाउनुहोस्' : 'Instant Repair Cost Calculator',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isNe
                        ? 'आफ्नो उपकरण र समस्या छान्नुहोस् र प्रयोगशाला प्रमाणित दरहरू हेर्नुहोस्।'
                        : 'Transparent technician labor and genuine parts quotation for Janakpur & Province 2.',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Step 1: Select Device Type
            Text(
              isNe ? '१. उपकरण वर्ग छान्नुहोस्' : '1. Select Equipment Category',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: SvcColors.ink),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: kEstimatorDevices.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final device = kEstimatorDevices[index];
                  final isSelected = device.id == _selectedDevice.id;

                  return InkWell(
                    onTap: () => _onSelectDevice(device),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 95,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? SvcColors.primarySoft : SvcColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? SvcColors.primary : SvcColors.border,
                          width: isSelected ? 1.8 : 1.0,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            device.icon,
                            color: isSelected ? SvcColors.primary : SvcColors.muted,
                            size: 26,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isNe ? device.nameNe.split(' ')[0] : device.name.split(' ')[0],
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? SvcColors.primaryDark : SvcColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // Step 2: Select Brand
            Text(
              isNe ? '२. ब्रान्ड चयन गर्नुहोस्' : '2. Select Brand',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: SvcColors.ink),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _selectedDevice.popularBrands.map((brand) {
                final isSelected = brand == _selectedBrand;
                return ChoiceChip(
                  label: Text(brand),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedBrand = brand);
                  },
                  selectedColor: SvcColors.primarySoft,
                  backgroundColor: SvcColors.surface,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? SvcColors.primaryDark : SvcColors.ink,
                  ),
                  side: BorderSide(
                    color: isSelected ? SvcColors.primary : SvcColors.border,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Step 3: Select Symptom / Problem
            Text(
              isNe ? '३. देखिन आएको समस्या छान्नुहोस्' : '3. What symptom are you experiencing?',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: SvcColors.ink),
            ),
            const SizedBox(height: 10),
            Column(
              children: _selectedDevice.symptoms.map((symptom) {
                final isSelected = symptom.id == _selectedSymptom?.id;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => setState(() => _selectedSymptom = symptom),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected ? SvcColors.primarySoft : SvcColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? SvcColors.primary : SvcColors.border,
                          width: isSelected ? 1.8 : 1.0,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSelected ? SvcColors.primary : SvcColors.muted,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isNe ? symptom.titleNe : symptom.title,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    fontSize: 13,
                                    color: SvcColors.ink,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isNe ? symptom.descNe : symptom.desc,
                                  style: const TextStyle(fontSize: 11, color: SvcColors.muted, height: 1.3),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Rs. ${symptom.minPrice.toString()} - ${symptom.maxPrice.toString()}',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: SvcColors.ink),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      isNe ? symptom.turnaroundNe : symptom.turnaround,
                                      style: const TextStyle(fontSize: 10, color: SvcColors.muted),
                                    ),
                                  ],
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
            const SizedBox(height: 20),

            // Step 4: Live Interactive Estimation Result Card
            if (_selectedSymptom != null) ...[
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isNe ? 'अनुमानित मर्मत खर्च' : 'Estimated Cost Range',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: SvcColors.muted),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.verified, color: SvcColors.success, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                isNe ? '${_selectedSymptom!.warrantyDays} दिन वारेन्टी' : '${_selectedSymptom!.warrantyDays}-Day Warranty',
                                style: const TextStyle(color: SvcColors.success, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rs. ${_selectedSymptom!.minPrice.toString()} – ${_selectedSymptom!.maxPrice.toString()}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: SvcColors.primaryDark,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: SvcColors.border),
                    const SizedBox(height: 10),

                    // Cost breakdown rows
                    _buildEstimateRow(
                      label: isNe ? 'प्राविधिक सेवा शुल्क (Labor)' : 'Technician Labor Fee',
                      value: 'Rs. ${_selectedSymptom!.laborFee}',
                    ),
                    const SizedBox(height: 6),
                    _buildEstimateRow(
                      label: isNe ? 'स्पेयर पार्ट्स अनुमान' : 'Parts Estimate',
                      value: isNe ? _selectedSymptom!.partsEstimateNe : _selectedSymptom!.partsEstimate,
                    ),
                    const SizedBox(height: 6),
                    _buildEstimateRow(
                      label: isNe ? 'अनुमानित समय' : 'Turnaround Time',
                      value: isNe ? _selectedSymptom!.turnaroundNe : _selectedSymptom!.turnaround,
                    ),
                    const SizedBox(height: 6),
                    _buildEstimateRow(
                      label: isNe ? 'घरमै सेवा (Home Visit)' : 'Home Visit Availability',
                      value: _selectedSymptom!.homeVisitAvailable
                          ? (isNe ? 'उपलब्ध (जनकपुर क्षेत्र)' : 'Available in Janakpur')
                          : (isNe ? 'ल्याबमै ल्याउनुपर्ने (Lab Only)' : 'Lab Drop-off Required'),
                      valueColor: _selectedSymptom!.homeVisitAvailable ? SvcColors.success : SvcColors.warning,
                    ),

                    const SizedBox(height: 14),

                    // Diagnostic Tip Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: SvcColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline, color: SvcColors.info, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isNe ? 'तत्काल सावधानी सल्लाह:' : 'Technician Advice:',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: SvcColors.ink),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isNe ? _selectedSymptom!.recommendedActionNe : _selectedSymptom!.recommendedAction,
                                  style: const TextStyle(fontSize: 11, color: SvcColors.muted, height: 1.3),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Action Button
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ServiceRequestScreen(
                              appState: widget.appState,
                              prefilledDevice: '${_selectedBrand ?? ''} ${_selectedDevice.name}',
                              prefilledIssue: '${_selectedSymptom!.title} (Est: Rs. ${_selectedSymptom!.minPrice}-${_selectedSymptom!.maxPrice})',
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SvcColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        isNe ? 'यो अनुमान सहित मर्मत बुक गर्नुहोस्' : 'Book Repair with this Estimate',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildEstimateRow({
    required String label,
    required String value,
    Color valueColor = SvcColors.ink,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: SvcColors.muted),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: valueColor),
          ),
        ),
      ],
    );
  }
}
