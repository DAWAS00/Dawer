import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../l10n/l10n.dart';

/// Top-of-screen live ETA card.
///
/// Shown only while an ETA is actually meaningful: after a driver is
/// assigned and before the order reaches its dropoff. Hidden for
/// `pending` (no driver yet) and `arrivedAtDropoff`/`completed`/`cancelled`
/// (arrival already happened or the order is over).
class OrderEtaSection extends StatelessWidget {
  const OrderEtaSection({
    super.key,
    required this.order,
    this.isDriverView = false,
  });

  final Order order;
  final bool isDriverView;

  bool get _isEtaRelevant => switch (order.status) {
    OrderStatus.accepted || OrderStatus.inTransit => true,
    _ => false,
  };

  @override
  Widget build(BuildContext context) {
    final etaMinutes = order.etaMinutes;
    if (!_isEtaRelevant || etaMinutes == null) return const SizedBox.shrink();

    final l10n = context.l10n;
    final subtitle = switch (order.status) {
      OrderStatus.accepted => l10n.orderDriverOnWay,
      OrderStatus.inTransit when isDriverView => l10n.orderEtaEnRouteToDropoff,
      OrderStatus.inTransit => l10n.supplierOrderInTransitToDest,
      _ => '',
    };

    return Padding(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.navigation,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n.orderDriverArrives(
                          '$etaMinutes ${l10n.orderEtaMinutesUnit}',
                        ),
                        textAlign: TextAlign.end,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          textAlign: TextAlign.end,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 350.ms)
        .slideY(
          begin: 0.06,
          end: 0,
          duration: 400.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
