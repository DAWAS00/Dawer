import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../viewmodels/marketplace_viewmodel.dart';

/// Animated banner shown at the top of the marketplace when AI-suggested
/// categories are available from the signup license validation step.
///
/// Consumes [MarketplaceViewModel] from the widget tree.
class MarketplaceSuggestionBanner extends StatelessWidget {
  const MarketplaceSuggestionBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MarketplaceViewModel>();

    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
      child: vm.showSuggestionBanner
          ? _BannerContent(
              categories: vm.aiSuggestedCategories,
              onCategoryTap: (cat) => vm.setSearch(cat),
              onDismiss: vm.dismissSuggestions,
              onShowAll: vm.showAllOrders,
            )
          : const SizedBox.shrink(),
    );
  }
}

class _BannerContent extends StatelessWidget {
  final List<String> categories;
  final void Function(String category) onCategoryTap;
  final VoidCallback onDismiss;
  final VoidCallback onShowAll;

  const _BannerContent({
    required this.categories,
    required this.onCategoryTap,
    required this.onDismiss,
    required this.onShowAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFCD34D)),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'اقتراحات بناءً على رخصتك', // TODO: localize
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF92400E),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onDismiss,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCD34D).withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 14,
                    color: Color(0xFF92400E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              children: [
                ...categories.map((cat) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _SuggestionChip(
                        label: cat,
                        onTap: () => onCategoryTap(cat),
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: OutlinedButton(
                    onPressed: onShowAll,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      side: const BorderSide(color: Color(0xFFC8860A), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'عرض كل الطلبات', // TODO: localize "Show All Orders"
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFC8860A).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFC8860A).withValues(alpha: 0.35),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF92400E),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.search_rounded,
              size: 13,
              color: Color(0xFFC8860A),
            ),
          ],
        ),
      ),
    );
  }
}
