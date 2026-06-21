import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../../l10n/l10n.dart';
import '../../shared/widgets/collection_sale_card.dart';
import '../widgets/supplier_order_card.dart';

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
      title: Text(context.l10n.orderDeliveryConfirmTitle,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(context.l10n.orderDeliveryConfirmMsg,
              textAlign: TextAlign.right, style: GoogleFonts.cairo()),
          if (sale.paymentModel == PaymentModel.perKg) ...[
            const SizedBox(height: 16),
            TextField(
              controller: weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: context.l10n.orderActualWeight,
                labelStyle: GoogleFonts.cairo(),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
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
            final weight =
                weightText.isEmpty ? null : double.tryParse(weightText);
            final error = onComplete(sale.id, actualWeightKg: weight);
            if (error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error,
                      style: GoogleFonts.cairo(color: Colors.white)),
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
                borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(context.l10n.confirm,
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

class SupplierOrdersTab extends StatelessWidget {
  final List<Order> activeOrders;
  final List<Order> completedOrders;
  final List<Order> cancelledOrders;
  final List<Order> collectionSaleOrders;
  final String? Function(String orderId) onCancelOrder;
  final String? Function(String saleId)? onStartTransit;
  final String? Function(String saleId, {double? actualWeightKg})? onComplete;

  const SupplierOrdersTab({
    super.key,
    required this.activeOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    this.collectionSaleOrders = const [],
    required this.onCancelOrder,
    this.onStartTransit,
    this.onComplete,
  });

  bool get _hasOrders =>
      activeOrders.isNotEmpty ||
      completedOrders.isNotEmpty ||
      cancelledOrders.isNotEmpty ||
      collectionSaleOrders.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return CustomScrollView(
      slivers: [
        // ── Gradient header ──
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0A3D20), Color(0xFF1A6B3C)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 20, 20, 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.receipt_long_rounded,
                          size: 13, color: Colors.white70),
                      const SizedBox(width: 5),
                      Text(
                        '${activeOrders.length + completedOrders.length + cancelledOrders.length + collectionSaleOrders.length}',
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
                Text(
                  l10n.ordersTabTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        if (!_hasOrders)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
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
                    child: const Icon(Icons.receipt_long_rounded,
                        size: 40, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.ordersNoOrdersYet,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.ordersCreateFromHome,
                    style: GoogleFonts.cairo(
                        fontSize: 14, color: AppColors.mutedText),
                  ),
                ],
              ),
            ),
          )
        else ...[
          if (collectionSaleOrders.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: l10n.ordersCollectionSection,
                count: collectionSaleOrders.length,
                color: AppColors.jobBlue,
                icon: Icons.local_shipping_rounded,
              ),
            ),
            _buildCollectionSalesList(context, collectionSaleOrders),
          ],
          if (activeOrders.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: l10n.ordersActiveSection,
                count: activeOrders.length,
                color: AppColors.statusActiveText,
                icon: Icons.pending_actions_rounded,
              ),
            ),
            _buildOrdersList(context, activeOrders, canCancel: true),
          ],
          if (completedOrders.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: l10n.ordersCompletedSection,
                count: completedOrders.length,
                color: AppColors.statusCompletedText,
                icon: Icons.check_circle_rounded,
              ),
            ),
            _buildOrdersList(context, completedOrders),
          ],
          if (cancelledOrders.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: _SectionHeader(
                title: l10n.ordersCancelledSection,
                count: cancelledOrders.length,
                color: AppColors.statusCancelledText,
                icon: Icons.cancel_rounded,
              ),
            ),
            _buildOrdersList(context, cancelledOrders),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ],
    );
  }

  SliverPadding _buildCollectionSalesList(
      BuildContext context, List<Order> sales) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CollectionSaleCard(
              sale: sales[i],
              onCancel: sales[i].status == OrderStatus.pending
                  ? () => onCancelOrder(sales[i].id)
                  : null,
              onStartTransit: sales[i].status == OrderStatus.pending &&
                      onStartTransit != null
                  ? () => _handleStartTransit(ctx, sales[i], onStartTransit!)
                  : null,
              onComplete: sales[i].status == OrderStatus.inTransit &&
                      onComplete != null
                  ? () => _showCompleteDialog(ctx, sales[i], onComplete!)
                  : null,
            ),
          ),
          childCount: sales.length,
        ),
      ),
    );
  }

  SliverPadding _buildOrdersList(BuildContext context, List<Order> orders,
      {bool canCancel = false}) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SupplierOrderCard(
              order: orders[i],
              canCancel:
                  canCancel && orders[i].status == OrderStatus.pending,
              onCancelOrder: onCancelOrder,
            ),
          ),
          childCount: orders.length,
        ),
      ),
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
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
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
