import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../data/models/order/order.dart';

/// Bottom sheet that lets a buyer reserve a marketplace item for pickup
/// on a date they choose (3–7 days from today), paying a 10 % deposit.
class MarketItemReserveSheet extends StatefulWidget {
  final Order item;
  final double walletBalance;

  /// Called when the user confirms — receives the chosen pickup date.
  final void Function(DateTime pickupDate) onConfirm;

  const MarketItemReserveSheet({
    super.key,
    required this.item,
    required this.walletBalance,
    required this.onConfirm,
  });

  @override
  State<MarketItemReserveSheet> createState() => _MarketItemReserveSheetState();
}

class _MarketItemReserveSheetState extends State<MarketItemReserveSheet> {
  static const double _depositPct = 0.10;
  static const int _minDays = 3;
  static const int _maxDays = 7;

  late int _selectedDaysFromNow;

  @override
  void initState() {
    super.initState();
    _selectedDaysFromNow = _minDays;
  }

  DateTime get _pickupDate =>
      DateTime.now().add(Duration(days: _selectedDaysFromNow));

  double get _depositAmount => (widget.item.itemPrice ?? 0) * _depositPct;

  bool get _canAfford => widget.walletBalance >= _depositAmount;

  String _formatDate(DateTime dt) {
    const months = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              'حجز العنصر',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002819),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'احجز هذا العنصر الآن بدفع ١٠٪ من قيمته كتأمين قابل للاسترداد.',
              style: GoogleFonts.cairo(
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.right,
            ),

            const SizedBox(height: 20),

            // Item summary
            _InfoRow(
              label: 'قيمة العنصر',
              value: widget.item.itemPrice != null
                  ? '${widget.item.itemPrice!.toStringAsFixed(2)} د.أ'
                  : 'غير محدد',
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'مبلغ التأمين (١٠٪)',
              value: '${_depositAmount.toStringAsFixed(2)} د.أ',
              valueColor: const Color(0xFF1E5C35),
              bold: true,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'رصيد المحفظة',
              value: '${widget.walletBalance.toStringAsFixed(2)} د.أ',
              valueColor: _canAfford ? null : const Color(0xFFDC2626),
            ),

            if (!_canAfford) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFCA5A5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'رصيدك غير كافٍ لدفع مبلغ التأمين',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: const Color(0xFFDC2626),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFDC2626),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
            const Divider(color: Color(0xFFE5E7EB)),
            const SizedBox(height: 16),

            // Date picker
            Text(
              'اختر موعد الاستلام',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002819),
              ),
            ),
            const SizedBox(height: 10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_maxDays - _minDays + 1, (i) {
                final days = _minDays + i;
                final date = DateTime.now().add(Duration(days: days));
                final selected = days == _selectedDaysFromNow;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDaysFromNow = days),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 44,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF06402B)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF06402B)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _dayName(date.weekday),
                            style: GoogleFonts.cairo(
                              fontSize: 10,
                              color: selected
                                  ? Colors.white70
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                          Text(
                            '${date.day}',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF002819),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 10),
            Center(
              child: Text(
                'موعد الاستلام: ${_formatDate(_pickupDate)}',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: const Color(0xFF374151),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Fraud warning
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      'إذا ألغيت الحجز بعد قبول البائع، يُصادَر مبلغ التأمين لصالحه. وينطبق الأمر ذاته على البائع إذا ألغى من طرفه.',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: const Color(0xFF92400E),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFFD97706),
                    size: 16,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Confirm button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _canAfford
                    ? () {
                        Navigator.pop(context);
                        widget.onConfirm(_pickupDate);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06402B),
                  disabledBackgroundColor: const Color(0xFFD1D5DB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _canAfford
                        ? 'تأكيد الحجز — ${_depositAmount.toStringAsFixed(2)} د.أ'
                        : 'رصيد غير كافٍ',
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _dayName(int weekday) {
    const names = [
      '',
      'إثنين',
      'ثلاثاء',
      'أربعاء',
      'خميس',
      'جمعة',
      'سبت',
      'أحد',
    ];
    return names[weekday];
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final bool bold;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? const Color(0xFF002819),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
