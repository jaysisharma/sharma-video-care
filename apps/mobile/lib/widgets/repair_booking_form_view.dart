import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme_tokens.dart';
import '../state/app_state.dart';
import '../services/firestore_service.dart';
import 'cloudinary_upload_card.dart';

class RepairBookingFormView extends StatefulWidget {
  final AppState appState;
  final String selectedCategory;
  final TextEditingController modelController;
  final TextEditingController descriptionController;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController streetController;
  final TextEditingController wardController;
  final String timeSlot;
  final String preferredDate; // yyyy-MM-dd
  final bool agreedToPricingRule;
  final bool submitting;
  final List<String> categories;
  final ValueChanged<String> onCategoryChanged;
  final ValueChanged<String> onTimeSlotChanged;
  final ValueChanged<String> onPreferredDateChanged;
  final ValueChanged<bool> onAgreedChanged;
  final VoidCallback onSubmit;
  final String? photoUrl;
  final ValueChanged<String>? onPhotoUploaded;
  final VoidCallback? onPhotoRemoved;

  const RepairBookingFormView({
    super.key,
    required this.appState,
    required this.selectedCategory,
    required this.modelController,
    required this.descriptionController,
    required this.nameController,
    required this.phoneController,
    required this.streetController,
    required this.wardController,
    required this.timeSlot,
    required this.preferredDate,
    required this.agreedToPricingRule,
    required this.submitting,
    required this.categories,
    required this.onCategoryChanged,
    required this.onTimeSlotChanged,
    required this.onPreferredDateChanged,
    required this.onAgreedChanged,
    required this.onSubmit,
    this.photoUrl,
    this.onPhotoUploaded,
    this.onPhotoRemoved,
  });

  /// The next [count] days the workshop is open, starting tomorrow
  /// (Saturday is on-call only, so it's skipped).
  static List<DateTime> openDays({DateTime? from, int count = 3}) {
    final start = from ?? DateTime.now();
    final days = <DateTime>[];
    var day = DateTime(start.year, start.month, start.day + 1);
    while (days.length < count) {
      if (day.weekday != DateTime.saturday) days.add(day);
      day = DateTime(day.year, day.month, day.day + 1);
    }
    return days;
  }

  static String dateValue(DateTime day) => DateFormat('yyyy-MM-dd').format(day);

  @override
  State<RepairBookingFormView> createState() => _RepairBookingFormViewState();
}

class _RepairBookingFormViewState extends State<RepairBookingFormView> {
  final Map<String, List<String>> _modelSuggestions = {
    'Camera': ['Sony A7 IV', 'Canon EOS R6', 'Nikon Z6 II', 'Sony FX3', 'Fujifilm X-T5'],
    'Lens': ['Sony 24-70mm GM', 'Canon 24-105mm L', 'Sigma 18-35mm Art', 'Tamron 28-75mm'],
    'Drone': ['DJI Mini 4 Pro', 'DJI Air 3', 'DJI Mavic 3 Pro', 'DJI Avata 2'],
    'Laptop': ['MacBook Pro M1/M2/M3', 'Dell XPS 15', 'Lenovo ThinkPad', 'ASUS ROG Strix'],
    'AC': ['Daikin 1.5T Inverter', 'Panasonic 1.5T Dual Inverter', 'LG 1.5T Dual Cool', 'Voltas 1T'],
    'TV & Display': ['Samsung 55" QLED', 'Sony Bravia 65" 4K', 'LG 55" OLED', 'TCL 50" 4K Smart'],
    'CCTV': ['Hikvision 4MP IP PoE', 'Dahua 8CH NVR', 'CP Plus 2MP Dome', 'Uniview 4K'],
  };

  final List<String> _quickSymptomTags = [
    "Won't turn on",
    'Water damage',
    'Dropped',
    'Spots on sensor',
    'Autofocus problem',
    'Overheating',
    'Screen cracked or flickering',
    'Weak cooling',
  ];

  // Values are stored with the request, so keep them stable.
  static const _timeSlots = [
    ('Morning (10:00 AM - 01:00 PM)', 'Morning', '10 AM – 1 PM'),
    ('Afternoon (01:00 PM - 05:00 PM)', 'Afternoon', '1 – 5 PM'),
    ('Evening (05:00 PM - 07:00 PM)', 'Evening', '5 – 7 PM'),
  ];

  InputDecoration _decoration({String? hint}) {
    OutlineInputBorder border(Color c, [double w = 1.2]) =>
        OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c, width: w));
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: SvcColors.subtle),
      filled: true,
      fillColor: SvcColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: border(SvcColors.borderStrong),
      enabledBorder: border(SvcColors.borderStrong),
      focusedBorder: border(SvcColors.primary, 1.5),
      errorBorder: border(SvcColors.danger),
      focusedErrorBorder: border(SvcColors.danger, 1.5),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: SvcColors.ink)),
      );

  Widget _field({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
    Iterable<String>? autofillHints,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          autofillHints: autofillHints,
          textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
          style: const TextStyle(fontSize: 15.5, color: SvcColors.ink),
          decoration: _decoration(hint: hint),
          validator: validator,
        ),
      ],
    );
  }

  Widget _chips(List<String> items, ValueChanged<String> onTap) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items)
          ActionChip(
            label: Text(item),
            onPressed: () => onTap(item),
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: SvcColors.ink),
            backgroundColor: SvcColors.surface,
            side: const BorderSide(color: SvcColors.border),
            shape: const StadiumBorder(),
            visualDensity: VisualDensity.compact,
          ),
      ],
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: SvcColors.ink),
      );

  String? _required(String? v, String message) => (v == null || v.trim().isEmpty) ? message : null;

  @override
  Widget build(BuildContext context) {
    final suggestions = _modelSuggestions[widget.selectedCategory] ?? [];

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: SvcColors.primarySoft,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SvcColors.primaryBorder),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, color: SvcColors.primary, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Inspection and pickup in Janakpur are free. We send you a quote, and nothing is repaired until you approve it.',
                  style: TextStyle(fontSize: 13.5, color: SvcColors.ink, height: 1.45),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _sectionTitle('Your device'),
        const SizedBox(height: 14),
        _label('Type of device'),
        DropdownButtonFormField<String>(
          initialValue: widget.selectedCategory,
          isExpanded: true,
          decoration: _decoration(),
          borderRadius: BorderRadius.circular(12),
          style: const TextStyle(fontSize: 15.5, color: SvcColors.ink),
          items: widget.categories
              .map((c) => DropdownMenuItem(value: c, child: Text(c, overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: (val) {
            if (val != null) widget.onCategoryChanged(val);
          },
        ),
        const SizedBox(height: 16),
        _field(
          label: 'Brand and model',
          controller: widget.modelController,
          hint: 'e.g. Sony A7 IV',
          validator: (v) => _required(v, 'Please enter the brand and model'),
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 10),
          _chips(suggestions, (s) => widget.modelController.text = s),
        ],
        const SizedBox(height: 16),
        _field(
          label: "What's wrong?",
          controller: widget.descriptionController,
          hint: 'Tell us what happened and what stopped working',
          maxLines: 4,
          validator: (v) => _required(v, 'Please describe the problem'),
        ),
        const SizedBox(height: 10),
        _chips(_quickSymptomTags, (tag) {
          final current = widget.descriptionController.text.trim();
          if (current.isEmpty) {
            widget.descriptionController.text = tag;
          } else if (!current.contains(tag)) {
            widget.descriptionController.text = '$current, $tag';
          }
        }),
        const SizedBox(height: 16),
        CloudinaryUploadCard(
          label: 'Fault / Damage Photo (Optional)',
          helperText: 'Attach a photo of the cracked screen, error, or broken part',
          icon: Icons.camera_alt_outlined,
          folder: 'video_care/repairs',
          imageUrl: widget.photoUrl,
          onUploaded: widget.onPhotoUploaded,
          onRemoved: widget.onPhotoRemoved,
        ),
        const SizedBox(height: 24),

        _sectionTitle('Pickup details'),
        const SizedBox(height: 14),
        _field(
          label: 'Your name',
          controller: widget.nameController,
          autofillHints: const [AutofillHints.name],
          validator: (v) => _required(v, 'Please enter your name'),
        ),
        const SizedBox(height: 16),
        _field(
          label: 'Mobile number',
          controller: widget.phoneController,
          hint: '98XXXXXXXX',
          keyboardType: TextInputType.phone,
          autofillHints: const [AutofillHints.telephoneNumber],
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Please enter your mobile number';
            return FirestoreService.isValidNepalMobile(v) ? null : 'Enter a valid mobile number, e.g. 98XXXXXXXX';
          },
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _field(
                label: 'Street address',
                controller: widget.streetController,
                hint: 'e.g. Mills Area',
                autofillHints: const [AutofillHints.streetAddressLine1],
                validator: (v) => _required(v, 'Required'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _field(
                label: 'Ward',
                controller: widget.wardController,
                hint: 'e.g. 4',
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _label('Preferred day'),
        Row(
          children: [
            for (final (i, day) in RepairBookingFormView.openDays().indexed) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _dayTile(day)),
            ],
          ],
        ),
        const SizedBox(height: 16),
        _label('Preferred time'),
        Row(
          children: [
            for (var i = 0; i < _timeSlots.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _timeSlotTile(_timeSlots[i])),
            ],
          ],
        ),
        const SizedBox(height: 18),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => widget.onAgreedChanged(!widget.agreedToPricingRule),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: widget.agreedToPricingRule,
                activeColor: SvcColors.primary,
                onChanged: (val) => widget.onAgreedChanged(val ?? false),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Text(
                    "I understand the inspection is free and I'll approve the quote before any repair starts.",
                    style: TextStyle(fontSize: 13.5, color: SvcColors.ink, height: 1.4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: widget.submitting ? null : widget.onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: SvcColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: SvcColors.primary.withValues(alpha: 0.6),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            child: widget.submitting
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                : const Text('Book free inspection'),
          ),
        ),
      ],
    );
  }

  Widget _dayTile(DateTime day) {
    final value = RepairBookingFormView.dateValue(day);
    final now = DateTime.now();
    final isTomorrow = day == DateTime(now.year, now.month, now.day + 1);
    return _choiceTile(
      selected: widget.preferredDate == value,
      title: isTomorrow ? 'Tomorrow' : DateFormat('EEEE').format(day),
      subtitle: DateFormat('d MMM').format(day),
      onTap: () => widget.onPreferredDateChanged(value),
    );
  }

  Widget _timeSlotTile((String, String, String) slot) {
    final (value, title, hours) = slot;
    return _choiceTile(
      selected: widget.timeSlot == value,
      title: title,
      subtitle: hours,
      onTap: () => widget.onTimeSlotChanged(value),
    );
  }

  Widget _choiceTile({
    required bool selected,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: selected ? SvcColors.primarySoft : SvcColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? SvcColors.primary : SvcColors.borderStrong, width: selected ? 1.5 : 1.2),
        ),
        child: Column(
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: SvcColors.ink),
            ),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: SvcColors.muted)),
          ],
        ),
      ),
    );
  }
}
