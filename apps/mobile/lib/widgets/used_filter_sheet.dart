import 'package:flutter/material.dart';
import '../theme_tokens.dart';
import '../data/used_products_data.dart';

class UsedFilterSheet extends StatefulWidget {
  final String initialCategory;
  final String initialGrade;
  final String initialSortBy;
  final void Function(String category, String grade, String sortBy) onApply;

  const UsedFilterSheet({
    super.key,
    required this.initialCategory,
    required this.initialGrade,
    required this.initialSortBy,
    required this.onApply,
  });

  static void show({
    required BuildContext context,
    required String currentCategory,
    required String currentGrade,
    required String currentSortBy,
    required void Function(String category, String grade, String sortBy) onApply,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => UsedFilterSheet(
        initialCategory: currentCategory,
        initialGrade: currentGrade,
        initialSortBy: currentSortBy,
        onApply: onApply,
      ),
    );
  }

  @override
  State<UsedFilterSheet> createState() => _UsedFilterSheetState();
}

class _UsedFilterSheetState extends State<UsedFilterSheet> {
  late String _selectedCategory;
  late String _selectedGrade;
  late String _selectedSortBy;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    _selectedGrade = widget.initialGrade;
    _selectedSortBy = widget.initialSortBy;
  }

  int get _activeFilterCount {
    int count = 0;
    if (_selectedCategory != 'All') count++;
    if (_selectedGrade != 'All') count++;
    if (_selectedSortBy != 'Featured') count++;
    return count;
  }

  void _reset() {
    setState(() {
      _selectedCategory = 'All';
      _selectedGrade = 'All';
      _selectedSortBy = 'Featured';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Sheet Header with Reset & Close
            Row(
              children: [
                const Icon(Icons.tune_rounded, color: SvcColors.primary, size: 22),
                const SizedBox(width: 8),
                const Text(
                  'Filter & Sort',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                if (_activeFilterCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFEDD5)),
                    ),
                    child: Text(
                      '$_activeFilterCount active',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: SvcColors.primary,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                TextButton(
                  onPressed: _reset,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(50, 32),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close',
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const Divider(height: 20, color: Color(0xFFF1F5F9)),

            // Section 1: Condition Grade
            _buildSectionTitle('Condition Grade'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kGradeFilters.map((gr) {
                final isSelected = gr['id'] == _selectedGrade;
                return ChoiceChip(
                  label: Text(gr['label']!),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedGrade = gr['id']!);
                  },
                  selectedColor: const Color(0xFF0F172A),
                  backgroundColor: const Color(0xFFF8FAFC),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 18),

            // Section 2: Category
            _buildSectionTitle('Gear Category'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: kUsedCategories.map((cat) {
                final isSelected = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedCategory = cat);
                  },
                  selectedColor: SvcColors.primary,
                  backgroundColor: const Color(0xFFF8FAFC),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? SvcColors.primary : const Color(0xFFE2E8F0),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 18),

            // Section 3: Sort Order
            _buildSectionTitle('Sort Results'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Featured',
                'Price: Low to High',
                'Price: High to Low',
              ].map((sort) {
                final isSelected = sort == _selectedSortBy;
                return ChoiceChip(
                  label: Text(sort),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedSortBy = sort);
                  },
                  selectedColor: const Color(0xFF0F172A),
                  backgroundColor: const Color(0xFFF8FAFC),
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // Action Button: Apply
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_selectedCategory, _selectedGrade, _selectedSortBy);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: SvcColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F172A),
        letterSpacing: -0.1,
      ),
    );
  }
}
