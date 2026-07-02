import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/constants/app_colors.dart';

class DwaarSkeleton extends StatelessWidget {
  const DwaarSkeleton({super.key, required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: enabled,
      effect: ShimmerEffect(
        baseColor: AppColors.primaryGreen.withValues(alpha: 0.06),
        highlightColor: AppColors.primaryGreen.withValues(alpha: 0.22),
        duration: const Duration(milliseconds: 1100),
      ),
      child: child,
    );
  }
}
