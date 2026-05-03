import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/order.dart';
import '../../../../../../l10n/l10n.dart';
import '../../shared/order_card.dart';
import '../../shared/order_details_view.dart';
import '../../shared/widgets/collection_sale_card.dart';

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

class DriverOrdersTab extends StatelessWidget {
  final List<Order> history;
  final Order? active;
  final List<Order> collectionSaleOrders;
  final ValueChanged<Order>? onCompleteOrder;
  final ValueChanged<String>? onCancelSale;
  final String? Function(String saleId)? onStartTransit;
  final String? Function(String saleId, {double? actualWeightKg})? onComplete;

  const DriverOrdersTab({
    super.key,
    required this.history,
    required this.active,
    this.collectionSaleOrders = const [],
    this.onCompleteOrder,
    this.onCancelSale,
    this.onStartTransit,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    // ignore: use_null_aware_elements
    final all = [if (active != null) active!, ...history];
    final allEmpty = all.isEmpty && collectionSaleOrders.isEmpty;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).padding.top + 20, 20, 16),
            child: Text(
              context.l10n.driverOrdersHistory,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002819),
              ),
            ),
          ),
        ),
        if (allEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06402B).withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      size: 64,
                      color: Color(0xFF06402B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    context.l10n.driverNoOrders,
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF002819),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.driverNoOrdersYet,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: const Color(0xFF717973),
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          if (collectionSaleOrders.isNotEmpty) ..._buildCollectionSalesSection(context),
          if (all.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: OrderCard(
                      order: all[i],
                      mode: (all[i].status == OrderStatus.inTransit || all[i].status == OrderStatus.accepted)
                          ? OrderCardMode.driverActive
                          : OrderCardMode.driverHistory,
                      onAction: all[i].status == OrderStatus.accepted || all[i].status == OrderStatus.inTransit
                          ? () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => OrderDetailsView(
                                    order: all[i],
                                    onCompleteOrder: onCompleteOrder,
                                    hideStatus: true,
                                  ),
                                ),
                              )
                          : null,
                    ),
                  ),
                  childCount: all.length,
                ),
              ),
            ),
        ],
      ],
    );
  }

  List<Widget> _buildCollectionSalesSection(BuildContext context) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF14401F).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${collectionSaleOrders.length}',
                  style: GoogleFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF14401F)),
                ),
              ),
              const Spacer(),
              Text(
                context.l10n.driverCollectionCommitments,
                style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002819)),
              ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: CollectionSaleCard(
                sale: collectionSaleOrders[i],
                onCancel: collectionSaleOrders[i].status == OrderStatus.pending
                    ? () => onCancelSale?.call(collectionSaleOrders[i].id)
                    : null,
                onStartTransit: collectionSaleOrders[i].status == OrderStatus.pending && onStartTransit != null
                    ? () => _handleStartTransit(ctx, collectionSaleOrders[i], onStartTransit!)
                    : null,
                onComplete: collectionSaleOrders[i].status == OrderStatus.inTransit && onComplete != null
                    ? () => _showCompleteDialog(ctx, collectionSaleOrders[i], onComplete!)
                    : null,
              ),
            ),
            childCount: collectionSaleOrders.length,
          ),
        ),
      ),
    ];
  }
}
