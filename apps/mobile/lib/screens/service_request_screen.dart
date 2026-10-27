import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../theme_tokens.dart';
import '../state/app_state.dart';
import '../services/firestore_service.dart';
import '../services/guest_repair_tickets.dart';
import '../widgets/repair_overview_view.dart';
import '../widgets/repair_booking_form_view.dart';
import '../widgets/repair_tracking_view.dart';
import '../data/repair_services_data.dart';
import '../widgets/svc_snackbar.dart';

class ServiceRequestScreen extends StatefulWidget {
  final AppState appState;
  final String? initialCategory;
  final String? prefilledDevice;
  final String? prefilledIssue;

  const ServiceRequestScreen({
    super.key,
    required this.appState,
    this.initialCategory,
    this.prefilledDevice,
    this.prefilledIssue,
  });

  @override
  State<ServiceRequestScreen> createState() => _ServiceRequestScreenState();
}

class _ServiceRequestScreenState extends State<ServiceRequestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  late String _selectedCategory;
  final _modelController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetController = TextEditingController();
  final _wardController = TextEditingController();

  String _timeSlot = 'Morning (10:00 AM - 01:00 PM)';
  String _preferredDate = RepairBookingFormView.dateValue(RepairBookingFormView.openDays().first);
  bool _agreedToPricingRule = false;
  bool _submitting = false;
  String? _photoUrl;

  final List<String> _categories = [
    'Camera',
    'Lens',
    'AC',
    'Laptop',
    'TV & Display',
    'Drone',
    'CCTV',
    'Washing Machine',
    'Installation & Setup',
    'Custom Service',
  ];

  @override
  void initState() {
    super.initState();

    final hasPrefilledData = widget.initialCategory != null ||
        widget.prefilledDevice != null ||
        widget.prefilledIssue != null;

    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: hasPrefilledData ? 1 : 0,
    );

    _selectedCategory = _knownCategory(widget.initialCategory);
    if (widget.prefilledDevice != null) {
      _modelController.text = widget.prefilledDevice!;
    }
    if (widget.prefilledIssue != null) {
      _descriptionController.text = widget.prefilledIssue!;
    }

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
    if (widget.initialCategory != null &&
        widget.initialCategory != oldWidget.initialCategory) {
      setState(() {
        _selectedCategory = _knownCategory(widget.initialCategory);
      });
      _tabController.animateTo(1);
    }
    if (widget.prefilledDevice != null &&
        widget.prefilledDevice != oldWidget.prefilledDevice) {
      _modelController.text = widget.prefilledDevice!;
      _tabController.animateTo(1);
    }
    if (widget.prefilledIssue != null &&
        widget.prefilledIssue != oldWidget.prefilledIssue) {
      _descriptionController.text = widget.prefilledIssue!;
      _tabController.animateTo(1);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _modelController.dispose();
    _descriptionController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _streetController.dispose();
    _wardController.dispose();
    super.dispose();
  }

  /// Only bookable categories may be preselected; anything else (e.g. a
  /// "Coming Soon" service) falls back to the first category.
  String _knownCategory(String? category) =>
      _categories.contains(category) ? category! : _categories[0];

  /// Maps a department name ("Lenses", "Drones & gimbals", "TVs") to a booking
  /// category by its key word ("Lens", "Drone", "TV & Display").
  String _categoryForDepartment(String department) {
    final words = department.toLowerCase().split(RegExp(r'[^a-z0-9]+'));
    return _categories.firstWhere(
      (c) {
        final key = c.toLowerCase().split(' ').first;
        return words.any((w) => w.startsWith(key));
      },
      orElse: () => _categories[0],
    );
  }

  void _onSelectDepartment(String department) {
    setState(() => _selectedCategory = _categoryForDepartment(department));
    _tabController.animateTo(1);
  }

  void _onSelectSymptom(String category, String symptomTitle) {
    setState(() {
      final matched = _categories.firstWhere(
        (c) => c.toLowerCase().contains(category.toLowerCase()),
        orElse: () => _categories[0],
      );
      _selectedCategory = matched;
      _descriptionController.text = 'Reported Symptom: $symptomTitle';
    });
    _tabController.animateTo(1);
  }

  void _onSelectService(MarketplaceRepairService service) {
    setState(() {
      final matched = _categories.firstWhere(
        (c) => c.toLowerCase().contains(service.category.toLowerCase()),
        orElse: () => _categories[0],
      );
      _selectedCategory = matched;
      _descriptionController.text =
          'Service Package: ${service.title} (Rs. ${service.price})\nTurnaround: ${service.turnaround}';
    });
    _tabController.animateTo(1);
  }

  /// City of the delivery hub the customer picked (where the device is).
  String get _customerCity {
    final hubName = widget.appState.selectedDeliveryHub.toLowerCase();
    for (final hub in kNepalDeliveryHubs) {
      if (hub.name.toLowerCase() == hubName) return hub.city;
    }
    return kNepalDeliveryHubs.firstWhere((h) => h.isDefault).city;
  }

  /// Clears the device and address fields after a booking; name and phone stay.
  void _resetForm() {
    _modelController.clear();
    _descriptionController.clear();
    _streetController.clear();
    _wardController.clear();
    setState(() {
      _photoUrl = null;
      _agreedToPricingRule = false;
      _preferredDate = RepairBookingFormView.dateValue(RepairBookingFormView.openDays().first);
    });
  }

  void _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreedToPricingRule) {
      SvcSnackbar.warning(context, 'Please confirm you understand how the free inspection works.');
      return;
    }

    setState(() => _submitting = true);

    try {
      final user = widget.appState.currentUser;
      final customerId =
          user?.id ?? FirestoreService.newGuestId();
      final device = _modelController.text.trim();
      final phone = _phoneController.text.trim();

      final ticketId = await FirestoreService().createServiceRequest(
        customerId: customerId,
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        title: '$_selectedCategory: ${_modelController.text.trim()}',
        description: _descriptionController.text.trim(),
        city: _customerCity,
        streetAddress: _wardController.text.trim().isEmpty
            ? _streetController.text.trim()
            : '${_streetController.text.trim()}, Ward ${_wardController.text.trim().replaceFirst(RegExp(r'^[Ww]ard\s*'), '')}',
        preferredDate: _preferredDate,
        preferredTimeSlot: _timeSlot,
        serviceType: _selectedCategory,
        photoUrl: _photoUrl,
      );

      // Guests have no account to list their repairs, so remember the ticket here.
      if (user == null) await GuestRepairTickets.add(ticketId);

      widget.appState.addNotification(
        NotificationItemModel(
          id: 'notif-service-${DateTime.now().millisecondsSinceEpoch}',
          title: 'Repair Request Submitted',
          message: 'We received your request for $device (ticket $ticketId). We will call you to arrange pickup.',
          category: 'repairs',
          timestamp: DateTime.now(),
          isRead: false,
          actionRoute: 'services',
          actionLabel: 'View repair',
        ),
      );

      if (!mounted) return;
      setState(() => _submitting = false);
      _resetForm();

      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: SvcColors.surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.check_circle_rounded, color: SvcColors.success, size: 36),
          title: const Text('Repair booked', style: TextStyle(fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'We will call $phone to arrange pickup of your $device. '
                'Inspection is free and you will approve the quote before any work starts.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: SvcColors.inkSecondary, height: 1.45),
              ),
              const SizedBox(height: 14),
              _TicketNumberBox(ticketId: ticketId),
              if (user == null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Keep this number to track your repair. You\'ll also find it under My repairs on this phone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: SvcColors.muted, height: 1.4),
                ),
              ],
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _tabController.animateTo(2);
              },
              style: TextButton.styleFrom(foregroundColor: SvcColors.ink),
              child: const Text('View my repairs', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _tabController.animateTo(0);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SvcColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      SvcSnackbar.show(context, 'Couldn\'t book your repair. Please try again.', type: SnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SvcColors.canvas,
      appBar: AppBar(
        title: const Text(
          'Repair',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: -0.4, color: SvcColors.ink),
        ),
        backgroundColor: SvcColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          indicatorColor: SvcColors.primary,
          indicatorWeight: 2.5,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: SvcColors.border,
          labelColor: SvcColors.ink,
          unselectedLabelColor: SvcColors.muted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14.5),
          tabs: const [
            Tab(text: 'Services'),
            Tab(text: 'Book'),
            Tab(text: 'My repairs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Marketplace Services & How It Works
          RepairOverviewView(
            appState: widget.appState,
            onSelectDepartment: _onSelectDepartment,
            onSelectSymptom: _onSelectSymptom,
            onSelectService: _onSelectService,
            onBookDirect: () => _tabController.animateTo(1),
          ),

          // Tab 2: Book Service (Rs. 0 Inspection)
          Form(
            key: _formKey,
            child: RepairBookingFormView(
              appState: widget.appState,
              selectedCategory: _selectedCategory,
              modelController: _modelController,
              descriptionController: _descriptionController,
              nameController: _nameController,
              phoneController: _phoneController,
              streetController: _streetController,
              wardController: _wardController,
              timeSlot: _timeSlot,
              preferredDate: _preferredDate,
              agreedToPricingRule: _agreedToPricingRule,
              submitting: _submitting,
              categories: _categories,
              onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
              onTimeSlotChanged: (slot) => setState(() => _timeSlot = slot),
              onPreferredDateChanged: (date) => setState(() => _preferredDate = date),
              onAgreedChanged: (val) => setState(() => _agreedToPricingRule = val),
              onSubmit: _submitRequest,
              photoUrl: _photoUrl,
              onPhotoUploaded: (url) => setState(() => _photoUrl = url),
              onPhotoRemoved: () => setState(() => _photoUrl = null),
            ),
          ),

          // Tab 3: Track Ticket
          RepairTrackingView(
            appState: widget.appState,
            onBookNow: () => _tabController.animateTo(1),
          ),
        ],
      ),
    );
  }
}

/// The new ticket number with a copy button, shown after booking.
class _TicketNumberBox extends StatelessWidget {
  final String ticketId;

  const _TicketNumberBox({required this.ticketId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: SvcColors.canvas,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SvcColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ticket number', style: TextStyle(fontSize: 11.5, color: SvcColors.muted)),
                SelectableText(
                  ticketId,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: SvcColors.ink, letterSpacing: 0.3),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Copy ticket number',
            icon: const Icon(Icons.copy_rounded, size: 18, color: SvcColors.primary),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: ticketId));
              if (context.mounted) {
                SvcSnackbar.show(context, 'Ticket number copied', type: SnackType.success);
              }
            },
          ),
        ],
      ),
    );
  }
}
