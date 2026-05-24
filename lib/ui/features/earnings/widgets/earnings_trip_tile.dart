import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/entities/earnings/trip_earning.dart';

class EarningsTripTile extends StatelessWidget {
  final TripEarning trip;

  const EarningsTripTile({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'رحلة #${trip.orderId} بقيمة ${trip.amount} دينار من ${trip.pickupAddress} إلى ${trip.dropoffAddress}',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'طلب #${trip.orderId}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${trip.pickupAddress} ← ${trip.dropoffAddress}',
                    style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '+${trip.amount.toStringAsFixed(2)} د.أ',
                  style: const TextStyle(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${trip.distanceKm} كم',
                  style: const TextStyle(color: AppColors.mutedText, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
