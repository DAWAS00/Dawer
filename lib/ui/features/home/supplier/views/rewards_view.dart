import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../data/models/reward_transaction.dart';

/// Phase 10 — Rewards Redemption UI.
/// Shows the supplier's points balance, progress to next tier,
/// and a history of reward transactions.
class RewardsView extends StatelessWidget {
  final int totalPoints;
  final List<RewardTransaction> transactions;

  const RewardsView({
    super.key,
    required this.totalPoints,
    this.transactions = const [],
  });

  static const _tiers = [
    (0, 'برونزي', Color(0xFFB45309)),
    (100, 'فضي', Color(0xFF6B7280)),
    (300, 'ذهبي', Color(0xFFD97706)),
    (600, 'بلاتيني', Color(0xFF1E40AF)),
  ];

  (String, Color, int) get _currentTier {
    for (int i = _tiers.length - 1; i >= 0; i--) {
      if (totalPoints >= _tiers[i].$1) {
        return (_tiers[i].$2, _tiers[i].$3, _tiers[i].$1);
      }
    }
    return (_tiers[0].$2, _tiers[0].$3, _tiers[0].$1);
  }

  int get _nextTierThreshold {
    for (final tier in _tiers) {
      if (totalPoints < tier.$1) return tier.$1;
    }
    return _tiers.last.$1;
  }

  @override
  Widget build(BuildContext context) {
    final (tierName, tierColor, tierStart) = _currentTier;
    final nextThreshold = _nextTierThreshold;
    final progress = nextThreshold > tierStart
        ? (totalPoints - tierStart) / (nextThreshold - tierStart)
        : 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF06402B),
        foregroundColor: Colors.white,
        title: Text('مكافآتي',
            style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildBalanceCard(tierName, tierColor, progress, nextThreshold),
          const SizedBox(height: 20),
          _buildRedemptionSection(context),
          const SizedBox(height: 20),
          if (transactions.isNotEmpty) ...[
            Text('سجل المكافآت',
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF002819))),
            const SizedBox(height: 12),
            ...transactions.map((t) => _TransactionTile(transaction: t)),
          ] else
            Center(
              child: Column(
                children: [
                  const Icon(Icons.emoji_events_outlined,
                      size: 64, color: Color(0xFFD97706)),
                  const SizedBox(height: 12),
                  Text('لا يوجد سجل مكافآت بعد',
                      style: GoogleFonts.cairo(
                          fontSize: 14, color: const Color(0xFF717973))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(
      String tierName, Color tierColor, double progress, int nextThreshold) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF06402B), const Color(0xFF1E6B35)],
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: tierColor.withValues(alpha: 0.5)),
                ),
                child: Text(tierName,
                    style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: tierColor)),
              ),
              const Spacer(),
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
          Text('نقطة',
              style: GoogleFonts.cairo(
                  fontSize: 14, color: Colors.white.withValues(alpha: 0.8))),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFFFC107)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalPoints / $nextThreshold نقطة للمستوى التالي',
            style: GoogleFonts.cairo(
                fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
          ),
        ],
      ),
    );
  }

  Widget _buildRedemptionSection(BuildContext context) {
    const options = [
      (Icons.discount_rounded, 'خصم على الطلبات', '50 نقطة'),
      (Icons.card_giftcard_rounded, 'كرت هدية', '100 نقطة'),
      (Icons.local_shipping_rounded, 'توصيل مجاني', '30 نقطة'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('استبدل نقاطك',
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002819))),
        const SizedBox(height: 12),
        Row(
          children: options.map((o) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('هذه الميزة قريباً!',
                          style: GoogleFonts.cairo()),
                      behavior: SnackBarBehavior.floating,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(o.$1, color: const Color(0xFF06402B), size: 28),
                        const SizedBox(height: 6),
                        Text(o.$2,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF002819))),
                        const SizedBox(height: 2),
                        Text(o.$3,
                            style: GoogleFonts.cairo(
                                fontSize: 10, color: const Color(0xFF717973))),
                      ],
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
              Text(transaction.description,
                  style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF002819))),
              Text(DateFormatter.relative(transaction.createdAt),
                  style: GoogleFonts.cairo(
                      fontSize: 11, color: const Color(0xFF717973))),
            ],
          ),
        ],
      ),
    );
  }
}
