import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../core/components/dwaar_detail_card.dart';

class OrderRouteCard extends StatelessWidget {
  const OrderRouteCard({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return DwaarDetailSection(
      icon: LucideIcons.route,
      title: 'مسار الطلب',
      accentColor: AppColors.primaryGreen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Route visual ──
          Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon column
              Column(
                children: [
                  const SizedBox(height: 2),
                  _RouteIcon(
                    icon: LucideIcons.packageOpen,
                    color: AppColors.primaryGreen,
                  ),
                  ..._buildDashedLine(),
                  _RouteIcon(
                    icon: LucideIcons.building2,
                    color: const Color(0xFFD32F2F),
                    isSquare: true,
                  ),
                ],
              ),
              const SizedBox(width: 12),
              // Address column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _RoutePoint(
                      label: 'نقطة الاستلام',
                      address: order.pickupAddress,
                      labelColor: AppColors.primaryGreen,
                    ),
                    const SizedBox(height: 24),
                    _RoutePoint(
                      label: 'نقطة التسليم',
                      address: order.dropoffAddress,
                      labelColor: const Color(0xFFD32F2F),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Distance + ETA chips ──
          if (order.distanceKm != null || order.etaMinutes != null) ...[
            const DwaarDetailDivider(verticalPadding: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (order.distanceKm != null) ...[
                  DwaarDetailChip(
                    icon: LucideIcons.map,
                    label: '${order.distanceKm!.toStringAsFixed(1)} كم',
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 10),
                ],
                if (order.etaMinutes != null)
                  DwaarDetailChip(
                    icon: LucideIcons.clock,
                    label: '~${order.etaMinutes} دقيقة',
                    color: const Color(0xFF1565C0),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildDashedLine() {
    return List.generate(
      5,
      (_) => Container(
        width: 2,
        height: 6,
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.borderSubtle,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

class _RouteIcon extends StatelessWidget {
  const _RouteIcon({
    required this.icon,
    required this.color,
    this.isSquare = false,
  });
  final IconData icon;
  final Color color;
  final bool isSquare;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
        borderRadius: isSquare ? BorderRadius.circular(8) : null,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Icon(icon, size: 15, color: color),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({
    required this.label,
    required this.address,
    required this.labelColor,
  });
  final String label;
  final String address;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          address,
          textAlign: TextAlign.end,
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: const Color(0xFF404943),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
