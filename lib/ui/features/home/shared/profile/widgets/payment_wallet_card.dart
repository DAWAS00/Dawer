import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../core/constants/app_colors.dart';

/// Government payment portal — منصة فواتيركم (eFawateercom), operated by the
/// Central Bank of Jordan. All government-adjacent services in Jordan collect
/// and pay fees through this gateway.
///
/// At the UI layer this is a web deep-link; once Dwaar is registered as a
/// biller with the CBJ this URL gains a biller code for a seamless flow.
const String _efawateercomUrl = 'https://www.efawateercom.jo/';

Future<void> _openEfawateercom() async {
  final uri = Uri.parse(_efawateercomUrl);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// Role-aware payment / wallet section on the profile page.
///
/// Three variants via named constructors:
/// - [PaymentWalletCard.driver]   — balance + held funds + withdraw CTA
/// - [PaymentWalletCard.supplier] — reward points + progress to next tier
/// - [PaymentWalletCard.company]  — current billing period summary
///
/// Every variant ends with the shared eFawateercom government-payment row.
class PaymentWalletCard extends StatelessWidget {
  const PaymentWalletCard._({
    required this.title,
    required this.icon,
    required this.body,
  });

  final String title;
  final IconData icon;
  final Widget body;

  /// Driver wallet: available balance + escrow-held funds.
  factory PaymentWalletCard.driver({
    required double balance,
    required double heldAmount,
    VoidCallback? onWithdraw,
  }) {
    return PaymentWalletCard._(
      title: 'محفظتي',
      icon: Icons.account_balance_wallet_rounded,
      body: _DriverBody(
        balance: balance,
        heldAmount: heldAmount,
        onWithdraw: onWithdraw,
      ),
    );
  }

  /// Supplier rewards: points balance + progress toward the next tier.
  factory PaymentWalletCard.supplier({
    required int points,
    VoidCallback? onViewRewards,
  }) {
    return PaymentWalletCard._(
      title: 'نقاطي ومكافآتي',
      icon: Icons.emoji_events_rounded,
      body: _SupplierBody(points: points, onViewRewards: onViewRewards),
    );
  }

  /// Recycling company: current billing-period throughput summary.
  factory PaymentWalletCard.company({
    required String periodLabel,
    required int shipments,
    required String weightLabel,
    VoidCallback? onViewInvoice,
  }) {
    return PaymentWalletCard._(
      title: 'الفوترة والمدفوعات',
      icon: Icons.receipt_long_rounded,
      body: _CompanyBody(
        periodLabel: periodLabel,
        shipments: shipments,
        weightLabel: weightLabel,
        onViewInvoice: onViewInvoice,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: isDark
            ? Border.all(color: theme.colorScheme.outline)
            : Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Card title row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Icon(icon, size: 20, color: theme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: body,
          ),
          // Divider + government payment row
          Divider(height: 1, color: theme.dividerColor),
          _EfawateercomRow(),
        ],
      ),
    );
  }
}

// ── Driver body ───────────────────────────────────────────────────────────────

class _DriverBody extends StatelessWidget {
  const _DriverBody({
    required this.balance,
    required this.heldAmount,
    this.onWithdraw,
  });

  final double balance;
  final double heldAmount;
  final VoidCallback? onWithdraw;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _AmountColumn(
                label: 'الرصيد المتاح',
                amount: balance,
                emphasize: true,
              ),
            ),
            Container(width: 1, height: 36, color: theme.dividerColor),
            Expanded(
              child: _AmountColumn(
                label: 'المحجوز',
                amount: heldAmount,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onWithdraw,
            icon: const Icon(Icons.payments_rounded, size: 20),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            label: Text(
              'طلب صرف رصيد',
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AmountColumn extends StatelessWidget {
  const _AmountColumn({
    required this.label,
    required this.amount,
    this.emphasize = false,
  });

  final String label;
  final double amount;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '${amount.toStringAsFixed(2)} د.أ',
            textDirection: TextDirection.ltr,
            style: GoogleFonts.dmSans(
              fontSize: emphasize ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: emphasize
                  ? AppColors.primaryGreen
                  : theme.textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Supplier body ───────────────────────────────────────────────────────────────

class _SupplierBody extends StatelessWidget {
  const _SupplierBody({required this.points, this.onViewRewards});

  final int points;
  final VoidCallback? onViewRewards;

  static const int _tierStep = 500;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final intoTier = points % _tierStep;
    final progress = intoTier / _tierStep;
    final remaining = _tierStep - intoTier;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$points',
              style: GoogleFonts.dmSans(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.accentAmber,
              ),
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'نقطة',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.accentAmber.withValues(alpha: 0.15),
            valueColor: const AlwaysStoppedAnimation(AppColors.accentAmber),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'تبقّى $remaining نقطة للمكافأة القادمة',
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onViewRewards,
            icon: const Icon(Icons.card_giftcard_rounded, size: 20),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accentAmber,
              side: const BorderSide(color: AppColors.accentAmber),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            label: Text(
              'عرض المكافآت',
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Company body ───────────────────────────────────────────────────────────────

class _CompanyBody extends StatelessWidget {
  const _CompanyBody({
    required this.periodLabel,
    required this.shipments,
    required this.weightLabel,
    this.onViewInvoice,
  });

  final String periodLabel;
  final int shipments;
  final String weightLabel;
  final VoidCallback? onViewInvoice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'الفترة الحالية:',
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              periodLabel,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MiniStat(
                value: '$shipments',
                label: 'الشحنات',
              ),
            ),
            Container(width: 1, height: 32, color: theme.dividerColor),
            Expanded(
              child: _MiniStat(
                value: weightLabel,
                label: 'الوزن (كغ)',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onViewInvoice,
            icon: const Icon(Icons.description_rounded, size: 20),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.primaryColor,
              side: BorderSide(color: theme.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            label: Text(
              'عرض الفاتورة',
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.textTheme.bodyLarge?.color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }
}

// ── eFawateercom government payment row ──────────────────────────────────────────

class _EfawateercomRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openEfawateercom,
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.efawateerTealBg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.account_balance_rounded,
                size: 20,
                color: AppColors.efawateerTeal,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الدفع عبر فواتيركم',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.efawateerTeal,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'منصة الدفع الإلكتروني الحكومية',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.open_in_new_rounded,
              size: 16,
              color: AppColors.efawateerTeal,
            ),
          ],
        ),
      ),
    );
  }
}
