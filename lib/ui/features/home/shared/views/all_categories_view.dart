import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/waste_type_icons.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/models/order_labels.dart';
import '../../../../../data/models/user_role.dart';
import '../viewmodels/marketplace_viewmodel.dart';
import '../widgets/market_item_card.dart';
import '../market_item_details_view.dart';

class AllCategoriesView extends StatelessWidget {
  const AllCategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MarketplaceViewModel>();
    final allItems = vm.filteredItems;
    final locale = Localizations.localeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF06402B),
        foregroundColor: Colors.white,
        title: Text(
          'الفئات والطلبات',
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 32),
        itemCount: WasteTypeIcons.all.length,
        itemBuilder: (context, index) {
          final (type, icon) = WasteTypeIcons.all[index];
          final categoryItems = allItems
              .where((o) => o.wasteTypes.contains(type))
              .toList();

          return _CategorySection(
            type: type,
            icon: icon,
            items: categoryItems,
            locale: locale,
            vm: vm,
          );
        },
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.type,
    required this.icon,
    required this.items,
    required this.locale,
    required this.vm,
  });

  final WasteType type;
  final IconData icon;
  final List<Order> items;
  final dynamic locale;
  final MarketplaceViewModel vm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section header
        Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF06402B).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              if (items.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06402B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${items.length}',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              const Spacer(),
              Text(
                type.labelFor(locale),
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002819),
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 20, color: const Color(0xFF06402B)),
            ],
          ),
        ),

        // Items or empty state
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
            child: Text(
              'لا توجد طلبات',
              textAlign: TextAlign.end,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: const Color(0xFF9CA3AF),
              ),
            ),
          )
        else
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: MarketItemCard(
                item: item,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: vm,
                      child: MarketItemDetailsView(
                        item: item,
                        role: UserRole.supplier,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
