import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../l10n/l10n.dart';

/// Bottom sheet shown when a supplier (individual or restaurant) taps
/// "قبول" on a collection job. The supplier makes two choices:
///   1. Delivery method  — self-deliver OR assign a rider
///   2. Transaction type — donate (company pays fees) OR sell (supplier pays fees)
///
/// The [onConfirm] callback is called with the two chosen values when the
/// supplier taps the confirm button.
class AcceptCollectionJobSheet extends StatefulWidget {
  final Order job;
  final void Function(
    CollectionDeliveryMethod deliveryMethod,
    CollectionTransactionType transactionType,
  )
  onConfirm;

  const AcceptCollectionJobSheet({
    super.key,
    required this.job,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required Order job,
    required void Function(CollectionDeliveryMethod, CollectionTransactionType)
    onConfirm,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AcceptCollectionJobSheet(job: job, onConfirm: onConfirm),
    );
  }

  @override
  State<AcceptCollectionJobSheet> createState() =>
      _AcceptCollectionJobSheetState();
}

class _AcceptCollectionJobSheetState extends State<AcceptCollectionJobSheet> {
  CollectionDeliveryMethod? _delivery;
  CollectionTransactionType? _transaction;

  bool get _canConfirm => _delivery != null && _transaction != null;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bottomPad = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomPad),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          const SizedBox(height: 12),
          _buildHeader(context),
          const SizedBox(height: 20),
          _buildSectionTitle(l10n.collectionSaleDeliveryMethodLabel),
          const SizedBox(height: 10),
          _buildDeliveryOptions(),
          const SizedBox(height: 20),
          _buildSectionTitle(l10n.collectionSaleTransactionTypeLabel),
          const SizedBox(height: 10),
          _buildTransactionOptions(),
          if (_canConfirm) ...[
            const SizedBox(height: 16),
            _buildSummary(context),
          ],
          const SizedBox(height: 20),
          _buildConfirmButton(context),
        ],
      ),
    );
  }

  Widget _buildHandle() => Center(
    child: Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0xFFD1D5DB),
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );

  Widget _buildHeader(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          l10n.acceptJobTitle,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF002819),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.acceptJobSubtitle,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: const Color(0xFF717973),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) => Align(
    alignment: Alignment.centerRight,
    child: Text(
      title,
      style: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF404943),
      ),
    ),
  );

  Widget _buildDeliveryOptions() => Row(
    children: [
      Expanded(
        child: _ChoiceCard(
          icon: Icons.directions_car_rounded,
          title: CollectionDeliveryMethod.selfDelivery.label,
          subtitle: CollectionDeliveryMethod.selfDelivery.description,
          selected: _delivery == CollectionDeliveryMethod.selfDelivery,
          onTap: () =>
              setState(() => _delivery = CollectionDeliveryMethod.selfDelivery),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _ChoiceCard(
          icon: Icons.local_shipping_rounded,
          title: CollectionDeliveryMethod.assignRider.label,
          subtitle: CollectionDeliveryMethod.assignRider.description,
          selected: _delivery == CollectionDeliveryMethod.assignRider,
          onTap: () =>
              setState(() => _delivery = CollectionDeliveryMethod.assignRider),
        ),
      ),
    ],
  );

  Widget _buildTransactionOptions() => Row(
    children: [
      Expanded(
        child: _ChoiceCard(
          icon: Icons.volunteer_activism_rounded,
          title: CollectionTransactionType.donate.label,
          subtitle: CollectionTransactionType.donate.description,
          selected: _transaction == CollectionTransactionType.donate,
          accentColor: const Color(0xFF1E5C35),
          onTap: () =>
              setState(() => _transaction = CollectionTransactionType.donate),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _ChoiceCard(
          icon: Icons.sell_rounded,
          title: CollectionTransactionType.sell.label,
          subtitle: CollectionTransactionType.sell.description,
          selected: _transaction == CollectionTransactionType.sell,
          accentColor: const Color(0xFFC8860A),
          onTap: () =>
              setState(() => _transaction = CollectionTransactionType.sell),
        ),
      ),
    ],
  );

  Widget _buildSummary(BuildContext context) {
    final l10n = context.l10n;
    final deliveryFeeNote = _transaction == CollectionTransactionType.donate
        ? l10n.acceptJobDeliveryFeeCompany
        : l10n.acceptJobDeliveryFeeYou;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF14401F).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF14401F).withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: Color(0xFF14401F),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              deliveryFeeNote,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: const Color(0xFF14401F),
              ),
            ),
          ),
          Text(
            '${_delivery!.label} · ${_transaction!.label}',
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 54,
    child: ElevatedButton(
      onPressed: _canConfirm
          ? () {
              Navigator.pop(context);
              widget.onConfirm(_delivery!, _transaction!);
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF06402B),
        disabledBackgroundColor: const Color(0xFF06402B).withValues(alpha: 0.3),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(
        context.l10n.acceptJobConfirmButton,
        style: GoogleFonts.cairo(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );
}

class _ChoiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Color accentColor;

  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.accentColor = const Color(0xFF14401F),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? accentColor.withValues(alpha: 0.08)
              : const Color(0xFFF4F6F5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? accentColor : const Color(0xFFDDE0DC),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (selected)
                  Icon(Icons.check_circle_rounded, size: 18, color: accentColor)
                else
                  Icon(
                    Icons.circle_outlined,
                    size: 18,
                    color: const Color(0xFFBBBFBD),
                  ),
                Icon(icon, size: 24, color: accentColor),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: selected ? accentColor : const Color(0xFF002819),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                fontSize: 10,
                color: const Color(0xFF717973),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
