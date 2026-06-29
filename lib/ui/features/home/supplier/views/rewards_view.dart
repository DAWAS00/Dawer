import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../../../data/models/reward_transaction.dart';
import '../../../../../data/services/app_order_store.dart';
import '../../../../../domain/entities/green_level.dart';
import '../../../../../l10n/l10n.dart';

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

/// خُضَر Green Credits rewards screen — shared by driver and supplier.
///
/// Reads the live balance + transaction history from [AppOrderStore] for
/// [userId] and lets the user redeem credits for real rewards (balance is
/// deducted and a redemption transaction is recorded).
class RewardsView extends StatelessWidget {
  final String userId;

  const RewardsView({super.key, required this.userId});

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
        title: Text('تأكيد الاستبدال',
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
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
                backgroundColor: AppColors.primaryGreen),
            child: Text('استبدال',
                style: GoogleFonts.cairo(color: Colors.white)),
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(
        ok
            ? 'تم الاستبدال بنجاح 🎉 ${option.reward}'
            : 'رصيد خُضَر غير كافٍ',
        style: GoogleFonts.cairo(color: Colors.white),
      ),
      backgroundColor:
          ok ? const Color(0xFF166534) : const Color(0xFF991B1B),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppOrderStore>();
    final points = store.greenPointsFor(userId);
    final transactions = store.greenTransactionsFor(userId);
    final level = GreenLevelInfo.fromPoints(points);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        title: Text('مكافآت خُضَر',
            style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _BalanceCard(points: points, level: level),
          const SizedBox(height: 20),
          _buildRedemptionSection(context, points),
          const SizedBox(height: 20),
          Text(context.l10n.rewardsHistoryTitle,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002819))),
          const SizedBox(height: 12),
          if (transactions.isNotEmpty)
            ...transactions.map((t) => _TransactionTile(transaction: t))
          else
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.eco_outlined,
                        size: 64, color: AppColors.primaryGreen),
                    const SizedBox(height: 12),
                    Text(context.l10n.rewardsNoHistory,
                        style: GoogleFonts.cairo(
                            fontSize: 14, color: const Color(0xFF717973))),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRedemptionSection(BuildContext context, int points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('استبدل نقاط خُضَر',
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002819))),
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
                    onTap: affordable
                        ? () => _confirmRedeem(context, o)
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 8),
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
                              blurRadius: 6),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(o.icon,
                              color: AppColors.primaryGreen, size: 28),
                          const SizedBox(height: 6),
                          Text(o.title,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF002819))),
                          const SizedBox(height: 2),
                          Text(o.reward,
                              style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen)),
                          const SizedBox(height: 4),
                          Text('${o.cost} خُضَر',
                              style: GoogleFonts.cairo(
                                  fontSize: 10,
                                  color: const Color(0xFF717973))),
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
  const _BalanceCard({required this.points, required this.level});
  final int points;
  final GreenLevel level;

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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4)),
                ),
                child: Text('${level.emoji} ${level.arabicLabel}',
                    style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
              const Spacer(),
              const Icon(Icons.eco_rounded,
                  color: Color(0xFFB9F6CA), size: 28),
            ],
          ),
          const SizedBox(height: 16),
          Text('$points',
              style: GoogleFonts.dmSans(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          Text('خُضَر',
              style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8))),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFB9F6CA)),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            level.isMaxLevel
                ? 'وصلت لأعلى مستوى — حارس الغابة 🌍'
                : '$points / ${level.nextThreshold} للمستوى التالي',
            style: GoogleFonts.cairo(
                fontSize: 11, color: Colors.white.withValues(alpha: 0.75)),
          ),
          const SizedBox(height: 4),
          Text(level.unlockDescription,
              style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.6))),
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
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(transaction.description,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF002819))),
                Text(DateFormatter.relative(transaction.createdAt),
                    style: GoogleFonts.cairo(
                        fontSize: 11, color: const Color(0xFF717973))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
