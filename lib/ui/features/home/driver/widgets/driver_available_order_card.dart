import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/waste_type_icons.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../l10n/l10n.dart';

class DriverAvailableOrderCard extends StatefulWidget {
  const DriverAvailableOrderCard({
    super.key,
    required this.order,
    required this.onAccept,
    this.onTap,
  });

  final Order order;
  final Future<String?> Function() onAccept;
  final VoidCallback? onTap;

  @override
  State<DriverAvailableOrderCard> createState() =>
      _DriverAvailableOrderCardState();
}

class _DriverAvailableOrderCardState extends State<DriverAvailableOrderCard> {
  bool _isLoading = false;
  bool _isSuccess = false;

  Future<void> _handleAccept() async {
    // 1. Confirmation Dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          context.l10n.orderAcceptButton,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل أنت متأكد من رغبتك في قبول هذا الطلب؟',
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              context.l10n.cancel,
              style: GoogleFonts.cairo(color: AppColors.mutedText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              context.l10n.confirm,
              style: GoogleFonts.cairo(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 2. Set loading state
    setState(() => _isLoading = true);

    // 3. Attempt to accept
    final error = await widget.onAccept();

    if (!mounted) return;

    if (error != null) {
      // Failed: reset loading so card stays visible
      setState(() => _isLoading = false);
    } else {
      // Success: show checkmark, then the parent will unmount this widget
      setState(() {
        _isLoading = false;
        _isSuccess = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final (badgeLabel, badgeBg, badgeFg) = _resolveBadge(
      widget.order.status,
      context,
    );
    final dateString =
        '${widget.order.createdAt.day}/${widget.order.createdAt.month}/${widget.order.createdAt.year}';

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header: ID + date, reward badge, status badge ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  // Badges group — Flexible so they never push the ID off screen.
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Status badge
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              badgeLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: badgeFg,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Reward badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.amberContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.coins,
                                size: 12,
                                color: AppColors.accentAmber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.order.reward.toStringAsFixed(1)} د.أ',
                                style: GoogleFonts.dmSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accentAmber,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Order ID + date — truncate long UUIDs to last 8 chars.
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '#${widget.order.id.length > 8 ? widget.order.id.substring(widget.order.id.length - 8) : widget.order.id}',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF191C1B),
                        ),
                      ),
                      Text(
                        dateString,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      LucideIcons.package,
                      size: 15,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: AppColors.borderSubtle, thickness: 1),

            // ── Body: Route + Metrics + Chips + Action ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildRouteLine(context),
                  const SizedBox(height: 16),

                  // Metrics row: distance + waste type
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAF8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetric(
                          icon: LucideIcons.map,
                          label: context.l10n.driverDistanceLabel,
                          value: widget.order.distanceKm != null
                              ? '${widget.order.distanceKm!.toStringAsFixed(1)} كم'
                              : '--',
                        ),
                        Container(
                          width: 1,
                          height: 24,
                          color: AppColors.borderSubtle,
                        ),
                        _buildMetric(
                          icon: LucideIcons.recycle,
                          label: context.l10n.driverWasteTypeLabel,
                          value: widget.order.wasteTypes.isNotEmpty
                              ? widget.order.wasteTypes.first.label
                              : '--',
                        ),
                        if (widget.order.distanceKm != null &&
                            widget.order.etaMinutes != null) ...[
                          Container(
                            width: 1,
                            height: 24,
                            color: AppColors.borderSubtle,
                          ),
                          _buildMetric(
                            icon: LucideIcons.clock,
                            label: context.l10n.driverTimeLabel,
                            value: '${widget.order.etaMinutes} د',
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Waste type chips
                  if (widget.order.wasteTypes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        ...widget.order.wasteTypes
                            .take(4)
                            .map((t) => _WasteChip(type: t)),
                        if (widget.order.wasteTypes.length > 4)
                          _MoreChip(count: widget.order.wasteTypes.length - 4),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Accept button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child:
                        ElevatedButton(
                              onPressed: (_isLoading || _isSuccess)
                                  ? null
                                  : _handleAccept,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isSuccess
                                    ? const Color(0xFF4CAF50)
                                    : AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 3,
                                      ),
                                    )
                                  : _isSuccess
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          LucideIcons.checkCircle2,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          context.l10n.driverOrderAccepted,
                                          style: GoogleFonts.cairo(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          context.l10n.orderAcceptButton,
                                          style: GoogleFonts.cairo(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          LucideIcons.arrowLeft,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                            )
                            .animate(target: _isSuccess ? 1 : 0)
                            .shimmer(duration: 400.ms, color: Colors.white24),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(target: _isSuccess ? 1 : 0).fadeOut(duration: 300.ms, delay: 600.ms);
  }

  Widget _buildRouteLine(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildNode(
          icon: LucideIcons.packageOpen,
          title: context.l10n.driverPickupLabel,
          subtitle: widget.order.pickupAddress,
          color: AppColors.primaryGreen,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 18),
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGreen.withValues(alpha: 0.6),
                    const Color(0xFFD32F2F).withValues(alpha: 0.6),
                  ],
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                ),
              ),
            ),
          ),
        ),
        _buildNode(
          icon: LucideIcons.building2,
          title: context.l10n.driverDeliveryLabel,
          subtitle: widget.order.dropoffAddress,
          color: const Color(0xFFD32F2F),
        ),
      ],
    );
  }

  Widget _buildNode({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return SizedBox(
      width: 90,
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Icon(icon, color: color, size: 17),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF404943),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.cairo(fontSize: 9, color: AppColors.mutedText),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMetric({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.mutedText),
            const SizedBox(width: 3),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 10,
                color: AppColors.mutedText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
      ],
    );
  }

  (String, Color, Color) _resolveBadge(
    OrderStatus status,
    BuildContext context,
  ) => switch (status) {
    OrderStatus.pending => (
      context.l10n.driverNewOrderBadge,
      const Color(0xFFE3F2FD),
      const Color(0xFF1565C0),
    ),
    _ => (status.label, AppColors.statusActiveBg, AppColors.primaryGreen),
  };
}

class _WasteChip extends StatelessWidget {
  const _WasteChip({required this.type});
  final WasteType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            WasteTypeIcons.iconFor(type),
            size: 12,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(width: 4),
          Text(
            type.label,
            style: GoogleFonts.cairo(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreChip extends StatelessWidget {
  const _MoreChip({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.mutedText.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '+$count',
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: AppColors.mutedText,
        ),
      ),
    );
  }
}
