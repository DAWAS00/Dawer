import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dwaar/l10n/l10n.dart';

class MarketItemRiderChoiceSheet extends StatelessWidget {
  final VoidCallback onBuyForSelf;
  final VoidCallback onDeliver;

  const MarketItemRiderChoiceSheet({
    super.key,
    required this.onBuyForSelf,
    required this.onDeliver,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Center(
            child: Container(
              width: 50,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.marketRiderChoiceTitle,
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.marketRiderChoiceSubtitle,
            style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF717973)),
          ),
          const SizedBox(height: 16),
          _ChoiceOptionTile(
            icon: Icons.shopping_bag_rounded,
            title: l10n.marketRiderOptionBuy,
            subtitle: l10n.marketRiderOptionBuySubtitle,
            onTap: onBuyForSelf,
          ),
          const SizedBox(height: 10),
          _ChoiceOptionTile(
            icon: Icons.local_shipping_rounded,
            title: l10n.marketRiderOptionDeliver,
            subtitle: l10n.marketRiderOptionDeliverSubtitle,
            onTap: onDeliver,
          ),
        ],
      ),
    );
  }
}

class _ChoiceOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ChoiceOptionTile({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
