import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dwaar/core/constants/app_colors.dart';
import 'package:dwaar/data/models/order.dart';
import 'package:dwaar/ui/common/map/order_route_map.dart';

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
    // Coordinates available — show real map
    if (order.pickupLat != null && order.dropoffLat != null) {
      return OrderRouteMap(
        pickupLat: order.pickupLat!,
        pickupLng: order.pickupLng!,
        dropoffLat: order.dropoffLat!,
        dropoffLng: order.dropoffLng!,
        driverLat: (hasDriver && order.status == OrderStatus.inTransit)
            ? _simulatedDriverLat(order)
            : null,
        driverLng: (hasDriver && order.status == OrderStatus.inTransit)
            ? _simulatedDriverLng(order)
            : null,
        height: 240,
        interactive: false,
      );
    }

    // Fallback placeholder — no coordinates
    return const _MapPlaceholder();
  }

  double _simulatedDriverLat(Order order) {
    final f = _progressFraction(order);
    return order.pickupLat! + (order.dropoffLat! - order.pickupLat!) * f;
  }

  double _simulatedDriverLng(Order order) {
    final f = _progressFraction(order);
    return order.pickupLng! + (order.dropoffLng! - order.pickupLng!) * f;
  }

  double _progressFraction(Order order) {
    if (order.inTransitAt == null) return 0.1;
    final elapsed = DateTime.now().difference(order.inTransitAt!).inSeconds;
    return (elapsed / 600).clamp(0.05, 0.95);
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
              '\u0627\u0644\u062e\u0631\u064a\u0637\u0629 \u063a\u064a\u0631 \u0645\u062a\u0648\u0641\u0631\u0629',
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
