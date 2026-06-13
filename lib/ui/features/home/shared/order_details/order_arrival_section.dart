import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/order/order.dart';

/// Shown in order details for:
///   - Driver in `accepted` state   → "I'm Here — Pickup" button
///   - Driver in `arrivedAtPickup`  → "Awaiting supplier" banner
///   - Driver in `inTransit` state  → "I'm Here — Dropoff" button
///   - Supplier in `arrivedAtPickup`→ "Driver arrived" card with confirm buttons
class OrderArrivalSection extends StatefulWidget {
  final Order order;
  final Future<String?> Function(Order)? onMarkArrivedAtPickup;
  final Future<String?> Function(Order)? onMarkArrivedAtDropoff;
  final void Function(bool available)? onSupplierConfirmArrival;

  const OrderArrivalSection({
    super.key,
    required this.order,
    this.onMarkArrivedAtPickup,
    this.onMarkArrivedAtDropoff,
    this.onSupplierConfirmArrival,
  });

  @override
  State<OrderArrivalSection> createState() => _OrderArrivalSectionState();
}

class _OrderArrivalSectionState extends State<OrderArrivalSection> {
  bool _loading = false;

  bool get _isDriverView =>
      widget.onMarkArrivedAtPickup != null ||
      widget.onMarkArrivedAtDropoff != null;

  Future<void> _tap(Future<String?> Function(Order) cb) async {
    setState(() => _loading = true);
    try {
      final error = await cb(widget.order);
      if (error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error, style: GoogleFonts.cairo(color: Colors.white)),
          backgroundColor: const Color(0xFF991B1B),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.order.status;

    if (_isDriverView) {
      if (s == OrderStatus.accepted && widget.onMarkArrivedAtPickup != null) {
        return _ArrivalCard(
          icon: Icons.location_on_rounded,
          iconColor: const Color(0xFF06402B),
          iconBg: const Color(0xFFD1FAE5),
          borderColor: const Color(0xFF06402B),
          title: 'وصلت إلى موقع الاستلام؟',
          subtitle: 'سيتم التحقق من موقعك (ضمن 200 م)',
          buttonLabel: 'أنا هنا — الاستلام',
          buttonColor: const Color(0xFF06402B),
          loading: _loading,
          onTap: () => _tap(widget.onMarkArrivedAtPickup!),
        );
      }
      if (s == OrderStatus.arrivedAtPickup) {
        return _AwaitingBanner();
      }
      if (s == OrderStatus.inTransit && widget.onMarkArrivedAtDropoff != null) {
        return _ArrivalCard(
          icon: Icons.flag_rounded,
          iconColor: const Color(0xFF1E40AF),
          iconBg: const Color(0xFFDBEAFE),
          borderColor: const Color(0xFF1E40AF),
          title: 'وصلت إلى موقع التسليم؟',
          subtitle: 'سيتم التحقق من موقعك (ضمن 200 م)',
          buttonLabel: 'أنا هنا — التسليم',
          buttonColor: const Color(0xFF1E40AF),
          loading: _loading,
          onTap: () => _tap(widget.onMarkArrivedAtDropoff!),
        );
      }
    } else {
      if (s == OrderStatus.arrivedAtPickup &&
          widget.onSupplierConfirmArrival != null) {
        return _SupplierConfirmCard(
          onConfirm: widget.onSupplierConfirmArrival!,
        );
      }
    }

    return const SizedBox.shrink();
  }
}

// ── Reusable card shell ───────────────────────────────────────────────────────

class _ArrivalCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color borderColor;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final Color buttonColor;
  final bool loading;
  final VoidCallback onTap;

  const _ArrivalCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.borderColor,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.buttonColor,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Spacer(),
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002819),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF717973)),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                disabledBackgroundColor: buttonColor.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                minimumSize: const Size(double.infinity, 56),
              ),
              child: loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      buttonLabel,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Driver awaiting banner ────────────────────────────────────────────────────

class _AwaitingBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'في انتظار تأكيد المورد',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF92400E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'المورد لديه 5 دقائق للرد — سيُعوَّض السائق تلقائياً عند انتهاء المهلة',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: const Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                color: Color(0xFF92400E),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Supplier confirmation card ────────────────────────────────────────────────

class _SupplierConfirmCard extends StatelessWidget {
  final void Function(bool available) onConfirm;
  const _SupplierConfirmCard({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'السائق وصل!',
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002819),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFD1FAE5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: Color(0xFF06402B),
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'السائق في موقعك الآن. هل أنت متاح لتسليم المواد؟',
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: const Color(0xFF404943),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => onConfirm(false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF991B1B),
                    side: const BorderSide(color: Color(0xFF991B1B)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(0, 56),
                  ),
                  child: Text(
                    'غير متاح',
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => onConfirm(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06402B),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    minimumSize: const Size(0, 56),
                  ),
                  child: Text(
                    'أنا متاح',
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
