import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/models/order_labels.dart';
import '../../../../../l10n/l10n.dart';
import '../views/collection_sale_detail_view.dart';

/// Card shown in a driver's or supplier's orders list for a collection-sale
/// commitment — where they agreed to sell/deliver waste to a recycling company.
class CollectionSaleCard extends StatelessWidget {
  final Order sale;
  final VoidCallback? onCancel;
  final VoidCallback? onStartTransit;
  final VoidCallback? onComplete;

  const CollectionSaleCard({
    super.key,
    required this.sale,
    this.onCancel,
    this.onStartTransit,
    this.onComplete,
  });

  double? get _price => sale.pricePerKg ?? sale.itemPrice;

  bool get _isNew =>
      DateTime.now().difference(sale.createdAt).inMinutes < 30;

  Color get _statusColor => switch (sale.status) {
        OrderStatus.pending => const Color(0xFFC8860A),
        OrderStatus.accepted => const Color(0xFF1E5C35),
        OrderStatus.inTransit => const Color(0xFF1E40AF),
        OrderStatus.completed => const Color(0xFF166534),
        OrderStatus.cancelled => const Color(0xFF991B1B),
      };

  Color get _statusBg => switch (sale.status) {
        OrderStatus.pending => const Color(0xFFFEF3C7),
        OrderStatus.accepted => const Color(0xFFD1FAE5),
        OrderStatus.inTransit => const Color(0xFFDBEAFE),
        OrderStatus.completed => const Color(0xFFDCFCE7),
        OrderStatus.cancelled => const Color(0xFFFEE2E2),
      };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CollectionSaleDetailView(sale: sale),
        ),
      ),
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: const Color(0xFF14401F).withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildTopRow(context),
          const SizedBox(height: 12),
          _buildDropoffRow(context),
          const SizedBox(height: 10),
          _buildWasteChips(),
          if (sale.collectionDeliveryMethod != null ||
              sale.collectionTransactionType != null) ...[  
            const SizedBox(height: 10),
            _buildChoiceChips(),
          ],
          if (_price != null) ...[
            const SizedBox(height: 10),
            _buildPriceRow(context),
          ],
          if (sale.jobDescription != null &&
              sale.jobDescription!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              sale.jobDescription!,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                  fontSize: 12, color: const Color(0xFF717973)),
            ),
          ],
          if (sale.linkedJobId != null) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                context.l10n.collectionSaleJobNumber(sale.linkedJobId ?? ''),
                style: GoogleFonts.dmSans(
                    fontSize: 10, color: const Color(0xFFBBBFBD)),
              ),
            ),
          ],
          if (sale.status == OrderStatus.pending) ...[
            const SizedBox(height: 12),
            _buildPendingActions(context),
          ],
          if (sale.status == OrderStatus.inTransit && onComplete != null) ...[
            const SizedBox(height: 12),
            _buildInTransitAction(context),
          ],
        ],
      ),
    ),  
    );
  }

  Widget _buildTopRow(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isNew) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF14401F),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(l10n.collectionSaleNew,
                    style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
              const SizedBox(width: 6),
            ],
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: _statusBg, borderRadius: BorderRadius.circular(20)),
              child: Text(sale.status.label,
                  style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _statusColor)),
            ),
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(sale.id,
                style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002819))),
            Text(_formatAge(context, sale.createdAt),
                style: GoogleFonts.cairo(
                    fontSize: 10, color: const Color(0xFF9CA3AF))),
          ],
        ),
        const SizedBox(width: 10),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF14401F).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.local_shipping_rounded,
              size: 20, color: Color(0xFF14401F)),
        ),
      ],
    );
  }

  Widget _buildDropoffRow(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.location_on_rounded,
            size: 14, color: Color(0xFF14401F)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(sale.dropoffAddress,
              style: GoogleFonts.cairo(
                  fontSize: 12, color: const Color(0xFF717973))),
        ),
        const SizedBox(width: 6),
        Text(context.l10n.collectionSaleDeliveryLocation,
            style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF404943))),
      ],
    );
  }

  Widget _buildWasteChips() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      alignment: WrapAlignment.end,
      children: sale.wasteTypes
          .map((t) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4EBAB).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(t.label,
                    style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF14401F))),
              ))
          .toList(),
    );
  }

  Widget _buildChoiceChips() {
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      alignment: WrapAlignment.end,
      children: [
        if (sale.collectionDeliveryMethod != null)
          _chip(
            icon: sale.collectionDeliveryMethod ==
                    CollectionDeliveryMethod.selfDelivery
                ? Icons.directions_car_rounded
                : Icons.local_shipping_rounded,
            label: sale.collectionDeliveryMethod!.label,
            bgColor: const Color(0xFFE0F2FE),
            textColor: const Color(0xFF0369A1),
          ),
        if (sale.collectionTransactionType != null)
          _chip(
            icon: sale.collectionTransactionType ==
                    CollectionTransactionType.donate
                ? Icons.volunteer_activism_rounded
                : Icons.sell_rounded,
            label: sale.collectionTransactionType!.label,
            bgColor: sale.collectionTransactionType ==
                    CollectionTransactionType.donate
                ? const Color(0xFFDCFCE7)
                : const Color(0xFFFEF3C7),
            textColor: sale.collectionTransactionType ==
                    CollectionTransactionType.donate
                ? const Color(0xFF166534)
                : const Color(0xFF92400E),
          ),
      ],
    );
  }

  Widget _chip({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label,
              style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: textColor)),
          const SizedBox(width: 4),
          Icon(icon, size: 12, color: textColor),
        ],
      ),
    );
  }

  Widget _buildPriceRow(BuildContext context) {
    final l10n = context.l10n;
    final unitLabel = sale.paymentModel?.unitLabelFor(Localizations.localeOf(context)) ?? l10n.orderCurrencyJD;
    return Row(
      children: [
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF14401F).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text('${_price!} $unitLabel',
              style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF14401F))),
        ),
        const Spacer(),
        Text(l10n.collectionSaleAgreedPrice,
            style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF404943))),
      ],
    );
  }

  Widget _buildPendingActions(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        if (onCancel != null)
          Expanded(
            child: SizedBox(
              height: 40,
              child: OutlinedButton.icon(
                onPressed: () => _showCancelDialog(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFDC2626)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: Text(l10n.collectionSaleCancelCommitment,
                    style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ),
        if (onCancel != null && onStartTransit != null)
          const SizedBox(width: 10),
        if (onStartTransit != null)
          Expanded(
            child: SizedBox(
              height: 40,
              child: ElevatedButton.icon(
                onPressed: onStartTransit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14401F),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.local_shipping_rounded, size: 16),
                label: Text(l10n.collectionSaleStartCollection,
                    style: GoogleFonts.cairo(
                        fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInTransitAction(BuildContext context) {
    final l10n = context.l10n;
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton.icon(
        onPressed: onComplete,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E40AF),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.check_circle_rounded, size: 16),
        label: Text(l10n.collectionSaleConfirmDelivery,
            style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.collectionSaleCancelTitle,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text(
            l10n.collectionSaleCancelConfirm,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.no, style: GoogleFonts.cairo())),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onCancel?.call();
            },
            child: Text(l10n.yesCancelOrder,
                style: GoogleFonts.cairo(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _formatAge(BuildContext context, DateTime dt) {
    final diff = DateTime.now().difference(dt);
    final l10n = context.l10n;
    if (diff.inDays > 0) return l10n.timeAgoDays(diff.inDays);
    if (diff.inHours > 0) return l10n.timeAgoHours(diff.inHours);
    return l10n.timeAgoMinutes(diff.inMinutes);
  }
}
