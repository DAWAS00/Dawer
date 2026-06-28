import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../data/models/reward_transaction.dart';
import '../../../../../data/services/eco_points_engine.dart';
import '../../../../../l10n/l10n.dart';
import '../../shared/rewards/eco_hero_badge_widget.dart';
import '../../shared/rewards/neighborhood_leaderboard_widget.dart';
import '../../shared/rewards/discount_coupons_widget.dart';

/// D3 — Enhanced Rewards System.
///
/// Shows: points balance + tier progress, Eco Hero badge (100 kg),
/// all achievement badges, partner coupons, neighborhood leaderboard,
/// and transaction history.
class RewardsView extends StatelessWidget {
  final int totalPoints;
  final List<RewardTransaction> transactions;
  final String userName;

  /// Lifetime kg collected by this supplier. When omitted, derived from
  /// totalPoints using the oil rate (10 pts/kg) as an approximation.
  final double? lifetimeKg;

  final int completedOrders;

  const RewardsView({
    super.key,
    required this.totalPoints,
    this.transactions = const [],
    this.userName = '',
    this.lifetimeKg,
    this.completedOrders = 0,
  });

  double get _lifetimeKg =>
      lifetimeKg ?? EcoPointsEngine.lifetimeKgFromPoints(totalPoints);

  List<(int, String, Color)> _tiers(BuildContext context) => [
        (0, context.l10n.tierBronze, const Color(0xFFB45309)),
        (100, context.l10n.tierSilver, const Color(0xFF6B7280)),
        (300, context.l10n.tierGold, const Color(0xFFD97706)),
        (600, context.l10n.tierPlatinum, const Color(0xFF1E40AF)),
      ];

  (String, Color, int) _currentTier(BuildContext context) {
    final tiers = _tiers(context);
    for (int i = tiers.length - 1; i >= 0; i--) {
      if (totalPoints >= tiers[i].$1) return (tiers[i].$2, tiers[i].$3, tiers[i].$1);
    }
    return (tiers[0].$2, tiers[0].$3, tiers[0].$1);
  }

  int _nextTierThreshold(BuildContext context) {
    for (final tier in _tiers(context)) {
      if (totalPoints < tier.$1) return tier.$1;
    }
    return _tiers(context).last.$1;
  }

  @override
  Widget build(BuildContext context) {
    final (tierName, tierColor, tierStart) = _currentTier(context);
    final nextThreshold = _nextTierThreshold(context);
    final progress = nextThreshold > tierStart
        ? (totalPoints - tierStart) / (nextThreshold - tierStart)
        : 1.0;
    final isEcoHero = EcoPointsEngine.isEcoHero(_lifetimeKg);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF06402B),
        foregroundColor: Colors.white,
        title: Text(
          context.l10n.rewardsTitle,
          style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Points balance card ───────────────────────────────────────────
          _buildBalanceCard(
              context, tierName, tierColor, progress, nextThreshold),
          const SizedBox(height: 16),

          // ── Eco Hero banner (shown only when earned) ──────────────────────
          if (isEcoHero) ...[
            EcoHeroBanner(
                userName: userName.isNotEmpty ? userName : 'أنت'),
            const SizedBox(height: 16),
          ],

          // ── Achievement badges ────────────────────────────────────────────
          _card(
            child: EcoBadgesSection(
              lifetimeKg: _lifetimeKg,
              completedOrders: completedOrders,
            ),
          ),
          const SizedBox(height: 16),

          // ── Partner coupons ───────────────────────────────────────────────
          _card(
            child: DiscountCouponsSection(totalPoints: totalPoints),
          ),
          const SizedBox(height: 16),

          // ── Neighborhood leaderboard ──────────────────────────────────────
          _card(
            child: const NeighborhoodLeaderboardPreview(),
          ),
          const SizedBox(height: 16),

          // ── Transaction history ───────────────────────────────────────────
          if (transactions.isNotEmpty) ...[
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
            ...transactions.map((t) => _TransactionTile(transaction: t)),
          ] else
            Center(
              child: Column(
                children: [
                  const Icon(Icons.emoji_events_outlined,
                      size: 64, color: Color(0xFFD97706)),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.rewardsNoHistory,
                    style: GoogleFonts.cairo(
                        fontSize: 14, color: const Color(0xFF717973)),
                  ),
                ],
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

  Widget _buildBalanceCard(
    BuildContext context,
    String tierName,
    Color tierColor,
    double progress,
    int nextThreshold,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF06402B), Color(0xFF1E6B35)],
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.eco_rounded,
                        color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${_lifetimeKg.toStringAsFixed(0)} كغ',
                      style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Tier badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: tierColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  tierName,
                  style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: tierColor),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.emoji_events_rounded,
                  color: Color(0xFFFFC107), size: 28),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '$totalPoints',
            style: GoogleFonts.dmSans(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          Text(
            context.l10n.rewardsPointsLabel,
            style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFFFC107)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.rewardsProgressText(totalPoints, nextThreshold),
            style: GoogleFonts.cairo(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.7)),
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
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03), blurRadius: 4),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction.description,
                style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF002819)),
              ),
              Text(
                DateFormatter.relative(transaction.createdAt),
                style: GoogleFonts.cairo(
                    fontSize: 11, color: const Color(0xFF717973)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
