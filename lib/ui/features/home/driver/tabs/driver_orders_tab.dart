import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/order.dart';
import '../../shared/order_card.dart';
import '../../shared/order_details_view.dart';
import '../../shared/widgets/collection_sale_card.dart';

void _showWeightDialog(
  BuildContext context,
  String saleId,
  String? Function(String saleId, {double? actualWeightKg}) onComplete,
) {
  showDialog<void>(
    context: context,
    builder: (_) => _WeightEntryDialog(
      onConfirm: (double? kg) {
        Navigator.pop(context);
        onComplete(saleId, actualWeightKg: kg);
      },
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
                onCancel: (collectionSaleOrders[i].status == OrderStatus.accepted ||
                            collectionSaleOrders[i].status == OrderStatus.inTransit)
                    ? () => onCancelSale?.call(collectionSaleOrders[i].id)
                    : null,
                onStartTransit: collectionSaleOrders[i].status == OrderStatus.accepted && onStartTransit != null
                    ? () { onStartTransit!(collectionSaleOrders[i].id); }
                    : null,
                onComplete: collectionSaleOrders[i].status == OrderStatus.inTransit && onComplete != null
                    ? () => _showWeightDialog(ctx, collectionSaleOrders[i].id, onComplete!)
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
