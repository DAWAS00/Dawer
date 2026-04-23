import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dwaar/core/constants/app_colors.dart';
import 'package:dwaar/data/models/order.dart';
import 'package:dwaar/l10n/l10n.dart';
import 'package:dwaar/ui/common/map/route_map_placeholder.dart';

class OrderMapSection extends StatelessWidget {
  final Order order;
  final bool hasDriver;

  const OrderMapSection({
    super.key,
    required this.order,
    required this.hasDriver,
  });

  @override
  Widget build(BuildContext context) {
    if (order.pickupLat != null && order.dropoffLat != null) {
      return RouteMapPlaceholder(
        pickupLat: order.pickupLat!,
        pickupLng: order.pickupLng!,
        dropoffLat: order.dropoffLat!,
        dropoffLng: order.dropoffLng!,
        height: 240,
      );
    }
    return const _MapPlaceholder();
  }
}

// -- Fallback placeholder (used when coords are null) -------------------------

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      color: AppColors.mapSurface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.map_outlined,
                size: 32, color: AppColors.primaryGreen),
            const SizedBox(height: 8),
            Text(
              context.l10n.mapUnavailable,
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
