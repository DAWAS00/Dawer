import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/services/eco_points_engine.dart';

/// Displays the driver's accumulated fuel credit and voucher milestones.
/// Drivers earn [EcoPointsEngine.fuelCreditPerDelivery] JOD per delivery.
class DriverFuelVoucherWidget extends StatelessWidget {
  final int completedDeliveries;

  const DriverFuelVoucherWidget({
    super.key,
    required this.completedDeliveries,
  });

  static const _milestones = [
    (20, 'FUEL1JD',  '1 دينار'),
    (60, 'FUEL3JD',  '3 دينار'),
    (100,'FUEL5JD',  '5 دينار'),
    (200,'FUEL10JD', '10 دينار'),
  ];

  @override
  Widget build(BuildContext context) {
    final credit = EcoPointsEngine.driverFuelCredit(completedDeliveries);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              const Text('⛽', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                'كوبونات الوقود',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${EcoPointsEngine.fuelCreditPerDelivery * 100 ~/ 1} فلس/رحلة',
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.90),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                credit.toStringAsFixed(2),
                style: GoogleFonts.dmSans(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'دينار',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.80),
                  ),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$completedDeliveries رحلة مكتملة',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.80),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          Text(
            'مراحل الكوبون',
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.80),
            ),
          ),
          const SizedBox(height: 10),
          ..._milestones.map((m) => _MilestoneTile(
                deliveriesRequired: m.$1,
                code: m.$2,
                label: m.$3,
                completed: completedDeliveries,
              )),
        ],
      ),
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  final int deliveriesRequired;
  final String code;
  final String label;
  final int completed;

  const _MilestoneTile({
    required this.deliveriesRequired,
    required this.code,
    required this.label,
    required this.completed,
  });

  bool get isUnlocked => completed >= deliveriesRequired;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          if (isUnlocked)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم نسخ الكود: $code',
                      style: GoogleFonts.cairo(),
                      textAlign: TextAlign.right,
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: const Color(0xFF1E5C35),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.copy_rounded,
                        size: 12, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      code,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Text(
              '$deliveriesRequired رحلة',
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          const Spacer(),
          Icon(
            isUnlocked
                ? Icons.check_circle_rounded
                : Icons.lock_outline_rounded,
            size: 16,
            color: isUnlocked
                ? const Color(0xFF86EFAC)
                : Colors.white.withValues(alpha: 0.40),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isUnlocked
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.50),
            ),
          ),
        ],
      ),
    );
  }
}
