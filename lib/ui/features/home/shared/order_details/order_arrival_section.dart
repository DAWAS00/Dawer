import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../l10n/l10n.dart';

/// Shown in order details for:
///   - Driver in `accepted` state   → "I'm Here — Pickup" button
///   - Driver in `arrivedAtPickup`  → "Awaiting supplier" banner
///   - Driver in `inTransit` state  → "I'm Here — Dropoff" button
///   - Supplier in `arrivedAtPickup`→ "Driver arrived" card with confirm buttons
class OrderArrivalSection extends StatefulWidget {
  final Order order;
  final Future<String?> Function(Order)? onMarkArrivedAtPickup;
  final Future<String?> Function(Order)? onMarkArrivedAtDropoff;
  final void Function(bool available)? onSupplierConfirmArrival;

  const OrderArrivalSection({
    super.key,
    required this.order,
    this.onMarkArrivedAtPickup,
    this.onMarkArrivedAtDropoff,
    this.onSupplierConfirmArrival,
  });

  @override
  State<OrderArrivalSection> createState() => _OrderArrivalSectionState();
}

class _OrderArrivalSectionState extends State<OrderArrivalSection> {
  bool _loading = false;

  bool get _isDriverView =>
      widget.onMarkArrivedAtPickup != null ||
      widget.onMarkArrivedAtDropoff != null;

  Future<void> _tap(Future<String?> Function(Order) cb) async {
    setState(() => _loading = true);
    try {
      final error = await cb(widget.order);
      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error, style: GoogleFonts.cairo(color: Colors.white)),
            backgroundColor: const Color(0xFF991B1B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final s = widget.order.status;

    if (_isDriverView) {
      if (s == OrderStatus.accepted && widget.onMarkArrivedAtPickup != null) {
        return _ArrivalCard(
          icon: Icons.location_on_rounded,
          iconColor: AppColors.primaryGreen,
          iconBg: AppColors.statusActiveBg,
          borderColor: AppColors.primaryGreen,
          title: l10n.orderArrivalAtPickup,
          subtitle: l10n.orderArrivalGeoNote,
          buttonLabel: l10n.orderArrivalHerePickup,
          buttonGradient: const LinearGradient(
            colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
          ),
          loading: _loading,
          onTap: () => _tap(widget.onMarkArrivedAtPickup!),
        );
      }
      if (s == OrderStatus.arrivedAtPickup) {
        return _AwaitingBanner();
      }
      if (s == OrderStatus.inTransit && widget.onMarkArrivedAtDropoff != null) {
        return _ArrivalCard(
          icon: Icons.flag_rounded,
          iconColor: const Color(0xFF1E40AF),
          iconBg: AppColors.statusInTransitBg,
          borderColor: const Color(0xFF1E40AF),
          title: l10n.orderArrivalAtDropoff,
          subtitle: l10n.orderArrivalGeoNote,
          buttonLabel: l10n.orderArrivalHereDropoff,
          buttonGradient: const LinearGradient(
            colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
          ),
          loading: _loading,
          onTap: () => _tap(widget.onMarkArrivedAtDropoff!),
        );
      }
    } else {
      if (s == OrderStatus.arrivedAtPickup &&
          widget.onSupplierConfirmArrival != null) {
        return _SupplierConfirmCard(
          onConfirm: widget.onSupplierConfirmArrival!,
        );
      }
    }

    return const SizedBox.shrink();
  }
}

// ── Reusable card shell ───────────────────────────────────────────────────────

class _ArrivalCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color borderColor;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final Gradient buttonGradient;
  final bool loading;
  final VoidCallback onTap;

  const _ArrivalCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.borderColor,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.buttonGradient,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Spacer(),
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF002819),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: iconBg,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withValues(alpha: 0.2),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: _GradientButton(
                  gradient: buttonGradient,
                  loading: loading,
                  label: buttonLabel,
                  onTap: onTap,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(
          begin: 0.05,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }
}

// ── Gradient Button ───────────────────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  final Gradient gradient;
  final bool loading;
  final String label;
  final VoidCallback onTap;

  const _GradientButton({
    required this.gradient,
    required this.loading,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: loading ? null : gradient,
        color: loading ? AppColors.mutedText.withValues(alpha: 0.3) : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: loading
            ? null
            : [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: loading ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: loading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.1,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Driver awaiting banner ────────────────────────────────────────────────────

class _AwaitingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.accentAmber.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentAmber.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.orderArrivalAwaitingSupplier,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF92400E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.orderArrivalAwaitingSubtitle,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: const Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accentAmber.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    color: Color(0xFF92400E),
                    size: 22,
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .rotate(
                  begin: -0.05,
                  end: 0.05,
                  duration: 1500.ms,
                  curve: Curves.easeInOut,
                ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ── Supplier confirmation card ────────────────────────────────────────────────

class _SupplierConfirmCard extends StatelessWidget {
  final void Function(bool available) onConfirm;
  const _SupplierConfirmCard({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    l10n.orderArrivalDriverArrived,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF002819),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.statusActiveBg,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withValues(alpha: 0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.directions_car_rounded,
                      color: AppColors.primaryGreen,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                l10n.orderArrivalDriverAtLocation,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: const Color(0xFF404943),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onConfirm(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.statusCancelledText,
                        side: BorderSide(
                          color: AppColors.statusCancelledText.withValues(
                            alpha: 0.5,
                          ),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        minimumSize: const Size(0, 56),
                      ),
                      child: Text(
                        l10n.unavailable,
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.ctaGradientStart,
                            AppColors.ctaGradientEnd,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.25,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          onTap: () => onConfirm(true),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                l10n.orderArrivalIAmAvailable,
                                style: GoogleFonts.cairo(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(
          begin: 0.05,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
