import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/order.dart';

/// Bottom sheet shown to the supplier after an order is completed,
/// letting them rate the driver 1–5 stars.
///
/// Usage:
/// ```dart
/// RateDriverSheet.show(context, order: order, onSubmit: (rating) {
///   store.submitDriverRating(order.id, rating);
/// });
/// ```
class RateDriverSheet extends StatefulWidget {
  final Order order;
  final ValueChanged<double> onSubmit;

  const RateDriverSheet({
    super.key,
    required this.order,
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    required Order order,
    required ValueChanged<double> onSubmit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RateDriverSheet(order: order, onSubmit: onSubmit),
    );
  }

  @override
  State<RateDriverSheet> createState() => _RateDriverSheetState();
}

class _RateDriverSheetState extends State<RateDriverSheet> {
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E6E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFF1E5C35).withValues(alpha: 0.1),
            child: const Icon(Icons.person_rounded,
                size: 36, color: Color(0xFF1E5C35)),
          ),
          const SizedBox(height: 12),
          Text(
            widget.order.driverName ?? 'السائق',
            style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002819)),
          ),
          const SizedBox(height: 4),
          Text(
            'كيف كانت تجربتك مع السائق؟',
            style: GoogleFonts.cairo(
                fontSize: 13, color: const Color(0xFF717973)),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final filled = i < _rating;
              return GestureDetector(
                onTap: () => setState(() => _rating = (i + 1).toDouble()),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_border_rounded,
                    color: const Color(0xFFFFC107),
                    size: 40,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _rating == 0
                ? 'اختر تقييمك'
                : _rating <= 2
                    ? 'سيئ'
                    : _rating == 3
                        ? 'متوسط'
                        : _rating == 4
                            ? 'جيد'
                            : 'ممتاز',
            style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E5C35)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _rating == 0
                  ? null
                  : () {
                      widget.onSubmit(_rating);
                      Navigator.of(context).pop();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06402B),
                disabledBackgroundColor:
                    const Color(0xFF06402B).withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('إرسال التقييم',
                  style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('تخطّ',
                style:
                    GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF9099A2))),
          ),
        ],
      ),
    );
  }
}
