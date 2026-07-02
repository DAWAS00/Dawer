import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/login_viewmodel.dart';
import '../../../../../l10n/l10n.dart';

// ════════════════════════════════════════════════════════════════════════════════
// SupplierPortalSelector
//
// When nothing is chosen → two tall branded portal cards side by side.
// When a sub-type is selected  → cards animate into a slim 48 px banner with a
//   "تغيير" chip that resets the selection back to the card view.
// ════════════════════════════════════════════════════════════════════════════════

class SupplierPortalSelector extends StatelessWidget {
  const SupplierPortalSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();
    final chosen = vm.supplierType;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SizeTransition(sizeFactor: anim, child: child),
      ),
      child: chosen == null
          ? _PortalCardRow(key: const ValueKey('cards'))
          : _SelectionBanner(key: ValueKey(chosen), chosen: chosen),
    );
  }
}

// ── Two portal cards ──────────────────────────────────────────────────────────

class _PortalCardRow extends StatelessWidget {
  const _PortalCardRow({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'اختر نوع حسابك',
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF404943),
              letterSpacing: 0.4,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _PortalCard(
                label: l10n.supplierTypeIndividual,
                subtitle: 'بيع مخلفاتك الشخصية مباشرة',
                icon: Icons.person_pin_circle_rounded,
                accentColor: const Color(0xFF1565C0),
                type: SupplierType.individual,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PortalCard(
                label: l10n.supplierTypeStore,
                subtitle: 'إدارة مخلفات نشاطك التجاري',
                icon: Icons.storefront_rounded,
                accentColor: const Color(0xFF00695C),
                type: SupplierType.storeBusiness,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PortalCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final SupplierType type;

  const _PortalCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<LoginViewModel>().setSupplierType(type),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [accentColor, Color.lerp(accentColor, Colors.black, 0.16)!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Slim selection banner ─────────────────────────────────────────────────────

class _SelectionBanner extends StatelessWidget {
  final SupplierType chosen;
  const _SelectionBanner({super.key, required this.chosen});

  static const _meta = {
    SupplierType.individual: (
      label: 'مورد فردي',
      icon: Icons.person_pin_circle_rounded,
      color: Color(0xFF1565C0),
    ),
    SupplierType.storeBusiness: (
      label: 'متجر / شركة',
      icon: Icons.storefront_rounded,
      color: Color(0xFF00695C),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final meta = _meta[chosen]!;
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: meta.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: meta.color.withValues(alpha: 0.35)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          // Reset chip
          GestureDetector(
            onTap: () => context.read<LoginViewModel>().clearSupplierType(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: meta.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'تغيير',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: meta.color,
                ),
              ),
            ),
          ),
          const Spacer(),
          Text(
            meta.label,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: meta.color,
            ),
          ),
          const SizedBox(width: 8),
          Icon(meta.icon, size: 18, color: meta.color),
        ],
      ),
    );
  }
}
