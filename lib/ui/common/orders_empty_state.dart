import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_tokens.dart';

// ── Reference messages for callers ────────────────────────────────────────────
// Driver — المتاحة:    message='لا توجد طلبات متاحة حالياً',    icon=Icons.inbox_rounded
// Driver — النشطة:    message='لا توجد طلبات نشطة',             icon=Icons.pending_actions_rounded
// Driver — السجل:     message='لم تُكمل أي طلبات بعد',          icon=Icons.history_rounded
// Supplier — النشطة:  message='لا توجد طلبات نشطة',             icon=Icons.add_circle_outline_rounded
//                     subMessage='ابدأ طلباً جديداً من الصفحة الرئيسية'
// Supplier — السجل:   message='لا يوجد سجل طلبات بعد',          icon=Icons.history_rounded
// Company — incoming: message='لا توجد شحنات قادمة حالياً',      icon=Icons.local_shipping_outlined
// Company — jobs:     message='لم تنشر وظائف تجميع بعد',         icon=Icons.work_outline_rounded
//                     subMessage='انشر وظيفة من الصفحة الرئيسية'
// ─────────────────────────────────────────────────────────────────────────────

class OrdersEmptyState extends StatelessWidget {
  final String message;
  final String? subMessage;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const OrdersEmptyState({
    super.key,
    required this.message,
    this.subMessage,
    this.icon = Icons.inbox_rounded,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    assert(
      onAction == null || actionLabel != null,
      'actionLabel must be provided when onAction is set.',
    );
    final dt = context.dt;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: dt.onSurfaceMuted),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: dt.onSurfaceVariant,
              ),
            ),
            if (subMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                subMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: dt.onSurfaceMuted,
                ),
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF1E5C35)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(160, 44),
                ),
                child: Text(
                  actionLabel!,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E5C35),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
