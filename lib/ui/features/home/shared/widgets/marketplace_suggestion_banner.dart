import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../l10n/l10n.dart';
import '../viewmodels/marketplace_viewmodel.dart';

/// Dismissible green banner shown at top of marketplace when AI-suggested
/// categories are available from the signup license validation step.
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
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.surfaceAltBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  size: 15,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.marketSuggestedByLicense,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onDismiss,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    size: 15,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Category chips row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            reverse: true,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: OutlinedButton(
                    onPressed: onShowAll,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      side: BorderSide(
                        color: AppColors.primaryGreen.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      l10n.marketShowAllOrders,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
                ...categories.map(
                  (cat) => Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8),
                    child: _SuggestionChip(
                      label: cat,
                      onTap: () => onCategoryTap(cat),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.surfaceAltBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.search_rounded,
              size: 13,
              color: AppColors.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }
}
