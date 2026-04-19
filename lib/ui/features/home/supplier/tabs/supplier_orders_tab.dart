import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/order.dart';
import '../../shared/widgets/collection_sale_card.dart';
import '../widgets/supplier_order_card.dart';


class SupplierOrdersTab extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final hasOrders = activeOrders.isNotEmpty || completedOrders.isNotEmpty || cancelledOrders.isNotEmpty || collectionSaleOrders.isNotEmpty;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 16),
            child: Text(
              'طلباتي',
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
                  Text('لا توجد طلبات بعد', style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF002819))),
                  const SizedBox(height: 8),
                  Text('أنشئ طلب استلام جديد من الصفحة الرئيسية', style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF717973))),
                ],
              ),
            ),
          )
        else ...[
          if (collectionSaleOrders.isNotEmpty) ...[
            _buildSectionHeader('التزامات التجميع', collectionSaleOrders.length, const Color(0xFF14401F)),
            _buildCollectionSalesList(context, collectionSaleOrders),
          ],
          if (activeOrders.isNotEmpty) ...[
            _buildSectionHeader('الطلبات النشطة', activeOrders.length, const Color(0xFF1E5C35)),
            _buildOrdersList(context, activeOrders, canCancel: true),
          ],
          if (completedOrders.isNotEmpty) ...[
            _buildSectionHeader('الطلبات المكتملة', completedOrders.length, const Color(0xFF166534)),
            _buildOrdersList(context, completedOrders),
          ],
          if (cancelledOrders.isNotEmpty) ...[
            _buildSectionHeader('الطلبات الملغاة', cancelledOrders.length, const Color(0xFF991B1B)),
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
              onCancel: (sales[i].status == OrderStatus.accepted ||
                         sales[i].status == OrderStatus.inTransit)
                  ? () => onCancelSale?.call(sales[i].id)
                  : null,
              onStartTransit: sales[i].status == OrderStatus.accepted && onStartTransit != null
                  ? () { onStartTransit!(sales[i].id); }
                  : null,
              onComplete: sales[i].status == OrderStatus.inTransit && onComplete != null
                  ? () { onComplete!(sales[i].id); }
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
