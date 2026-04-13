import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../data/models/order.dart';
import '../../../../features/auth/viewmodels/login_viewmodel.dart';
import '../viewmodels/marketplace_viewmodel.dart';
import '../widgets/market_item_card.dart';
import '../market_item_details_view.dart';

class MarketplaceTab extends StatelessWidget {
  final UserRole role;
  final void Function(Order purchasedOrder)? onSupplierPurchaseConfirmed;

  const MarketplaceTab({
    super.key,
    required this.role,
    this.onSupplierPurchaseConfirmed,
  });

  static const List<(WasteType, IconData)> _categories = [
    (WasteType.paper, Icons.newspaper_rounded),
    (WasteType.plastic, Icons.local_drink_rounded),
    (WasteType.metal, Icons.hardware_rounded),
    (WasteType.glass, Icons.wine_bar_rounded),
    (WasteType.electronics, Icons.devices_rounded),
    (WasteType.organic, Icons.eco_rounded),
    (WasteType.furniture, Icons.chair_rounded),
    (WasteType.oil, Icons.water_drop_rounded),
    (WasteType.tires, Icons.tire_repair_rounded),
    (WasteType.construction, Icons.construction_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MarketplaceViewModel>();
    final items = vm.filteredItems;

    return CustomScrollView(
      slivers: [
        // ── Header ──
        SliverToBoxAdapter(child: _buildHeader(context)),

        // ── Search bar ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
                style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF191C1B)),
                decoration: InputDecoration(
                  hintText: 'ابحث عن مواد، بائع، أو منطقة...',
                  hintStyle: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF9CA3AF)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF9CA3AF), size: 22),
                ),
              ),
            ),
          ),
        ),

        // ── Category chips ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                separatorBuilder: (_, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final (type, icon) = _categories[index];
                  final isSelected = vm.selectedCategory == type;
                  return GestureDetector(
                    onTap: () => vm.setCategory(type),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF06402B) : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: isSelected ? null : Border.all(color: const Color(0xFFE6E9E7)),
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
                              color: isSelected ? Colors.white : const Color(0xFF404943),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(icon, size: 14, color: isSelected ? Colors.white : const Color(0xFF717973)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // ── Results count ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06402B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${items.length}',
                    style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF06402B)),
                  ),
                ),
                const Spacer(),
                Text(
                  'العروض المتاحة',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002819),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Items list ──
        if (items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.storefront_rounded, size: 56, color: const Color(0xFFD1D5DB)),
                  const SizedBox(height: 12),
                  Text(
                    'لا توجد عروض حالياً',
                    style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF9CA3AF)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'جرّب البحث بكلمات أخرى أو تصفية مختلفة',
                    style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFFBBBFBD)),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => MarketItemCard(
                  item: items[index],
                  onTap: () {
                    final marketVm = context.read<MarketplaceViewModel>();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: marketVm,
                          child: MarketItemDetailsView(
                            item: items[index],
                            role: role,
                            onSupplierPurchaseConfirmed:
                                onSupplierPurchaseConfirmed,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                childCount: items.length,
              ),
            ),
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
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  role == UserRole.driver
                      ? 'استلم وابيع'
                      : role == UserRole.supplier
                          ? 'اشترِ وأوصل'
                          : 'استلم في منشأتك',
                  style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
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
                  color: Colors.white,
                ),
              ),
              Text(
                'تصفّح المواد المعروضة للبيع',
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }
}
