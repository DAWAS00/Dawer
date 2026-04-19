import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class FilterGroup {
  final String? label;
  final List<String> options;
  final String selected;
  final void Function(String) onChanged;

  const FilterGroup({
    this.label,
    required this.options,
    required this.selected,
    required this.onChanged,
  });
}

class FilterChipRow extends StatelessWidget {
  final List<FilterGroup> groups;

  const FilterChipRow({super.key, required this.groups});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: groups.map(_buildGroup).toList(),
      ),
    );
  }

  Widget _buildGroup(FilterGroup group) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (group.label != null) ...[
          Text(
            group.label!,
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(width: 6),
        ],
        ...group.options.map((opt) => _buildChip(opt, group)),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildChip(String option, FilterGroup group) {
    final isSelected = option == group.selected;
    return GestureDetector(
      onTap: () => group.onChanged(option),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF06402B)
              : const Color(0xFFF2F4F2),
          borderRadius: BorderRadius.circular(30),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFFE6E9E7)),
        ),
        child: Text(
          option,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight:
                isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : const Color(0xFF404943),
          ),
        ),
      ),
    );
  }
}
