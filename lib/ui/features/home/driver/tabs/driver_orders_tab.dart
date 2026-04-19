import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../data/models/order.dart';
import '../../shared/order_card.dart';
import '../../shared/order_details_view.dart';
import '../../shared/widgets/collection_sale_card.dart';
import '../viewmodels/driver_home_viewmodel.dart';

void _showWeightDialog(
  BuildContext context,
  DriverHomeViewModel vm,
  String saleId,
) {
  showDialog<void>(
    context: context,
    builder: (_) => _WeightEntryDialog(
      onConfirm: (double? kg) {
        vm.completeCollectionSale(saleId, actualWeightKg: kg);
      },
    ),
  );
}

class DriverOrdersTab extends StatefulWidget {
  const DriverOrdersTab({super.key});

  @override
  State<DriverOrdersTab> createState() => _DriverOrdersTabState();
}

class _DriverOrdersTabState extends State<DriverOrdersTab> {
  String _filterAvailableType = 'الكل';
  String _filterActiveStatus  = 'الكل';
  String _filterActiveType    = 'الكل';
  String _filterHistoryPeriod = 'الكل';
  String _filterHistoryResult = 'الكل';

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DriverHomeViewModel>();

    final availableOrders = vm.available;
    final activeOrders    = [if (vm.active != null) vm.active!];
    final allSales        = vm.collectionSaleOrders;
    final acceptedSales   = allSales
        .where((s) =>
            s.status == OrderStatus.accepted ||
            s.status == OrderStatus.inTransit)
        .toList();
    final historySales    = allSales
        .where((s) =>
            s.status == OrderStatus.completed ||
            s.status == OrderStatus.cancelled)
        .toList();
    final completedPickups =
        vm.history.where((o) => o.status == OrderStatus.completed).toList();
    final cancelledPickups =
        vm.history.where((o) => o.status == OrderStatus.cancelled).toList();

    final availableCount = availableOrders.length;
    final activeCount    = activeOrders.length + acceptedSales.length;

    String tabLabel(String base, int count) =>
        count > 0 ? '$base ($count)' : base;

    return DefaultTabController(
      length: 3,
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
                  Tab(text: tabLabel('المتاحة', availableCount)),
                  Tab(text: tabLabel('النشطة', activeCount)),
                  const Tab(text: 'السجل'),
                ],
              ),
            );
          }),
          Expanded(
            child: TabBarView(
              children: [
                _buildAvailableTab(context, vm, availableOrders),
                _buildActiveTab(context, vm, activeOrders, acceptedSales),
                _buildHistoryTab(
                    context, completedPickups, cancelledPickups, historySales),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab 1 — المتاحة ──────────────────────────────────────────────────────

  Widget _buildAvailableTab(
    BuildContext context,
    DriverHomeViewModel vm,
    List<Order> available,
  ) {
    final filtered = available.where((o) {
      if (_filterAvailableType == 'طلب استلام') return o.type == OrderType.pickup;
      if (_filterAvailableType == 'وظيفة تجميع') return o.type == OrderType.collection;
      return true;
    }).toList();

    return Column(
      children: [
        _filterRow(
          chips: ['الكل', 'طلب استلام', 'وظيفة تجميع'],
          selected: _filterAvailableType,
          onSelected: (v) => setState(() => _filterAvailableType = v),
        ),
        Expanded(
          child: filtered.isEmpty
              ? _emptyState('لا توجد طلبات متاحة حالياً')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OrderCard(
                      order: filtered[i],
                      mode: OrderCardMode.driverAvailable,
                      onAction: () => vm.acceptOrder(filtered[i]),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  // ── Tab 2 — النشطة ───────────────────────────────────────────────────────

  Widget _buildActiveTab(
    BuildContext context,
    DriverHomeViewModel vm,
    List<Order> activeOrders,
    List<Order> acceptedSales,
  ) {
    final allItems = <_ActiveItem>[
      ...activeOrders.map(_ActiveItem.fromOrder),
      ...acceptedSales.map(_ActiveItem.fromSale),
    ]..sort((a, b) => b.order.createdAt.compareTo(a.order.createdAt));

    final filtered = allItems.where((item) {
      final statusOk = switch (_filterActiveStatus) {
        'مقبول'     => item.order.status == OrderStatus.accepted,
        'في الطريق' => item.order.status == OrderStatus.inTransit,
        _           => true,
      };
      final typeOk = switch (_filterActiveType) {
        'طلب استلام'    => !item.isSale,
        'التزام تجميع' => item.isSale,
        _              => true,
      };
      return statusOk && typeOk;
    }).toList();

    return Column(
      children: [
        _filterRow(
          chips: ['الكل', 'مقبول', 'في الطريق'],
          selected: _filterActiveStatus,
          onSelected: (v) => setState(() => _filterActiveStatus = v),
        ),
        _filterRow(
          chips: ['الكل', 'طلب استلام', 'التزام تجميع'],
          selected: _filterActiveType,
          onSelected: (v) => setState(() => _filterActiveType = v),
        ),
        Expanded(
          child: filtered.isEmpty
              ? _emptyState('لا توجد طلبات نشطة حالياً')
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
                              ? () => vm.startCollectionSaleTransit(order.id)
                              : null,
                          onComplete: order.status == OrderStatus.inTransit
                              ? () => _showWeightDialog(ctx, vm, order.id)
                              : null,
                          onCancel: (order.status == OrderStatus.accepted ||
                                  order.status == OrderStatus.inTransit)
                              ? () => vm.cancelCollectionSale(order.id)
                              : null,
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: OrderCard(
                          order: order,
                          mode: OrderCardMode.driverActive,
                          onAction: () => Navigator.of(ctx).push(
                            MaterialPageRoute(
                              builder: (_) => OrderDetailsView(
                                order: order,
                                onCompleteOrder: vm.completeOrder,
                                viewerRole: OrderDetailsViewerRole.driver,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
        ),
      ],
    );
  }

  // ── Tab 3 — السجل ────────────────────────────────────────────────────────

  Widget _buildHistoryTab(
    BuildContext context,
    List<Order> completedPickups,
    List<Order> cancelledPickups,
    List<Order> historySales,
  ) {
    final now = DateTime.now();

    bool periodMatch(DateTime dt) => switch (_filterHistoryPeriod) {
          'اليوم' =>
            dt.year == now.year && dt.month == now.month && dt.day == now.day,
          'هذا الأسبوع' => now.difference(dt).inDays < 7,
          'هذا الشهر'   => now.difference(dt).inDays < 30,
          _             => true,
        };

    bool resultMatch(OrderStatus s) => switch (_filterHistoryResult) {
          'مكتمل' => s == OrderStatus.completed,
          'ملغي'  => s == OrderStatus.cancelled,
          _       => true,
        };

    final allPickups = [...completedPickups, ...cancelledPickups]
        .where((o) => periodMatch(o.completedAt ?? o.createdAt) && resultMatch(o.status))
        .toList();

    final filteredSales = historySales
        .where((s) => periodMatch(s.completedAt ?? s.createdAt) && resultMatch(s.status))
        .toList();

    final allItems = <_HistoryItem>[
      ...allPickups.map((o) => _HistoryItem(
          order: o,
          isSale: false,
          sortDate: o.completedAt ?? o.createdAt)),
      ...filteredSales.map((s) => _HistoryItem(
          order: s,
          isSale: true,
          sortDate: s.completedAt ?? s.createdAt)),
    ]..sort((a, b) => b.sortDate.compareTo(a.sortDate));

    return Column(
      children: [
        _filterRow(
          chips: ['الكل', 'اليوم', 'هذا الأسبوع', 'هذا الشهر'],
          selected: _filterHistoryPeriod,
          onSelected: (v) => setState(() => _filterHistoryPeriod = v),
        ),
        _filterRow(
          chips: ['الكل', 'مكتمل', 'ملغي'],
          selected: _filterHistoryResult,
          onSelected: (v) => setState(() => _filterHistoryResult = v),
        ),
        Expanded(
          child: allItems.isEmpty
              ? _emptyState('لا يوجد سجل طلبات بعد')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: allItems.length,
                  itemBuilder: (ctx, i) {
                    final item = allItems[i];
                    if (item.isSale) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: CollectionSaleCard(sale: item.order),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OrderCard(
                                order: item.order,
                                mode: OrderCardMode.driverActive),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () => Navigator.of(ctx).push(
                                  MaterialPageRoute(
                                    builder: (_) => OrderDetailsView(
                                      order: item.order,
                                      viewerRole: OrderDetailsViewerRole.driver,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'عرض التفاصيل',
                                  style: GoogleFonts.cairo(
                                    fontSize: 13,
                                    color: const Color(0xFF1E5C35),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
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

// ── Helper data classes ───────────────────────────────────────────────────────

class _ActiveItem {
  final Order order;
  final bool isSale;

  const _ActiveItem._(this.order, this.isSale);

  factory _ActiveItem.fromOrder(Order o) => _ActiveItem._(o, false);
  factory _ActiveItem.fromSale(Order s)  => _ActiveItem._(s, true);
}

class _HistoryItem {
  final Order order;
  final bool isSale;
  final DateTime sortDate;

  const _HistoryItem({
    required this.order,
    required this.isSale,
    required this.sortDate,
  });
}

class _WeightEntryDialog extends StatefulWidget {
  final void Function(double?) onConfirm;

  const _WeightEntryDialog({required this.onConfirm});

  @override
  State<_WeightEntryDialog> createState() => _WeightEntryDialogState();
}

class _WeightEntryDialogState extends State<_WeightEntryDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'تأكيد التسليم',
        textAlign: TextAlign.right,
        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'أدخل الوزن الفعلي (اختياري)',
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.left,
            style: GoogleFonts.dmSans(),
            decoration: InputDecoration(
              suffixText: 'كغ',
              suffixStyle: GoogleFonts.cairo(),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('إلغاء',
              style: GoogleFonts.cairo(color: const Color(0xFF9CA3AF))),
        ),
        ElevatedButton(
          onPressed: () {
            final weightText = _controller.text.trim();
            final kg = weightText.isEmpty ? null : double.tryParse(weightText);
            Navigator.of(context).pop();
            widget.onConfirm(kg);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E5C35),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('تأكيد',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
