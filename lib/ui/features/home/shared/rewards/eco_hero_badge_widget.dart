import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_tokens.dart';
import '../../../../../data/models/eco_badge.dart';

/// Displays all earned + locked badges in a horizontal scroll row.
/// Shows the Eco Hero badge prominently when earned (100 kg milestone).
class EcoBadgesSection extends StatelessWidget {
  final double lifetimeKg;
  final int completedOrders;

  const EcoBadgesSection({
    super.key,
    required this.lifetimeKg,
    required this.completedOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: Text(
            'إنجازاتك',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            reverse: true,
            itemCount: EcoBadge.all.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final badge = EcoBadge.all[index];
              final earned = badge.isEarned(
                lifetimeKg: lifetimeKg,
                completedOrders: completedOrders,
              );
              return _BadgeChip(badge: badge, earned: earned);
            },
          ),
        ),
      ],
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final EcoBadge badge;
  final bool earned;

  const _BadgeChip({required this.badge, required this.earned});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: earned ? 1.0 : 0.35,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: earned ? badge.surface : context.dt.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: earned
                ? badge.color.withValues(alpha: 0.35)
                : Colors.transparent,
            width: earned ? 1.5 : 0,
          ),
          boxShadow: earned
              ? [
                  BoxShadow(
                    color: badge.color.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(badge.emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 6),
            Text(
              badge.label,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: earned ? badge.color : context.dt.onSurfaceMuted,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!earned) ...[
              const SizedBox(height: 2),
              Text(
                badge.requirementLabel,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 9,
                  color: context.dt.onSurfaceMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Full-width Eco Hero celebration banner — shown when user has earned
/// the 100 kg badge. Used at top of the rewards page.
class EcoHeroBanner extends StatefulWidget {
  final String userName;

  const EcoHeroBanner({super.key, required this.userName});

  @override
  State<EcoHeroBanner> createState() => _EcoHeroBannerState();
}

class _EcoHeroBannerState extends State<EcoHeroBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF4C1D95)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.30),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '🌟 مبروك، بطل إيكو!',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.userName} جمع 100 كغ+ من المواد القابلة للتدوير '
                    'وأثّر إيجابياً على بيئة عمان.',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(
                      fontSize: 12.5,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            const Text('🏅', style: TextStyle(fontSize: 48)),
          ],
        ),
      ),
    );
  }
}
