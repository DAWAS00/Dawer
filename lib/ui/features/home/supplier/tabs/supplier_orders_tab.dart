import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/services/app_order_store.dart';
import '../../shared/widgets/collection_sale_card.dart';
import '../../shared/widgets/rate_driver_sheet.dart';
import '../widgets/supplier_order_card.dart';

class SupplierOrdersTab extends StatefulWidget {
  final List<Order> activeOrders;
  final List<Order> completedOrders;
  final List<Order> cancelledOrders;
  final List<Order> collectionSaleOrders;
  final String? Function(String orderId) onCancelOrder;
  final ValueChanged<String>? onCancelSale;
  final String? Function(String saleId)? onStartTransit;
  final String? Function(String saleId, {double? actualWeightKg})? onComplete;

  const SupplierOrdersTab({
    super.key,
    required this.activeOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    this.collectionSaleOrders = const [],
    required this.onCancelOrder,
    this.onCancelSale,
    this.onStartTransit,
    this.onComplete,
  });

  @override
  State<SupplierOrdersTab> createState() => _SupplierOrdersTabState();
}

class _SupplierOrdersTabState extends State<SupplierOrdersTab> {
  String _filterActiveType     = 'الكل';
  String _filterActiveStatus   = 'الكل';
  String _filterHistoryPeriod  = 'الكل';
  String _filterHistoryWasteType = 'الكل';

  @override
  Widget build(BuildContext context) {
    final activeCollectionSales = widget.collectionSaleOrders
        .where((s) =>
            s.status == OrderStatus.accepted ||
            s.status == OrderStatus.inTransit)
        .toList();

    final activeCount =
        widget.activeOrders.length + activeCollectionSales.length;

    String tabLabel(String base, int count) =>
        count > 0 ? '$base ($count)' : base;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Builder(builder: (ctx) {
            final cs = Theme.of(ctx).colorScheme;
            return Container(
              height: 52,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              decoration: BoxDecoration(
                color: cs.onSurface.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: const Color(0xFF06402B),
                  borderRadius: BorderRadius.circular(30),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(4),
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: cs.onSurface.withValues(alpha: 0.6),
                labelStyle: GoogleFonts.cairo(
                    fontSize: 13, fontWeight: FontWeight.bold),
                unselectedLabelStyle: GoogleFonts.cairo(fontSize: 13),
                tabs: [
                  Tab(text: tabLabel('النشطة', activeCount)),
                  const Tab(text: 'السجل'),
                ],
              ),
            );
          }),
          Expanded(
            child: TabBarView(
              children: [
                _buildActiveTab(context, activeCollectionSales),
                _buildHistoryTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 1 — النشطة ───────────────────────────────────────────────────────

  Widget _buildActiveTab(
      BuildContext context, List<Order> activeCollectionSales) {
    final allItems = <_ActiveItem>[
      ...widget.activeOrders.map(_ActiveItem.fromOrder),
      ...activeCollectionSales.map(_ActiveItem.fromSale),
    ]..sort((a, b) => b.order.createdAt.compareTo(a.order.createdAt));

    final filtered = allItems.where((item) {
      final typeOk = switch (_filterActiveType) {
        'طلب استلام'    => !item.isSale,
        'التزام تجميع' => item.isSale,
        _              => true,
      };
      final statusOk = switch (_filterActiveStatus) {
        'قيد الانتظار' => item.order.status == OrderStatus.pending,
        'تم القبول'    => item.order.status == OrderStatus.accepted,
        'في الطريق'    => item.order.status == OrderStatus.inTransit,
        _              => true,
      };
      return typeOk && statusOk;
    }).toList();

    return Column(
      children: [
        _filterRow(
          chips: ['الكل', 'طلب استلام', 'التزام تجميع'],
          selected: _filterActiveType,
          onSelected: (v) => setState(() => _filterActiveType = v),
        ),
        _filterRow(
          chips: ['الكل', 'قيد الانتظار', 'تم القبول', 'في الطريق'],
          selected: _filterActiveStatus,
          onSelected: (v) => setState(() => _filterActiveStatus = v),
        ),
        Expanded(
          child: filtered.isEmpty
              ? _emptyState('لا توجد طلبات نشطة.')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final item = filtered[i];
                    final order = item.order;
                    if (item.isSale) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CollectionSaleCard(
                          sale: order,
                          onStartTransit: order.status == OrderStatus.accepted
                              ? () => widget.onStartTransit?.call(order.id)
                              : null,
                          onComplete: order.status == OrderStatus.inTransit
                              ? () => widget.onComplete?.call(order.id)
                              : null,
                          onCancel: (order.status == OrderStatus.accepted ||
                                  order.status == OrderStatus.inTransit)
                              ? () => widget.onCancelSale?.call(order.id)
                              : null,
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SupplierOrderCard(
                          order: order,
                          canCancel: order.status == OrderStatus.pending,
                          onCancelOrder: widget.onCancelOrder,
                        ),
                      );
                    }
                  },
                ),
        ),
      ],
    );
  }

  // ── Tab 2 — السجل ────────────────────────────────────────────────────────

  Widget _buildHistoryTab(BuildContext context) {
    final now = DateTime.now();
    final allHistory = [...widget.completedOrders, ...widget.cancelledOrders];

    // Collect unique WasteType labels for dynamic chips
    final wasteLabels = <String>{};
    for (final o in allHistory) {
      for (final t in o.wasteTypes) {
        wasteLabels.add(t.label);
      }
    }
    final wasteChips = ['الكل', ...wasteLabels.toList()..sort()];

    bool periodMatch(DateTime dt) => switch (_filterHistoryPeriod) {
          'اليوم' =>
            dt.year == now.year && dt.month == now.month && dt.day == now.day,
          'هذا الأسبوع' => now.difference(dt).inDays < 7,
          'هذا الشهر'   => now.difference(dt).inDays < 30,
          _             => true,
        };

    final filtered = allHistory.where((o) {
      if (!periodMatch(o.createdAt)) return false;
      if (_filterHistoryWasteType != 'الكل') {
        if (!o.wasteTypes.any((t) => t.label == _filterHistoryWasteType)) {
          return false;
        }
      }
      return true;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Column(
      children: [
        _filterRow(
          chips: ['الكل', 'اليوم', 'هذا الأسبوع', 'هذا الشهر'],
          selected: _filterHistoryPeriod,
          onSelected: (v) => setState(() => _filterHistoryPeriod = v),
        ),
        _filterRow(
          chips: wasteChips,
          selected: _filterHistoryWasteType,
          onSelected: (v) => setState(() => _filterHistoryWasteType = v),
        ),
        Expanded(
          child: filtered.isEmpty
              ? _emptyState('لا يوجد سجل طلبات بعد')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) {
                    final order = filtered[i];
                    final canRate = order.status == OrderStatus.completed &&
                        order.driverName != null &&
                        order.driverRating == null;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SupplierOrderCard(
                            order: order,
                            canCancel: false,
                            onCancelOrder: widget.onCancelOrder,
                          ),
                          if (canRate)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () => RateDriverSheet.show(
                                  ctx,
                                  order: order,
                                  onSubmit: (rating) => context
                                      .read<AppOrderStore>()
                                      .submitDriverRating(order.id, rating),
                                ),
                                icon: const Icon(
                                  Icons.star_rounded,
                                  size: 16,
                                  color: Color(0xFFC8860A),
                                ),
                                label: Text(
                                  'تقييم السائق',
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFC8860A),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  Widget _filterRow({
    required List<String> chips,
    required String selected,
    required ValueChanged<String> onSelected,
  }) {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return SizedBox(
        height: 44,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            children: chips.map((chip) {
              final isSelected = chip == selected;
              return Padding(
                padding: const EdgeInsets.only(left: 8),
                child: GestureDetector(
                  onTap: () => onSelected(chip),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    height: 32,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF06402B)
                          : cs.onSurface.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF06402B)
                            : cs.onSurface.withValues(alpha: 0.12),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      chip,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? Colors.white
                            : cs.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  Widget _emptyState(String message) {
    return Center(
      child: Text(
        message,
        style: GoogleFonts.cairo(
            fontSize: 14, color: const Color(0xFF717973)),
      ),
    );
  }
}

// ── Helper data class ─────────────────────────────────────────────────────────

class _ActiveItem {
  final Order order;
  final bool isSale;

  const _ActiveItem._(this.order, this.isSale);

  factory _ActiveItem.fromOrder(Order o) => _ActiveItem._(o, false);
  factory _ActiveItem.fromSale(Order s)  => _ActiveItem._(s, true);
}
