import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_tokens.dart';
import '../../../../../data/models/order/order.dart';
import 'package:dwaar/ui/common/map/route_map_placeholder.dart';
import '../../../../../l10n/l10n.dart';

/// Full-screen detail view for a [OrderType.collectionSale] commitment.
/// Shows drop-off location, delivery method, transaction type, and status.
class CollectionSaleDetailView extends StatelessWidget {
  final Order sale;

  const CollectionSaleDetailView({super.key, required this.sale});

  bool get _isNew =>
      DateTime.now().difference(sale.createdAt).inMinutes < 30;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: context.dt.scaffold,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          l10n.collectionSaleDetailTitle,
          style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildStatusRow(context),
          const SizedBox(height: 16),
          if (sale.pickupLat != null && sale.dropoffLat != null) ...[
            _buildMapSection(),
            const SizedBox(height: 12),
          ],
          _buildDropoffCard(context),
          const SizedBox(height: 12),
          if (sale.collectionDeliveryMethod != null ||
              sale.collectionTransactionType != null) ...[
            _buildChoicesCard(context),
            const SizedBox(height: 12),
          ],
          _buildWasteCard(context),
          if (sale.pricePerKg != null || sale.itemPrice != null) ...[
            const SizedBox(height: 12),
            _buildPricingCard(context),
          ],
          const SizedBox(height: 12),
          _buildMetaCard(context),
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

  Widget _buildStatusRow(BuildContext context) {
    final l10n = context.l10n;
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
            child: Text(l10n.collectionSaleNew,
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
              color: context.dt.onSurfaceMuted),
        ),
      ],
    );
  }

  Widget _buildDropoffCard(BuildContext context) {
    final l10n = context.l10n;
    return _card(context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_rounded,
                  color: Color(0xFF14401F), size: 20),
              const Spacer(),
              Text(
                l10n.collectionSaleDeliveryLocationNoColon,
                style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: context.dt.onSurface),
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
                  color: context.dt.onSurface),
            ),
          ),
          if (sale.supplierNotes != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                l10n.collectionSaleCompanyNote(sale.supplierNotes!),
                style: GoogleFonts.cairo(
                    fontSize: 12, color: context.dt.onSurfaceMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChoicesCard(BuildContext context) {
    final l10n = context.l10n;
    return _card(context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(l10n.collectionSaleAgreementTitle,
              style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: context.dt.onSurface)),
          const SizedBox(height: 12),
          if (sale.collectionDeliveryMethod != null) ...[
            _infoRow(
              context,
              icon: sale.collectionDeliveryMethod ==
                      CollectionDeliveryMethod.selfDelivery
                  ? Icons.directions_car_rounded
                  : Icons.local_shipping_rounded,
              label: l10n.collectionSaleDeliveryMethodLabel,
              value: sale.collectionDeliveryMethod!.label,
              subtitle: sale.collectionDeliveryMethod!.description,
            ),
            const SizedBox(height: 10),
          ],
          if (sale.collectionTransactionType != null)
            _infoRow(
              context,
              icon: sale.collectionTransactionType ==
                      CollectionTransactionType.donate
                  ? Icons.volunteer_activism_rounded
                  : Icons.sell_rounded,
              label: l10n.collectionSaleTransactionTypeLabel,
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

  Widget _buildWasteCard(BuildContext context) {
    final l10n = context.l10n;
    return _card(context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(l10n.collectionSaleWasteTypesLabel,
              style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: context.dt.onSurface)),
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
                  fontSize: 12, color: context.dt.onSurfaceMuted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPricingCard(BuildContext context) {
    final l10n = context.l10n;
    final isPerKg = sale.paymentModel == PaymentModel.perKg;
    final price = sale.pricePerKg ?? sale.itemPrice ?? 0;
    final priceUnit = isPerKg
        ? '${l10n.currencyJodShort} / ${l10n.unitKg}'
        : l10n.currencyJodShort;
    return _card(context,
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
              '${price.toStringAsFixed(2)} $priceUnit',
              style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF14401F)),
            ),
          ),
          const Spacer(),
          Text(l10n.collectionSaleAgreedPriceNoColon,
              style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: context.dt.onSurface)),
        ],
      ),
    );
  }

  Widget _buildMetaCard(BuildContext context) {
    final l10n = context.l10n;
    final diff = DateTime.now().difference(sale.createdAt);
    final ageStr = diff.inDays > 0
        ? l10n.timeAgoDays(diff.inDays)
        : diff.inHours > 0
            ? l10n.timeAgoHours(diff.inHours)
            : l10n.timeAgoMinutes(diff.inMinutes);
    return _card(context,
      child: Column(
        children: [
          _metaRow(context, l10n.collectionSaleCommitmentNumber, sale.id),
          if (sale.linkedJobId != null) ...[
            const SizedBox(height: 6),
            _metaRow(context, l10n.collectionSaleJobNumberLabel, sale.linkedJobId!),
          ],
          const SizedBox(height: 6),
          _metaRow(context, l10n.collectionSaleAcceptedAt, ageStr),
        ],
      ),
    );
  }

  Widget _infoRow(
    BuildContext context, {
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
                    fontSize: 11, color: context.dt.onSurfaceMuted)),
            Text(value,
                style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? context.dt.onSurface)),
            if (subtitle != null)
              Text(subtitle,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                      fontSize: 10, color: context.dt.onSurfaceMuted)),
          ],
        ),
      ],
    );
  }

  Widget _metaRow(BuildContext context, String label, String value) {
    return Row(
      children: [
        Text(value,
            style: GoogleFonts.dmSans(
                fontSize: 12, color: context.dt.onSurfaceMuted)),
        const Spacer(),
        Text(label,
            style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: context.dt.onSurfaceVariant)),
      ],
    );
  }

  Widget _card(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.dt.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: context.dt.shadow.withValues(alpha: 0.04),
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
