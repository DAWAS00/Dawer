import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../features/chatbot/dawa_chat_widget.dart';
import '../../../../../core/constants/waste_type_icons.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/models/user.dart';
import '../../../../features/auth/viewmodels/login_viewmodel.dart';
import '../viewmodels/marketplace_viewmodel.dart';
import '../widgets/market_item_card.dart';
import '../widgets/marketplace_collection_jobs_section.dart';
import '../widgets/marketplace_segment_bar.dart';
import '../market_item_details_view.dart';

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
    final items = vm.filteredItems;
    final collectionJobs = vm.collectionJobsFor(widget.currentUserName);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context)),

        // ── Pinned segment selector ──
        SliverPersistentHeader(
          pinned: true,
          delegate: MarketplaceSegmentDelegate(
            selectedIndex: _segment,
            listingsCount: items.length,
            jobsCount: collectionJobs.length,
            onChanged: (i) => setState(() => _segment = i),
          ),
        ),

        // ── Segment 0: seller listings ──
        if (_segment == 0) ...[
          SliverToBoxAdapter(child: _buildSearchBar(vm)),
          SliverToBoxAdapter(child: _buildCategoryChips(vm)),
          SliverToBoxAdapter(child: _buildResultsCount(items.length)),
          if (items.isEmpty)
            _buildEmptyListings()
          else
            _buildItemsList(context, vm, items),
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
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF14401F), Color(0xFF1E6B35)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 20, 20, 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.role == UserRole.driver
                  ? 'استلم وابيع'
                  : widget.role == UserRole.supplier
                      ? 'اشترِ وأوصل'
                      : 'استلم في منشأتك',
              style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'السوق',
                style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              Text(
                _segment == 0
                    ? 'تصفّح المواد المعروضة للبيع'
                    : 'وظائف التجميع من شركات التدوير',
                style:
                    GoogleFonts.cairo(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            child: Icon(
              _segment == 0
                  ? Icons.storefront_rounded
                  : Icons.work_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.smart_toy_rounded,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () => _openChatbot(context),
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

  Widget _buildSearchBar(MarketplaceViewModel vm) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          onChanged: vm.setSearch,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: GoogleFonts.cairo(
              fontSize: 14, color: const Color(0xFF191C1B)),
          decoration: InputDecoration(
            hintText: 'ابحث عن مواد، بائع، أو منطقة...',
            hintStyle: GoogleFonts.cairo(
                fontSize: 13, color: const Color(0xFF9CA3AF)),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            prefixIcon: const Icon(Icons.search_rounded,
                color: Color(0xFF9CA3AF), size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(MarketplaceViewModel vm) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          reverse: true,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: WasteTypeIcons.all.length,
          separatorBuilder: (_, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final (type, icon) = WasteTypeIcons.all[index];
            final isSelected = vm.selectedCategory == type;
            return GestureDetector(
              onTap: () => vm.setCategory(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF06402B)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: isSelected
                      ? null
                      : Border.all(color: const Color(0xFFE6E9E7)),
                  boxShadow: [
                    if (!isSelected)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      type.label,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF404943),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(icon,
                        size: 14,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF717973)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResultsCount(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF06402B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF06402B)),
            ),
          ),
          const Spacer(),
          Text(
            'العروض المتاحة',
            style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002819)),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildEmptyListings() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          children: [
            const Icon(Icons.storefront_rounded,
                size: 48, color: Color(0xFFD1D5DB)),
            const SizedBox(height: 10),
            Text(
              'لا توجد عروض حالياً',
              style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
    );
  }

  SliverPadding _buildItemsList(
    BuildContext context,
    MarketplaceViewModel vm,
    List<Order> items,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, index) => MarketItemCard(
            item: items[index],
            onTap: () {
              final marketVm = ctx.read<MarketplaceViewModel>();
              Navigator.of(ctx).push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: marketVm,
                    child: MarketItemDetailsView(
                      item: items[index],
                      role: widget.role,
                      onSupplierPurchaseConfirmed:
                          widget.onSupplierPurchaseConfirmed,
                    ),
                  ),
                ),
              );
            },
          ),
          childCount: items.length,
        ),
      ),
    );
  }
}
