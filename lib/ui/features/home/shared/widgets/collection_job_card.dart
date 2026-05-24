import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/models/order_labels.dart';
import '../../../../../l10n/l10n.dart';

class CollectionJobCard extends StatelessWidget {
  final Order job;
  final VoidCallback? onClaim;
  final VoidCallback? onTap;
  final bool showClaimButton;

  const CollectionJobCard({
    super.key,
    required this.job,
    this.onClaim,
    this.onTap,
    this.showClaimButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF14401F).withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildTopRow(context),
          const SizedBox(height: 10),
          _buildWasteChips(context),
          const SizedBox(height: 10),
          _buildPriceRow(context),
          if (job.jobDescription != null &&
              job.jobDescription!.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildDescription(),
          ],
          const SizedBox(height: 12),
          _buildFooter(context),
        ],
      ),
    ),
    );
  }

  Widget _buildTopRow(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _JobBadge(),
            if (job.isEdited) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.edit_rounded,
                        size: 10, color: Color(0xFF92400E)),
                    const SizedBox(width: 3),
                    Text(
                      l10n.collectionJobEdited,
                      style: GoogleFonts.cairo(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF92400E)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              job.supplierName ?? l10n.collectionJobRecyclingCoLabel,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002819),
              ),
            ),
            Text(
              _formatAge(context, job.createdAt),
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: const Color(0xFF717973),
              ),
            ),
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
          child: const Icon(
            Icons.recycling_rounded,
            size: 20,
            color: Color(0xFF14401F),
          ),
        ),
      ],
    );
  }

  Widget _buildWasteChips(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      alignment: WrapAlignment.end,
      children: job.wasteTypes
          .map(
            (t) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFD4EBAB).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                t.labelFor(locale),
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF14401F),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildPriceRow(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    final payModel = job.paymentModel;
    final price = job.pricePerKg ?? job.itemPrice;

    return Row(
      children: [
        if (job.minQuantityKg != null && payModel == PaymentModel.perKg)
          _InfoChip(
            icon: Icons.scale_rounded,
            label: l10n.collectionJobMinQtyFrom(job.minQuantityKg!.toStringAsFixed(0)),
            color: const Color(0xFF7C3AED),
          ),
        const Spacer(),
        if (payModel != null)
          _InfoChip(
            icon: payModel == PaymentModel.perKg
                ? Icons.scale_rounded
                : Icons.payments_rounded,
            label: payModel.labelFor(locale),
            color: const Color(0xFF14401F),
          ),
        if (price != null) ...[
          const SizedBox(width: 8),
          Text(
            '$price ${payModel?.unitLabelFor(locale) ?? 'JD'}',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF14401F),
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.monetization_on_rounded,
            size: 15,
            color: Color(0xFF14401F),
          ),
        ],
      ],
    );
  }

  Widget _buildDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        job.jobDescription!,
        textAlign: TextAlign.right,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.cairo(
          fontSize: 12,
          color: const Color(0xFF404943),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        if (showClaimButton && onClaim != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onClaim,
              icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
              label: Text(
                l10n.collectionJobAcceptButton,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14401F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          )
        else
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14, color: Color(0xFF717973)),
                const SizedBox(width: 4),
                Text(
                  l10n.driverViewDetails,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: const Color(0xFF717973),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(width: 10),
        Row(
          children: [
            const Icon(Icons.location_on_rounded,
                size: 13, color: Color(0xFF9CA3AF)),
            const SizedBox(width: 3),
            Text(
              job.pickupAddress,
              style: GoogleFonts.cairo(
                  fontSize: 11, color: const Color(0xFF717973)),
            ),
          ],
        ),
      ],
    );
  }

  String _formatAge(BuildContext context, DateTime dt) {
    final l10n = context.l10n;
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return l10n.timeAgoDays(diff.inDays);
    if (diff.inHours > 0) return l10n.timeAgoHours(diff.inHours);
    return l10n.timeAgoMinutes(diff.inMinutes);
  }
}

class _JobBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFD4EBAB),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.work_rounded, size: 12, color: Color(0xFF14401F)),
          const SizedBox(width: 4),
          Text(
            context.l10n.collectionJobBadge,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF14401F),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, size: 12, color: color),
        ],
      ),
    );
  }
}
