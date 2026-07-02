import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/mock/order_mock_data.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../../l10n/l10n.dart';
import '../../shared/order_card.dart';
import '../../shared/order_details_view.dart';
import '../../shared/widgets/collection_sale_card.dart';
import '../viewmodels/driver_home_viewmodel.dart';
import '../../../../core/components/dwaar_skeleton.dart';

void _handleStartTransit(
  BuildContext context,
  Order sale,
  String? Function(String saleId) onStartTransit,
) {
  final error = onStartTransit(sale.id);
  if (error != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error, style: GoogleFonts.cairo(color: Colors.white)),
        backgroundColor: const Color(0xFF991B1B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

void _showCompleteDialog(
  BuildContext context,
  Order sale,
  String? Function(String saleId, {double? actualWeightKg}) onComplete,
) {
  final weightController = TextEditingController();
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        context.l10n.orderDeliveryConfirmTitle,
        textAlign: TextAlign.right,
        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            context.l10n.orderDeliveryConfirmMsg,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(),
          ),
          if (sale.paymentModel == PaymentModel.perKg) ...[
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: context.l10n.orderActualWeight,
                labelStyle: GoogleFonts.cairo(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(context.l10n.cancel, style: GoogleFonts.cairo()),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(ctx);
            final weightText = weightController.text.trim();
            final weight = weightText.isEmpty
                ? null
                : double.tryParse(weightText);
            final error = onComplete(sale.id, actualWeightKg: weight);
            if (error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    error,
                    style: GoogleFonts.cairo(color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF991B1B),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.jobBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            context.l10n.confirm,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}

const _activeStatuses = {
  OrderStatus.accepted,
  OrderStatus.arrivedAtPickup,
  OrderStatus.inTransit,
  OrderStatus.arrivedAtDropoff,
};

class DriverOrdersTab extends StatefulWidget {
  final List<Order> history;
  final Order? active;
  final List<Order> collectionSaleOrders;
  final ValueChanged<Order>? onCompleteOrder;
  final ValueChanged<String>? onCancelSale;
  final String? Function(String saleId)? onStartTransit;
  final String? Function(String saleId, {double? actualWeightKg})? onComplete;
  final Future<String?> Function(Order)? onMarkArrivedAtPickup;
  final Future<String?> Function(Order)? onMarkArrivedAtDropoff;

  const DriverOrdersTab({
    super.key,
    required this.history,
    required this.active,
    this.collectionSaleOrders = const [],
    this.onCompleteOrder,
    this.onCancelSale,
    this.onStartTransit,
    this.onComplete,
    this.onMarkArrivedAtPickup,
    this.onMarkArrivedAtDropoff,
  });

  @override
  State<DriverOrdersTab> createState() => _DriverOrdersTabState();
}

class _DriverOrdersTabState extends State<DriverOrdersTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final loading = context.watch<DriverHomeViewModel>().isLoading;
    final skeletons = OrderMockData.skeletonOrders();
    final all = loading
        ? skeletons
        : [if (widget.active != null) widget.active!, ...widget.history];
    final activeList = loading
        ? skeletons
        : all.where((o) => _activeStatuses.contains(o.status)).toList();
    final completedList = loading
        ? <Order>[]
        : all.where((o) => o.status == OrderStatus.completed).toList();

    return Column(
      children: [
        // ── Gradient header ──
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A3D20), Color(0xFF1A6B3C)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top + 20,
            20,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  // Stats bubble
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.receipt_long_rounded,
                          size: 13,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${all.length}',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Title
                  Text(
                    l10n.driverOrdersHistory,
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Tab bar inside gradient
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    child: Text(
                      '${l10n.driverOrdersTabAll} (${all.length})',
                      style: GoogleFonts.cairo(fontSize: 12),
                    ),
                  ),
                  Tab(
                    child: Text(
                      '${l10n.driverOrdersTabActive} (${activeList.length})',
                      style: GoogleFonts.cairo(fontSize: 12),
                    ),
                  ),
                  Tab(
                    child: Text(
                      '${l10n.driverOrdersTabCompleted} (${completedList.length})',
                      style: GoogleFonts.cairo(fontSize: 12),
                    ),
                  ),
                ],
                labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700),
                unselectedLabelStyle: GoogleFonts.cairo(
                  fontWeight: FontWeight.w500,
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                indicatorColor: Colors.white,
                indicatorWeight: 2.5,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.white.withValues(alpha: 0.2),
              ),
            ],
          ),
        ),

        // ── Tab views ──
        Expanded(
          child: DwaarSkeleton(
            enabled: loading,
            child: TabBarView(
              controller: _tabController,
              children: [
                _OrderListView(
                  orders: all,
                  collectionSaleOrders: loading
                      ? const []
                      : widget.collectionSaleOrders,
                  tab: this,
                ),
                _OrderListView(
                  orders: activeList,
                  collectionSaleOrders: loading
                      ? const []
                      : widget.collectionSaleOrders
                            .where((o) => _activeStatuses.contains(o.status))
                            .toList(),
                  tab: this,
                ),
                _OrderListView(
                  orders: completedList,
                  collectionSaleOrders: const [],
                  tab: this,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OrderListView extends StatelessWidget {
  const _OrderListView({
    required this.orders,
    required this.collectionSaleOrders,
    required this.tab,
  });

  final List<Order> orders;
  final List<Order> collectionSaleOrders;
  final _DriverOrdersTabState tab;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEmpty = orders.isEmpty && collectionSaleOrders.isEmpty;

    if (isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 40,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.driverNoOrders,
              style: GoogleFonts.cairo(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.driverNoOrdersYet,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppColors.mutedText,
              ),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        if (collectionSaleOrders.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: l10n.driverCollectionCommitments,
              count: collectionSaleOrders.length,
              color: AppColors.jobBlue,
              icon: Icons.local_shipping_rounded,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CollectionSaleCard(
                    sale: collectionSaleOrders[i],
                    onCancel:
                        collectionSaleOrders[i].status == OrderStatus.pending &&
                            tab.widget.onCancelSale != null
                        ? () => tab.widget.onCancelSale!(
                            collectionSaleOrders[i].id,
                          )
                        : null,
                    onStartTransit:
                        collectionSaleOrders[i].status == OrderStatus.pending &&
                            tab.widget.onStartTransit != null
                        ? () => _handleStartTransit(
                            ctx,
                            collectionSaleOrders[i],
                            tab.widget.onStartTransit!,
                          )
                        : null,
                    onComplete:
                        collectionSaleOrders[i].status ==
                                OrderStatus.inTransit &&
                            tab.widget.onComplete != null
                        ? () => _showCompleteDialog(
                            ctx,
                            collectionSaleOrders[i],
                            tab.widget.onComplete!,
                          )
                        : null,
                  ),
                ),
                childCount: collectionSaleOrders.length,
              ),
            ),
          ),
        ],
        if (orders.isNotEmpty) ...[
          if (collectionSaleOrders.isNotEmpty)
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: l10n.driverOrdersHistory,
                count: orders.length,
                color: AppColors.primaryGreen,
                icon: Icons.receipt_long_rounded,
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DriverOrderCard(
                    order: orders[i],
                    onCompleteOrder: tab.widget.onCompleteOrder,
                    onMarkArrivedAtPickup: tab.widget.onMarkArrivedAtPickup,
                    onMarkArrivedAtDropoff: tab.widget.onMarkArrivedAtDropoff,
                  ),
                ),
                childCount: orders.length,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 4),
                Text(
                  '$count',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain,
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverOrderCard extends StatelessWidget {
  final Order order;
  final ValueChanged<Order>? onCompleteOrder;
  final Future<String?> Function(Order)? onMarkArrivedAtPickup;
  final Future<String?> Function(Order)? onMarkArrivedAtDropoff;

  const _DriverOrderCard({
    required this.order,
    this.onCompleteOrder,
    this.onMarkArrivedAtPickup,
    this.onMarkArrivedAtDropoff,
  });

  bool get _isActive => _activeStatuses.contains(order.status);

  void _openDetails(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderDetailsView(
          order: order,
          hideStatus: true,
          isDriverView: true,
          onCompleteOrder: onCompleteOrder,
          onMarkArrivedAtPickup: onMarkArrivedAtPickup,
          onMarkArrivedAtDropoff: onMarkArrivedAtDropoff,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OrderCard(
      order: order,
      mode: _isActive
          ? OrderCardMode.driverActive
          : OrderCardMode.driverHistory,
      onAction: _isActive ? () => _openDetails(context) : null,
    );
  }
}
