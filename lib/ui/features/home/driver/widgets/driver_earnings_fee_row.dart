import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dwaar/l10n/l10n.dart';
import '../viewmodels/driver_earnings_viewmodel.dart';

class DriverEarningsFeeRow extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const DriverEarningsFeeRow({
    super.key,
    required this.label,
    required this.amount,
    this.color = const Color(0xFF404943),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            '${amount.toStringAsFixed(2)} ${context.l10n.currencyJodShort}',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819),
            ),
          ),
          const Spacer(),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class DriverEarningsFinancialsCard extends StatelessWidget {
  final EarningsFinancials financials;

  const DriverEarningsFinancialsCard({super.key, required this.financials});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            l10n.earningsFinancialDetails,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819),
            ),
          ),
          const SizedBox(height: 16),
          DriverEarningsFeeRow(label: l10n.orderBaseFee, amount: financials.baseFee),
          DriverEarningsFeeRow(label: l10n.earningsDistanceFees, amount: financials.distanceFee),
          DriverEarningsFeeRow(label: l10n.orderMaterialFee, amount: financials.materialFee),
          DriverEarningsFeeRow(label: l10n.orderUrgencyFee, amount: financials.urgencyFee),
          const Divider(height: 24, thickness: 1, color: Color(0xFFE6E9E7)),
          Row(
            children: [
              Text(
                '${financials.total.toStringAsFixed(2)} ${l10n.currencyJodShort}',
                style: GoogleFonts.dmSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF0A5E3E),
                ),
              ),
              const Spacer(),
              Text(
                l10n.earningsNetTotalLabel,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002819),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
