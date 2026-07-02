import 'package:flutter/material.dart';
import 'package:dwaar/core/theme/app_tokens.dart';
import 'package:dwaar/core/constants/app_colors.dart';

class HomeDriverBar extends StatelessWidget {
  const HomeDriverBar({
    super.key,
    required this.name,
    required this.rating,
    required this.etaMinutes,
  });

  final String name;
  final double rating;
  final String etaMinutes;

  @override
  Widget build(BuildContext context) {
    final dt = context.dt;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: dt.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dt.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: dt.shadow.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F5E9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_shipping_outlined,
              size: 18,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'السائق النشط',
                  style: TextStyle(fontSize: 9, color: dt.onSurfaceMuted),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: dt.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (_) => const Icon(
                        Icons.star_rounded,
                        size: 11,
                        color: AppColors.accentAmber,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: dt.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 11, color: Color(0xFF1565C0)),
                const SizedBox(width: 3),
                Text(
                  '$etaMinutes دقيقة',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
