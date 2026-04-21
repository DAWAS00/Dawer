import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../l10n/l10n.dart';

/// Sticky segment selector for the marketplace tab.
/// Shows two tabs: seller listings and collection jobs.
class MarketplaceSegmentBar extends StatelessWidget {
  final int selectedIndex;
  final int listingsCount;
  final int jobsCount;
  final ValueChanged<int> onChanged;

  const MarketplaceSegmentBar({
    super.key,
    required this.selectedIndex,
    required this.listingsCount,
    required this.jobsCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      color: const Color(0xFFF4F6F4),
      padding: const EdgeInsets.fromLTRB(15, 5, 15, 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            _SegmentOption(
              label: l10n.marketSegmentJobs,
              icon: Icons.work_rounded,
              count: jobsCount,
              isSelected: selectedIndex == 1,
              accentColor: const Color(0xFF14401F),
              onTap: () => onChanged(1),
            ),
            const SizedBox(width: 4),
            _SegmentOption(
              label: l10n.marketAvailableOffers,
              icon: Icons.storefront_rounded,
              count: listingsCount,
              isSelected: selectedIndex == 0,
              accentColor: const Color(0xFF06402B),
              onTap: () => onChanged(0),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _SegmentOption({
    required this.label,
    required this.icon,
    required this.count,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          // Button size: vertical = height, horizontal = side padding
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (count > 0) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$count',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : accentColor,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFF717973),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color:
                        isSelected ? Colors.white : const Color(0xFF404943),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// [SliverPersistentHeaderDelegate] that pins [MarketplaceSegmentBar] to top.
/// minExtent/maxExtent = outer-top(10) + pill(4) + button-vertical*2 + pill(4) + outer-bottom(10)
class MarketplaceSegmentDelegate extends SliverPersistentHeaderDelegate {
  final int selectedIndex;
  final int listingsCount;
  final int jobsCount;
  final ValueChanged<int> onChanged;

  const MarketplaceSegmentDelegate({
    required this.selectedIndex,
    required this.listingsCount,
    required this.jobsCount,
    required this.onChanged,
  });

  @override
  double get minExtent => 70;

  @override
  double get maxExtent => 70;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return MarketplaceSegmentBar(
      selectedIndex: selectedIndex,
      listingsCount: listingsCount,
      jobsCount: jobsCount,
      onChanged: onChanged,
    );
  }

  @override
  bool shouldRebuild(MarketplaceSegmentDelegate old) =>
      old.selectedIndex != selectedIndex ||
      old.listingsCount != listingsCount ||
      old.jobsCount != jobsCount;
}
