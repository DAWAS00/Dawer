import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../data/models/reward_transaction.dart';
import '../../../../../data/services/app_order_store.dart';
import '../../../../../data/services/eco_points_engine.dart';
import '../../../../../domain/entities/green_level.dart';
import '../../../../../l10n/l10n.dart';
import '../../shared/rewards/discount_coupons_widget.dart';
import '../../shared/rewards/eco_hero_badge_widget.dart';
import '../../shared/rewards/neighborhood_leaderboard_widget.dart';

/// A single redemption offer in the خُضَر catalogue.
class _RedeemOption {
  const _RedeemOption({
    required this.cost,
    required this.title,
    required this.reward,
    required this.icon,
  });
  final int cost;
  final String title;
  final String reward;
  final IconData icon;
}

/// D3 — Enhanced Rewards System & خُضَر Green Credits rewards screen — shared by driver and supplier.
///
/// Shows: live points balance + tier progress, Eco Hero badge (100 kg),
/// achievement badges, redemption catalog, partner coupons,
/// neighborhood leaderboard, and transaction history.
class RewardsView extends StatelessWidget {
  final String userId;
  final String userName;
  final int completedOrders;
  final double? lifetimeKg;

  const RewardsView({
    super.key,
    required this.userId,
    this.userName = '',
    this.completedOrders = 0,
    this.lifetimeKg,
  });

  static const List<_RedeemOption> _options = [
    _RedeemOption(
      cost: 500,
      title: 'خصم على الطلبات',
      reward: '٥ د.أ',
      icon: Icons.discount_rounded,
    ),
    _RedeemOption(
      cost: 1000,
      title: 'قسيمة شراء',
      reward: '١٢ د.أ',
      icon: Icons.card_giftcard_rounded,
    ),
    _RedeemOption(
      cost: 2000,
      title: 'شحن مجاني',
      reward: 'لمدة شهر',
      icon: Icons.local_shipping_rounded,
    ),
  ];

  Future<void> _confirmRedeem(
    BuildContext context,
    _RedeemOption option,
  ) async {
    final store = context.read<AppOrderStore>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'تأكيد الاستبدال',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'سيتم خصم ${option.cost} خُضَر مقابل "${option.title} — ${option.reward}". هل تريد المتابعة؟',
          style: GoogleFonts.cairo(),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
            ),
            child: Text(
              'استبدال',
              style: GoogleFonts.cairo(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final ok = store.redeemGreenCredits(
      userId,
      cost: option.cost,
      description: 'استبدال: ${option.title} — ${option.reward}',
    );
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'تم الاستبدال بنجاح 🎉 ${option.reward}' : 'رصيد خُضَر غير كافٍ',
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        backgroundColor: ok ? const Color(0xFF166534) : const Color(0xFF991B1B),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  double _getLifetimeKg(int points) =>
      lifetimeKg ?? EcoPointsEngine.lifetimeKgFromPoints(points);

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppOrderStore>();
    final points = store.greenPointsFor(userId);
    final transactions = store.greenTransactionsFor(userId);
    final level = GreenLevelInfo.fromPoints(points);
    final currentLifetimeKg = _getLifetimeKg(points);
    final isEcoHero = EcoPointsEngine.isEcoHero(currentLifetimeKg);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        title: Text(
          context.l10n.rewardsTitle,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Points balance card ───────────────────────────────────────────
          _BalanceCard(
            points: points,
            level: level,
            lifetimeKg: currentLifetimeKg,
          ),
          const SizedBox(height: 16),

          // ── Eco Hero banner (shown only when earned) ──────────────────────
          if (isEcoHero) ...[
            EcoHeroBanner(userName: userName.isNotEmpty ? userName : 'أنت'),
            const SizedBox(height: 16),
          ],

          // ── Achievement badges ────────────────────────────────────────────
          _card(
            child: EcoBadgesSection(
              lifetimeKg: currentLifetimeKg,
              completedOrders: completedOrders,
            ),
          ),
          const SizedBox(height: 16),

          // ── Interactive Redemption Options ────────────────────────────────
          _buildRedemptionSection(context, points),
          const SizedBox(height: 16),

          // ── Partner coupons ───────────────────────────────────────────────
          _card(child: DiscountCouponsSection(totalPoints: points)),
          const SizedBox(height: 16),

          // ── Neighborhood leaderboard ──────────────────────────────────────
          _card(child: const NeighborhoodLeaderboardPreview()),
          const SizedBox(height: 24),

          // ── Transaction history ───────────────────────────────────────────
          Text(
            context.l10n.rewardsHistoryTitle,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819),
            ),
          ),
          const SizedBox(height: 12),
          if (transactions.isNotEmpty)
            ...transactions.map((t) => _TransactionTile(transaction: t))
          else
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.eco_outlined,
                      size: 64,
                      color: AppColors.primaryGreen,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.l10n.rewardsNoHistory,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: const Color(0xFF717973),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildRedemptionSection(BuildContext context, int points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'استبدل نقاط خُضَر',
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF002819),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _options.map((o) {
            final affordable = points >= o.cost;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Opacity(
                  opacity: affordable ? 1.0 : 0.5,
                  child: GestureDetector(
                    onTap: affordable ? () => _confirmRedeem(context, o) : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: affordable
                              ? AppColors.primaryGreen.withValues(alpha: 0.4)
                              : const Color(0xFFE6E9E7),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(o.icon, color: AppColors.primaryGreen, size: 28),
                          const SizedBox(height: 6),
                          Text(
                            o.title,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF002819),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            o.reward,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${o.cost} خُضَر',
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              color: const Color(0xFF717973),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.points,
    required this.level,
    required this.lifetimeKg,
  });
  final int points;
  final GreenLevel level;
  final double lifetimeKg;

  @override
  Widget build(BuildContext context) {
    final progress = level.isMaxLevel
        ? 1.0
        : ((points - level.lowerThreshold) /
                  (level.nextThreshold - level.lowerThreshold))
              .clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryGreen, Color(0xFF1E6B35)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              // Lifetime kg stat
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.eco_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${lifetimeKg.toStringAsFixed(0)} كغ',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Tier/Level badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '${level.emoji} ${level.arabicLabel}',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.eco_rounded, color: Color(0xFFB9F6CA), size: 28),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$points',
            style: GoogleFonts.dmSans(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            'خُضَر',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFB9F6CA),
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            level.isMaxLevel
                ? 'وصلت لأعلى مستوى — حارس الغابة 🌍'
                : '$points / ${level.nextThreshold} للمستوى التالي',
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            level.unlockDescription,
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final RewardTransaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isPositive = transaction.type.isPositive;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          Text(
            '${isPositive ? '+' : '-'}${transaction.points}',
            style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isPositive
                  ? const Color(0xFF166534)
                  : const Color(0xFF991B1B),
            ),
          ),
          const Spacer(),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction.description,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF002819),
                  ),
                ),
                Text(
                  DateFormatter.relative(transaction.createdAt),
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: const Color(0xFF717973),
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
