import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/order.dart';
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
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo()),
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
            final error =
                onComplete(sale.id, actualWeightKg: weight);
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
            backgroundColor: const Color(0xFF1E40AF),
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

  @override
  Widget build(BuildContext context) {
    final hasOrders = activeOrders.isNotEmpty || completedOrders.isNotEmpty || cancelledOrders.isNotEmpty || collectionSaleOrders.isNotEmpty;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 16),
            child: Text(
              context.l10n.ordersTabTitle,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF002819)),
            ),
          ),
        ),
        if (!hasOrders)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E5C35).withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long_rounded, size: 64, color: Color(0xFF1E5C35)),
                  ),
                  const SizedBox(height: 24),
                  Text(context.l10n.ordersNoOrdersYet, style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF002819))),
                  const SizedBox(height: 8),
                  Text(context.l10n.ordersCreateFromHome, style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF717973))),
                ],
              ),
            ),
          )
        else ...[
          if (collectionSaleOrders.isNotEmpty) ...[
            _buildSectionHeader(context.l10n.ordersCollectionSection, collectionSaleOrders.length, const Color(0xFF14401F)),
            _buildCollectionSalesList(context, collectionSaleOrders),
          ],
          if (activeOrders.isNotEmpty) ...[
            _buildSectionHeader(context.l10n.ordersActiveSection, activeOrders.length, const Color(0xFF1E5C35)),
            _buildOrdersList(context, activeOrders, canCancel: true),
          ],
          if (completedOrders.isNotEmpty) ...[
            _buildSectionHeader(context.l10n.ordersCompletedSection, completedOrders.length, const Color(0xFF166534)),
            _buildOrdersList(context, completedOrders),
          ],
          if (cancelledOrders.isNotEmpty) ...[
            _buildSectionHeader(context.l10n.ordersCancelledSection, cancelledOrders.length, const Color(0xFF991B1B)),
            _buildOrdersList(context, cancelledOrders),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ],
    );
  }

  static SliverToBoxAdapter _buildSectionHeader(String title, int count, Color color) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.bold, color: color),
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF002819)),
            ),
          ],
        ),
      ),
    );
  }

  SliverPadding _buildCollectionSalesList(
      BuildContext context, List<Order> sales) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CollectionSaleCard(
              sale: sales[i],
              onCancel: sales[i].status == OrderStatus.pending
                  ? () => onCancelOrder(sales[i].id)
                  : null,
              onStartTransit: sales[i].status == OrderStatus.pending && onStartTransit != null
                  ? () => _handleStartTransit(ctx, sales[i], onStartTransit!)
                  : null,
              onComplete: sales[i].status == OrderStatus.inTransit && onComplete != null
                  ? () => _showCompleteDialog(ctx, sales[i], onComplete!)
                  : null,
            ),
          ),
          childCount: sales.length,
        ),
      ),
    );
  }

  SliverPadding _buildOrdersList(BuildContext context, List<Order> orders, {bool canCancel = false}) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SupplierOrderCard(
              order: orders[i],
              canCancel: canCancel && orders[i].status == OrderStatus.pending,
              onCancelOrder: onCancelOrder,
            ),
          ),
          childCount: orders.length,
        ),
      ),
    );
  }
}
