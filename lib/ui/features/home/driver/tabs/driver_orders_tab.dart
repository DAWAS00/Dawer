import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/order.dart';
import '../../shared/order_card.dart';
import '../../shared/order_details_view.dart';
import '../../shared/widgets/collection_sale_card.dart';

class DriverOrdersTab extends StatelessWidget {
  final List<Order> history;
  final Order? active;
  final List<Order> collectionSaleOrders;
  final ValueChanged<Order>? onCompleteOrder;
  final ValueChanged<String>? onCancelSale;

  const DriverOrdersTab({
    super.key,
    required this.history,
    required this.active,
    this.collectionSaleOrders = const [],
    this.onCompleteOrder,
    this.onCancelSale,
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
              'سجل الطلبات',
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
                    'لا توجد طلبات',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF002819),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'لم تقم بقبول أي طلبات بعد',
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
                'التزامات التجميع',
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
              ),
            ),
            childCount: collectionSaleOrders.length,
          ),
        ),
      ),
    ];
  }
}
