import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order/order.dart';
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
    // Layered containers: outer = blue accent strip, inner = white card body.
    // This avoids Flutter's "non-uniform Border + borderRadius" restriction.
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.jobBlue,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.jobBlue.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsetsDirectional.only(start: 4),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(13),
              bottomStart: Radius.circular(13),
              topEnd: Radius.circular(16),
              bottomEnd: Radius.circular(16),
            ),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
              const Divider(height: 1, color: Color(0xFFEFF6FF)),
              const SizedBox(height: 12),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Company icon
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.jobBlueBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.recycling_rounded,
            size: 22,
            color: AppColors.jobBlue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.supplierName ?? l10n.collectionJobRecyclingCoLabel,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0D1F15),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _formatAge(context, job.createdAt),
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: const Color(0xFF717973),
                ),
              ),
            ],
          ),
        ),
        // Badges column
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _JobBadge(),
            if (job.isEdited) ...[
              const SizedBox(height: 4),
              _EditedBadge(l10n: l10n),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildWasteChips(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: job.wasteTypes
          .map(
            (t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.jobBlueBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                t.labelFor(locale),
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.jobBlue,
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
            label: l10n.collectionJobMinQtyFrom(
              job.minQuantityKg!.toStringAsFixed(0),
            ),
            bgColor: const Color(0xFFF3E8FF),
            textColor: const Color(0xFF7C3AED),
          ),
        const Spacer(),
        if (payModel != null) ...[
          _InfoChip(
            icon: payModel == PaymentModel.perKg
                ? Icons.scale_rounded
                : Icons.payments_outlined,
            label: payModel.labelFor(locale),
            bgColor: AppColors.jobBlueBg,
            textColor: AppColors.jobBlue,
          ),
          const SizedBox(width: 8),
        ],
        if (price != null)
          Text(
            '${price.toStringAsFixed(1)} ${payModel?.unitLabelFor(locale) ?? 'JD'}',
            style: GoogleFonts.dmSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.jobBlue,
            ),
          ),
      ],
    );
  }

  Widget _buildDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.jobBlueBorder),
      ),
      child: Text(
        job.jobDescription!,
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
        // Location
        Expanded(
          child: Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 13,
                color: Color(0xFF9CA3AF),
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  job.pickupAddress,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: const Color(0xFF717973),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        // Action
        if (showClaimButton && onClaim != null)
          ElevatedButton.icon(
            onPressed: onClaim,
            icon: const Icon(Icons.check_circle_outline_rounded, size: 15),
            label: Text(
              l10n.collectionJobAcceptButton,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.jobBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
          )
        else
          TextButton.icon(
            onPressed: onTap,
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: AppColors.jobBlue,
            ),
            label: Text(
              l10n.driverViewDetails,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: AppColors.jobBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
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
        color: AppColors.jobBlueBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.jobBlueBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.work_outline_rounded,
            size: 11,
            color: AppColors.jobBlue,
          ),
          const SizedBox(width: 4),
          Text(
            context.l10n.collectionJobBadge,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.jobBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditedBadge extends StatelessWidget {
  final dynamic l10n;
  const _EditedBadge({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.amberContainer,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.edit_rounded, size: 10, color: Color(0xFF92400E)),
          const SizedBox(width: 3),
          Text(
            l10n.collectionJobEdited as String,
            style: GoogleFonts.cairo(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF92400E),
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
  final Color bgColor;
  final Color textColor;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
