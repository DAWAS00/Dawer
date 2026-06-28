import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../features/chatbot/dawa_chat_widget.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/waste_type_icons.dart';
import '../../../../../core/layout/app_layout.dart';
import '../../../../../data/mock/order_mock_data.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../data/models/user.dart';
import '../../../../features/auth/viewmodels/login_viewmodel.dart';
import '../viewmodels/marketplace_viewmodel.dart';
import '../widgets/market_item_card.dart';
import '../widgets/marketplace_collection_jobs_section.dart';
import '../widgets/marketplace_segment_bar.dart';
import '../widgets/marketplace_suggestion_banner.dart';
import '../market_item_details_view.dart';
import '../../../../../data/models/order_labels.dart';
import '../../../../../l10n/l10n.dart';
import '../views/all_categories_view.dart';
import '../../../../core/components/dwaar_skeleton.dart';

class MarketplaceTab extends StatefulWidget {
  final UserRole role;
  final void Function(Order purchasedOrder)? onSupplierPurchaseConfirmed;
  final User? currentDriver;
  final String? currentUserName;
  final void Function(Order? sale)? onJobAccepted;

  const MarketplaceTab({
    super.key,
    required this.role,
    this.onSupplierPurchaseConfirmed,
    this.currentDriver,
    this.currentUserName,
    this.onJobAccepted,
  });

  @override
  State<MarketplaceTab> createState() => _MarketplaceTabState();
}

class _MarketplaceTabState extends State<MarketplaceTab> {
  int _segment = 0; // 0 = listings, 1 = collection jobs

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MarketplaceViewModel>();
    final l10n = context.l10n;
    final loading = vm.isLoading;
    final items = loading ? OrderMockData.skeletonOrders() : vm.filteredItems;
    final collectionJobs = vm.collectionJobsFor(widget.currentUserName);

    return CustomScrollView(
      slivers: [
        // ── Gradient header (scrolls away) ──
        SliverToBoxAdapter(child: _buildHeader(context)),

        // ── Pinned: search + segment tabs combined ──
        SliverPersistentHeader(
          pinned: true,
          delegate: MarketplaceSegmentDelegate(
            selectedIndex: _segment,
            listingsCount: items.length,
            jobsCount: collectionJobs.length,
            onChanged: (i) => setState(() => _segment = i),
            onSearch: vm.setSearch,
            searchHint: l10n.marketSearch,
          ),
        ),

        // ── Segment 0: seller listings ──
        if (_segment == 0) ...[
          // AI suggestion banner
          if (!loading && vm.hasUserCategories)
            const SliverToBoxAdapter(
                child: MarketplaceSuggestionBanner()),
          // Category filter strip (always shown)
          if (!loading)
            SliverToBoxAdapter(
                child: _buildCategoryStrip(context, vm)),
          // Results header
          SliverToBoxAdapter(
              child: _buildResultsHeader(
                  context, loading ? 0 : items.length, vm)),
          // Items or empty state
          if (!loading && items.isEmpty)
            _buildEmptyListings(context)
          else
            SliverToBoxAdapter(
              child: DwaarSkeleton(
                enabled: loading,
                child: _buildItemsColumn(context, vm, items),
              ),
            ),
        ],

        // ── Segment 1: collection jobs ──
        if (_segment == 1)
          CollectionJobsSection(
            jobs: collectionJobs,
            role: widget.role,
            vm: vm,
            currentDriver: widget.currentDriver,
            currentUserName: widget.currentUserName,
            onJobAccepted: widget.onJobAccepted,
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A3D20), Color(0xFF1A6B3C)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      padding: EdgeInsetsDirectional.fromSTEB(
          20, MediaQuery.of(context).padding.top + 20, 20, 20),
      child: Row(
        children: [
          // Role badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Text(
              widget.role == UserRole.driver
                  ? l10n.marketDriverRole
                  : widget.role == UserRole.supplier
                      ? l10n.marketSupplierRole
                      : l10n.marketRecyclingRole,
              style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ),
          const Spacer(),
          // Title + subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                l10n.marketTitle,
                style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white),
              ),
              Text(
                _segment == 0
                    ? l10n.marketBrowse
                    : l10n.marketCollectionJobsSubtitle,
                style: GoogleFonts.cairo(
                    fontSize: 11, color: Colors.white60),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Chatbot button
          GestureDetector(
            onTap: () => _openChatbot(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Icon(Icons.smart_toy_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _openChatbot(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => const Scaffold(
          backgroundColor: Color(0xFF06402B),
          body: DawaChatWidget(),
        ),
      ),
    );
  }

  Widget _buildCategoryStrip(
      BuildContext context, MarketplaceViewModel vm) {
    final locale = Localizations.localeOf(context);
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      child: SizedBox(
        height: 38,
        child: ListView(
          scrollDirection: Axis.horizontal,
          reverse: true,
          padding: const EdgeInsetsDirectional.only(start: 16, end: 16),
          children: [
            // "All" chip at logical end (rightmost in RTL)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 8),
              child: GestureDetector(
                onTap: () => vm.setCategory(null),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: vm.selectedCategory == null
                        ? AppColors.primaryGreen
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: vm.selectedCategory == null
                        ? null
                        : Border.all(
                            color: AppColors.surfaceAltBorder),
                    boxShadow: vm.selectedCategory != null
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.marketCategoryAll,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: vm.selectedCategory == null
                              ? Colors.white
                              : const Color(0xFF404943),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.apps_rounded,
                        size: 13,
                        color: vm.selectedCategory == null
                            ? Colors.white
                            : const Color(0xFF717973),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Waste type chips
            ...WasteTypeIcons.all.map((entry) {
              final (type, icon) = entry;
              final isSelected = vm.selectedCategory == type;
              return Padding(
                padding: const EdgeInsetsDirectional.only(start: 8),
                child: GestureDetector(
                  onTap: () => vm.setCategory(type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryGreen
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected
                          ? null
                          : Border.all(
                              color: AppColors.surfaceAltBorder),
                      boxShadow: !isSelected
                          ? [
                              BoxShadow(
                                color:
                                    Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          type.labelFor(locale),
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF404943),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          icon,
                          size: 13,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF717973),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsHeader(
      BuildContext context, int count, MarketplaceViewModel vm) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          // All categories link
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: vm,
                  child: const AllCategoriesView(),
                ),
              ),
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.surfaceAltBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.category_outlined,
                      size: 13, color: AppColors.primaryGreen),
                  const SizedBox(width: 4),
                  Text(
                    'كل الفئات',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Results count
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            l10n.marketAvailableOffers,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0D1F15),
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildEmptyListings(BuildContext context) {
    final l10n = context.l10n;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
        child: Container(
          width: double.infinity,
          padding:
              const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.surfaceAltBorder),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  size: 32,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.marketNoOffers,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.marketNoOffersBody,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: const Color(0xFF9CA3AF),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemsColumn(
    BuildContext context,
    MarketplaceViewModel vm,
    List<Order> items,
  ) {
    final layout = context.layout;
    final edgePad = EdgeInsets.fromLTRB(layout.hPad, 4, layout.hPad, 100);

    Widget buildCard(Order item) => MarketItemCard(
          item: item,
          onTap: () {
            final marketVm = context.read<MarketplaceViewModel>();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: marketVm,
                  child: MarketItemDetailsView(
                    item: item,
                    role: widget.role,
                    onSupplierPurchaseConfirmed:
                        widget.onSupplierPurchaseConfirmed,
                  ),
                ),
              ),
            );
          },
        );

    if (layout.isWide) {
      return Padding(
        padding: edgePad,
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: layout.marketMaxExtent,
            mainAxisExtent: 200,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => buildCard(items[i]),
        ),
      );
    }

    return Padding(
      padding: edgePad,
      child: Column(
        children: items.map(buildCard).toList(),
      ),
    );
  }
}
