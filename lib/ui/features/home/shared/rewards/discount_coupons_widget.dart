import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_tokens.dart';
import '../../../../../data/services/eco_points_engine.dart';

/// Grid of partner discount coupons. Locked coupons show the points
/// required; unlocked ones reveal the code with a copy-to-clipboard button.
class DiscountCouponsSection extends StatelessWidget {
  final int totalPoints;

  const DiscountCouponsSection({super.key, required this.totalPoints});

  @override
  Widget build(BuildContext context) {
    final coupons = EcoPointsEngine.coupons;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'كوبونات الشركاء',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.10,
          ),
          itemCount: coupons.length,
          itemBuilder: (context, index) {
            final coupon = coupons[index];
            final unlocked = totalPoints >= coupon.pointsRequired;
            return _CouponCard(
              coupon: coupon,
              unlocked: unlocked,
            );
          },
        ),
      ],
    );
  }
}

class _CouponCard extends StatelessWidget {
  final DiscountCoupon coupon;
  final bool unlocked;

  const _CouponCard({required this.coupon, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    final accent = Color(coupon.color | 0xFF000000);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: unlocked
            ? accent.withValues(alpha: 0.07)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked
              ? accent.withValues(alpha: 0.30)
              : Theme.of(context).dividerColor,
          width: unlocked ? 1.5 : 1.0,
        ),
        boxShadow: unlocked
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              if (!unlocked)
                Icon(Icons.lock_rounded, size: 14, color: accent.withValues(alpha: 0.50))
              else
                GestureDetector(
                  onTap: () => _copyCode(context),
                  child: Icon(Icons.copy_rounded,
                      size: 14, color: accent),
                ),
              const Spacer(),
              Text(coupon.iconEmoji,
                  style: const TextStyle(fontSize: 22)),
            ],
          ),
          const Spacer(),
          Text(
            coupon.title,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: unlocked
                  ? accent
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          if (unlocked)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                coupon.code,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: accent,
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${coupon.pointsRequired} نقطة',
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: context.dt.onSurfaceMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _copyCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: coupon.code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم نسخ الكود: ${coupon.code}',
          style: GoogleFonts.cairo(),
          textAlign: TextAlign.right,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: const Color(0xFF1E5C35),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
