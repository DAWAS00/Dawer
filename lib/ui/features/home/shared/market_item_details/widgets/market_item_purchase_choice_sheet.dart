import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../l10n/l10n.dart';

class MarketItemPurchaseChoiceSheet extends StatelessWidget {
  final VoidCallback onSelfPickup;
  final VoidCallback onAssignRider;

  const MarketItemPurchaseChoiceSheet({
    super.key,
    required this.onSelfPickup,
    required this.onAssignRider,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.marketPurchaseChoiceTitle,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.marketPurchaseChoiceSubtitle,
            style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF717973)),
          ),
          const SizedBox(height: 16),
          _PurchaseOptionTile(
            icon: Icons.storefront_rounded,
            title: l10n.marketPurchaseSelfPickup,
            subtitle: l10n.marketPurchaseNoFee,
            onTap: onSelfPickup,
          ),
          const SizedBox(height: 10),
          _PurchaseOptionTile(
            icon: Icons.local_shipping_rounded,
            title: l10n.marketPurchaseAssignRider,
            subtitle: l10n.marketPurchaseRiderFeeNote,
            onTap: onAssignRider,
          ),
        ],
      ),
    );
  }
}

class _PurchaseOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PurchaseOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE6E9E7)),
        ),
        child: Row(
          children: [
            const Icon(Icons.chevron_left_rounded, color: Color(0xFF9CA3AF), size: 20),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002819),
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF717973)),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF06402B).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF06402B), size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
