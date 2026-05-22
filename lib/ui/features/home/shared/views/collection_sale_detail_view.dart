import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/order.dart';
import 'package:dwaar/ui/common/map/route_map_placeholder.dart';

/// Full-screen detail view for a [OrderType.collectionSale] commitment.
/// Shows drop-off location, delivery method, transaction type, and status.
class CollectionSaleDetailView extends StatelessWidget {
  final Order sale;

  const CollectionSaleDetailView({super.key, required this.sale});

  bool get _isNew =>
      DateTime.now().difference(sale.createdAt).inMinutes < 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF06402B),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'تفاصيل الالتزام',
          style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusRow(),
          const SizedBox(height: 16),
          if (sale.pickupLat != null && sale.dropoffLat != null) ...[
            _buildMapSection(),
            const SizedBox(height: 12),
          ],
          _buildDropoffCard(),
          const SizedBox(height: 12),
          if (sale.collectionDeliveryMethod != null ||
              sale.collectionTransactionType != null) ...[
            _buildChoicesCard(),
            const SizedBox(height: 12),
          ],
          _buildWasteCard(),
          if (sale.pricePerKg != null || sale.itemPrice != null) ...[
            const SizedBox(height: 12),
            _buildPricingCard(),
          ],
          const SizedBox(height: 12),
          _buildMetaCard(),
        ],
      ),
    );
  }

  Widget _buildMapSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: RouteMapPlaceholder(
        pickupLat: sale.pickupLat!,
        pickupLng: sale.pickupLng!,
        dropoffLat: sale.dropoffLat!,
        dropoffLng: sale.dropoffLng!,
        height: 180,
      ),
    );
  }

  Widget _buildStatusRow() {
    final isNew = _isNew;
    return Row(
      children: [
        if (isNew) ...[
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF14401F),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('جديد',
                style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
          const SizedBox(width: 8),
        ],
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _statusBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(sale.status.label,
              style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _statusColor)),
        ),
        const Spacer(),
        Text(
          sale.id,
          style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF717973)),
        ),
      ],
    );
  }

  Widget _buildDropoffCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  color: Color(0xFF14401F), size: 20),
              const Spacer(),
              Text(
                'موقع التسليم',
                style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002819)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF14401F).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              sale.dropoffAddress,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002819)),
            ),
          ),
          if (sale.supplierNotes != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'الشركة: ${sale.supplierNotes}',
                style: GoogleFonts.cairo(
                    fontSize: 12, color: const Color(0xFF717973)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChoicesCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('تفاصيل الاتفاق',
              style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002819))),
          const SizedBox(height: 12),
          if (sale.collectionDeliveryMethod != null) ...[
            _infoRow(
              icon: sale.collectionDeliveryMethod ==
                      CollectionDeliveryMethod.selfDelivery
                  ? Icons.directions_car_rounded
                  : Icons.local_shipping_rounded,
              label: 'طريقة التوصيل',
              value: sale.collectionDeliveryMethod!.label,
              subtitle: sale.collectionDeliveryMethod!.description,
            ),
            const SizedBox(height: 10),
          ],
          if (sale.collectionTransactionType != null)
            _infoRow(
              icon: sale.collectionTransactionType ==
                      CollectionTransactionType.donate
                  ? Icons.volunteer_activism_rounded
                  : Icons.sell_rounded,
              label: 'نوع المعاملة',
              value: sale.collectionTransactionType!.label,
              subtitle: sale.collectionTransactionType!.description,
              valueColor: sale.collectionTransactionType ==
                      CollectionTransactionType.donate
                  ? const Color(0xFF166534)
                  : const Color(0xFFC8860A),
            ),
        ],
      ),
    );
  }

  Widget _buildWasteCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('أنواع النفايات',
              style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002819))),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            alignment: WrapAlignment.end,
            children: sale.wasteTypes
                .map((t) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4EBAB).withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(t.label,
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF14401F))),
                    ))
                .toList(),
          ),
          if (sale.jobDescription != null &&
              sale.jobDescription!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              sale.jobDescription!,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                  fontSize: 12, color: const Color(0xFF717973)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPricingCard() {
    final isPerKg = sale.paymentModel == PaymentModel.perKg;
    final price = sale.pricePerKg ?? sale.itemPrice ?? 0;
    return _card(
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF14401F).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${price.toStringAsFixed(2)} ${isPerKg ? 'د.أ / كغ' : 'د.أ'}',
              style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF14401F)),
            ),
          ),
          const Spacer(),
          Text('السعر المتفق عليه',
              style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002819))),
        ],
      ),
    );
  }

  Widget _buildMetaCard() {
    final diff = DateTime.now().difference(sale.createdAt);
    final ageStr = diff.inDays > 0
        ? 'منذ ${diff.inDays} يوم'
        : diff.inHours > 0
            ? 'منذ ${diff.inHours} ساعة'
            : 'منذ ${diff.inMinutes} دقيقة';
    return _card(
      child: Column(
        children: [
          _metaRow('رقم الالتزام', sale.id),
          if (sale.linkedJobId != null) ...[
            const SizedBox(height: 6),
            _metaRow('رقم الوظيفة', sale.linkedJobId!),
          ],
          const SizedBox(height: 6),
          _metaRow('تاريخ القبول', ageStr),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: valueColor ?? const Color(0xFF14401F)),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(label,
                style: GoogleFonts.cairo(
                    fontSize: 11, color: const Color(0xFF717973))),
            Text(value,
                style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? const Color(0xFF002819))),
            if (subtitle != null)
              Text(subtitle,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                      fontSize: 10, color: const Color(0xFF9CA3AF))),
          ],
        ),
      ],
    );
  }

  Widget _metaRow(String label, String value) {
    return Row(
      children: [
        Text(value,
            style: GoogleFonts.dmSans(
                fontSize: 12, color: const Color(0xFF717973))),
        const Spacer(),
        Text(label,
            style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF404943))),
      ],
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }

  Color get _statusColor => switch (sale.status) {
        OrderStatus.pending => const Color(0xFFC8860A),
        OrderStatus.accepted || OrderStatus.arrivedAtPickup => const Color(0xFF1E5C35),
        OrderStatus.inTransit || OrderStatus.arrivedAtDropoff => const Color(0xFF1E40AF),
        OrderStatus.completed => const Color(0xFF166534),
        OrderStatus.cancelled => const Color(0xFF991B1B),
      };

  Color get _statusBg => switch (sale.status) {
        OrderStatus.pending => const Color(0xFFFEF3C7),
        OrderStatus.accepted || OrderStatus.arrivedAtPickup => const Color(0xFFD1FAE5),
        OrderStatus.inTransit || OrderStatus.arrivedAtDropoff => const Color(0xFFDBEAFE),
        OrderStatus.completed => const Color(0xFFDCFCE7),
        OrderStatus.cancelled => const Color(0xFFFEE2E2),
      };
}
