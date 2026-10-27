import 'package:flutter/material.dart';
import '../theme_tokens.dart';
import '../data/repair_services_data.dart';
import '../widgets/repair_how_it_works_sheet.dart';
import '../screens/estimator_screen.dart';
import '../state/app_state.dart';
import '../utils/format.dart';
import '../config/business_contact.dart';

class RepairOverviewView extends StatefulWidget {
  final AppState appState;
  final Function(String category) onSelectDepartment;
  final Function(String category, String symptomTitle) onSelectSymptom;
  final Function(MarketplaceRepairService service) onSelectService;
  final VoidCallback onBookDirect;

  const RepairOverviewView({
    super.key,
    required this.appState,
    required this.onSelectDepartment,
    required this.onSelectSymptom,
    required this.onSelectService,
    required this.onBookDirect,
  });

  @override
  State<RepairOverviewView> createState() => _RepairOverviewViewState();
}

String _tidyTurnaround(String t) => t.replaceAll(' - ', '–').replaceAll('Hours', 'hours');

String _rs(int amount) => formatRs(amount);

class _RepairOverviewViewState extends State<RepairOverviewView> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final _searchController = TextEditingController();

  final List<String> _categoryFilters = [
    'All',
    'Camera',
    'Lens',
    'Drone',
    'Laptop',
    'AC',
    'TV & Display',
    'CCTV',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MarketplaceRepairService> get _filteredServices {
    final q = _searchQuery.toLowerCase();
    return kMarketplaceServices.where((svc) {
      final matchesQuery = q.isEmpty ||
          svc.title.toLowerCase().contains(q) ||
          svc.shortDescription.toLowerCase().contains(q) ||
          svc.category.toLowerCase().contains(q);
      if (!matchesQuery) return false;
      if (_selectedCategory == 'All') return true;
      return svc.category.toLowerCase() == _selectedCategory.toLowerCase();
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final services = _filteredServices;

    return ListView(
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _buildIntroCard(),
        const SizedBox(height: 14),
        _buildFacts(),
        const SizedBox(height: 28),

        _sectionTitle('What needs fixing?'),
        const SizedBox(height: 12),
        _buildDepartments(),
        const SizedBox(height: 28),

        _sectionTitle('Popular repairs'),
        const SizedBox(height: 12),
        _buildSearchField(),
        const SizedBox(height: 12),
        _buildCategoryChips(),
        const SizedBox(height: 12),
        if (services.isEmpty) _buildEmptySearchResults() else _buildServiceList(services),
        const SizedBox(height: 12),
        _buildEstimatorRow(),
        const SizedBox(height: 28),

        _sectionTitle('Visit the workshop'),
        const SizedBox(height: 12),
        _buildWorkshopCard(context),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: SvcColors.ink),
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: SvcColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SvcColors.border),
      );

  // Intro: what the service is, in plain words, with the two main actions.
  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: SvcColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SvcColors.primaryBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Free inspection before every repair',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: SvcColors.ink, height: 1.25),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bring your device to our Station Road workshop or book a pickup. We check it, send you a quote, and only start after you approve.',
            style: TextStyle(fontSize: 14, color: SvcColors.inkSecondary, height: 1.45),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: widget.onBookDirect,
              style: ElevatedButton.styleFrom(
                backgroundColor: SvcColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
              ),
              child: const Text('Book a repair'),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: TextButton(
              onPressed: () => showHowItWorksFullSheet(context),
              style: TextButton.styleFrom(foregroundColor: SvcColors.ink, minimumSize: const Size(44, 44)),
              child: const Text('How it works', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacts() {
    const facts = [
      (Icons.search_rounded, 'Free inspection'),
      (Icons.verified_user_outlined, '90-day warranty'),
      (Icons.settings_suggest_outlined, 'Genuine parts'),
      (Icons.two_wheeler_outlined, 'Pickup in Janakpur'),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 3.6,
      children: [
        for (final (icon, label) in facts)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: _cardDecoration,
            child: Row(
              children: [
                Icon(icon, size: 18, color: SvcColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SvcColors.ink),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDepartments() {
    return Container(
      decoration: _cardDecoration,
      child: Column(
        children: [
          for (var i = 0; i < kRepairDepartments.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 64, color: SvcColors.borderSubtle),
            _departmentRow(kRepairDepartments[i]),
          ],
        ],
      ),
    );
  }

  Widget _departmentRow(RepairDepartment dept) {
    return InkWell(
      onTap: () => widget.onSelectDepartment(dept.name),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: SvcColors.primarySoft, borderRadius: BorderRadius.circular(10)),
              child: Icon(dept.icon, size: 20, color: SvcColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dept.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: SvcColors.ink),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'From ${_rs(dept.startingPrice)} · ${_tidyTurnaround(dept.turnaround)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: SvcColors.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: SvcColors.subtle),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value.trim()),
      textInputAction: TextInputAction.search,
      style: const TextStyle(fontSize: 15, color: SvcColors.ink),
      decoration: InputDecoration(
        hintText: 'Search, e.g. sensor cleaning',
        hintStyle: const TextStyle(color: SvcColors.subtle),
        prefixIcon: const Icon(Icons.search_rounded, color: SvcColors.muted, size: 20),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close_rounded, size: 18, color: SvcColors.muted),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              ),
        filled: true,
        fillColor: SvcColors.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: SvcColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: SvcColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: SvcColors.primary, width: 1.4)),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categoryFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final cat = _categoryFilters[i];
          final selected = _selectedCategory == cat;
          return ChoiceChip(
            label: Text(cat),
            selected: selected,
            showCheckmark: false,
            onSelected: (_) => setState(() => _selectedCategory = cat),
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : SvcColors.ink,
            ),
            selectedColor: SvcColors.ink,
            backgroundColor: SvcColors.surface,
            side: BorderSide(color: selected ? SvcColors.ink : SvcColors.border),
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            visualDensity: VisualDensity.compact,
          );
        },
      ),
    );
  }

  Widget _buildServiceList(List<MarketplaceRepairService> services) {
    return Container(
      decoration: _cardDecoration,
      child: Column(
        children: [
          for (var i = 0; i < services.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 14, endIndent: 14, color: SvcColors.borderSubtle),
            _serviceRow(services[i]),
          ],
        ],
      ),
    );
  }

  Widget _serviceRow(MarketplaceRepairService svc) {
    return InkWell(
      onTap: () => widget.onSelectService(svc),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    svc.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: SvcColors.ink, height: 1.3),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    svc.shortDescription,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: SvcColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_rs(svc.price), style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: SvcColors.ink)),
                const SizedBox(height: 3),
                Text(_tidyTurnaround(svc.turnaround.split(' • ').first),
                    style: const TextStyle(fontSize: 12, color: SvcColors.muted)),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: SvcColors.subtle),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySearchResults() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration,
      child: Column(
        children: [
          const Text(
            'No matching repairs',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: SvcColors.ink),
          ),
          const SizedBox(height: 4),
          const Text(
            'Describe the problem and we will inspect it for free.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: SvcColors.muted),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: widget.onBookDirect,
            style: OutlinedButton.styleFrom(
              foregroundColor: SvcColors.ink,
              side: const BorderSide(color: SvcColors.borderStrong),
              minimumSize: const Size(44, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Describe your problem', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimatorRow() {
    return Material(
      color: SvcColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: SvcColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: const Icon(Icons.calculate_outlined, color: SvcColors.primary),
        title: const Text(
          'Not sure what it will cost?',
          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: SvcColors.ink),
        ),
        subtitle: const Text('Get an estimate in a minute', style: TextStyle(fontSize: 13, color: SvcColors.muted)),
        trailing: const Icon(Icons.chevron_right_rounded, color: SvcColors.subtle),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EstimatorScreen(appState: widget.appState)),
        ),
      ),
    );
  }

  Widget _buildWorkshopCard(BuildContext context) {
    Widget row(IconData icon, String title, String detail, VoidCallback onTap) {
      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Icon(icon, color: SvcColors.inkSecondary),
        title: Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: SvcColors.ink)),
        subtitle: Text(detail, style: const TextStyle(fontSize: 13, color: SvcColors.muted)),
        trailing: const Icon(Icons.chevron_right_rounded, color: SvcColors.subtle),
        onTap: onTap,
      );
    }

    return Material(
      color: SvcColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: SvcColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          row(Icons.location_on_outlined, 'Station Road, Janakpur', 'Near Ramanand Chowk · ${BusinessContact.hoursShort}',
              () => _showLabContactModal(context)),
          const Divider(height: 1, indent: 56, color: SvcColors.borderSubtle),
          row(Icons.engineering_outlined, 'Our technicians', 'Who will work on your device',
              () => _showTechniciansModal(context)),
          const Divider(height: 1, indent: 56, color: SvcColors.borderSubtle),
          row(Icons.receipt_long_outlined, 'How pricing works', 'Inspection, quote and approval',
              () => showHowItWorksFullSheet(context)),
        ],
      ),
    );
  }

  void _showTechniciansModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.engineering_rounded, color: SvcColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Lead Certified Engineers',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: SvcColors.ink),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...kLabTechnicians.map((tech) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: SvcColors.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: SvcColors.primarySoft,
                          child: Icon(tech.icon, color: SvcColors.primary, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(tech.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(tech.speciality, style: const TextStyle(fontSize: 11.5, color: SvcColors.muted)),
                              const SizedBox(height: 2),
                              Text('★ ${tech.rating} (${tech.jobsCompleted} completed repairs)', style: const TextStyle(fontSize: 11, color: Color(0xFF047857), fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLabContactModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.location_on_rounded, color: SvcColors.primary),
                    SizedBox(width: 8),
                    Text(
                      '${BusinessContact.name} Workshop',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: SvcColors.ink),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '${BusinessContact.street}, ${BusinessContact.city}, Nepal',
                  style: TextStyle(fontSize: 13, height: 1.4, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 8),
                const Text(
                  '${BusinessContact.hours}\nPhone & WhatsApp: ${BusinessContact.phoneDisplay}',
                  style: TextStyle(fontSize: 12, height: 1.4, color: SvcColors.muted),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          callWorkshop(context);
                        },
                        icon: const Icon(Icons.call_rounded, size: 16),
                        label: const Text('Call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SvcColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          whatsappWorkshop(context, message: 'Hello ${BusinessContact.name}, I have a question about a repair.');
                        },
                        icon: const Icon(Icons.chat_rounded, size: 16, color: Color(0xFF16A34A)),
                        label: const Text('WhatsApp', style: TextStyle(color: Color(0xFF16A34A))),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
