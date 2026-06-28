import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/l10n.dart';

/// Underline-style segment tabs for the marketplace.
/// Shows "Listings" and "Collection Jobs" with count badges.
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
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              _SegmentTab(
                label: l10n.marketSegmentJobs,
                icon: Icons.work_outline_rounded,
                count: jobsCount,
                isSelected: selectedIndex == 1,
                accentColor: AppColors.jobBlue,
                countBgColor: AppColors.jobBlueBg,
                onTap: () => onChanged(1),
              ),
              _SegmentTab(
                label: l10n.marketAvailableOffers,
                icon: Icons.storefront_outlined,
                count: listingsCount,
                isSelected: selectedIndex == 0,
                accentColor: AppColors.primaryGreen,
                countBgColor: AppColors.surfaceAlt,
                onTap: () => onChanged(0),
              ),
            ],
          ),
          // Animated underline indicator
          LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / 2;
              // Jobs = index 1 (left in RTL), Listings = index 0 (right in RTL)
              // In visual order: Jobs left, Listings right
              final isRtl = Directionality.of(context) == TextDirection.rtl;
              double indicatorLeft;
              if (isRtl) {
                // In RTL: jobs tab is on the right, listings on the left
                indicatorLeft = selectedIndex == 1 ? tabWidth : 0;
              } else {
                // In LTR: listings tab is on the left, jobs on the right
                indicatorLeft = selectedIndex == 0 ? 0 : tabWidth;
              }
              return Stack(
                children: [
                  Container(height: 2, color: const Color(0xFFE2E8E5)),
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    left: indicatorLeft,
                    child: Container(
                      width: tabWidth,
                      height: 2,
                      color: selectedIndex == 0
                          ? AppColors.primaryGreen
                          : AppColors.jobBlue,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;
  final bool isSelected;
  final Color accentColor;
  final Color countBgColor;
  final VoidCallback onTap;

  const _SegmentTab({
    required this.label,
    required this.icon,
    required this.count,
    required this.isSelected,
    required this.accentColor,
    required this.countBgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  icon,
                  key: ValueKey(isSelected),
                  size: 17,
                  color: isSelected ? accentColor : const Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? accentColor
                        : const Color(0xFF717973),
                  ),
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor : countBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : accentColor,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Combined sticky header delegate: search bar + segment tabs.
class MarketplaceSegmentDelegate extends SliverPersistentHeaderDelegate {
  final int selectedIndex;
  final int listingsCount;
  final int jobsCount;
  final ValueChanged<int> onChanged;
  final ValueChanged<String> onSearch;
  final String searchHint;

  const MarketplaceSegmentDelegate({
    required this.selectedIndex,
    required this.listingsCount,
    required this.jobsCount,
    required this.onChanged,
    required this.onSearch,
    required this.searchHint,
  });

  // search padding(10+6) + bar(44) + tabs(46) + underline(2) + buffer(4) = 112
  @override
  double get minExtent => 112;

  @override
  double get maxExtent => 112;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: shrinkOffset > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: _MarketSearchBar(
              hint: searchHint,
              onChanged: onSearch,
            ),
          ),
          // Segment tabs + underline
          MarketplaceSegmentBar(
            selectedIndex: selectedIndex,
            listingsCount: listingsCount,
            jobsCount: jobsCount,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(MarketplaceSegmentDelegate old) =>
      old.selectedIndex != selectedIndex ||
      old.listingsCount != listingsCount ||
      old.jobsCount != jobsCount ||
      old.searchHint != searchHint;
}

class _MarketSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const _MarketSearchBar({required this.hint, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8E5)),
      ),
      child: TextField(
        onChanged: onChanged,
        style: GoogleFonts.cairo(
          fontSize: 13,
          color: const Color(0xFF14241C),
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.cairo(
            fontSize: 13,
            color: const Color(0xFF9CA3AF),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primaryGreen,
            size: 20,
          ),
          suffixIcon: const Icon(
            Icons.tune_rounded,
            color: Color(0xFF9CA3AF),
            size: 18,
          ),
        ),
      ),
    );
  }
}
