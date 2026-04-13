import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../data/models/order.dart';

class MarketItemDeliveryAddressSheet extends StatefulWidget {
  final Order item;
  final void Function(String address, double deliveryFee) onConfirm;

  const MarketItemDeliveryAddressSheet({
    super.key,
    required this.item,
    required this.onConfirm,
  });

  @override
  State<MarketItemDeliveryAddressSheet> createState() => _MarketItemDeliveryAddressSheetState();
}

class _MarketItemDeliveryAddressSheetState extends State<MarketItemDeliveryAddressSheet> {
  double get _distanceFee => (widget.item.distanceKm ?? 5.0) * 0.2;

  double get _weightSurcharge => switch (widget.item.weightCategory) {
        WeightCategory.light => 0.0,
        WeightCategory.medium => 1.0,
        WeightCategory.heavy => 2.5,
        WeightCategory.veryHeavy => 5.0,
        null => 0.0,
      };

  double get _deliveryFee => 1.5 + _distanceFee + _weightSurcharge;
  double get _totalCost => (widget.item.itemPrice ?? 0) + _deliveryFee;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'تأكيد الشراء والتوصيل',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002819),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'رسوم التوصيل محسوبة حسب المسافة والوزن',
              style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF717973)),
            ),
            const SizedBox(height: 20),
            _addressTile(
              icon: Icons.storefront_rounded,
              bg: const Color(0xFF06402B).withValues(alpha: 0.08),
              color: const Color(0xFF06402B),
              label: 'موقع البائع',
              value: widget.item.pickupAddress,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.more_vert_rounded, color: Color(0xFFD1D5DB), size: 20),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06402B).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.item.distanceKm?.toStringAsFixed(1) ?? '–'} كم',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF06402B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.more_vert_rounded, color: Color(0xFFD1D5DB), size: 20),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('سيتم ربط خرائط جوجل قريباً', style: GoogleFonts.cairo()),
                  backgroundColor: const Color(0xFF1E5C35),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              child: _addressTile(
                icon: Icons.home_rounded,
                bg: const Color(0xFFFEF3C7),
                color: const Color(0xFFC8860A),
                label: 'عنوان التوصيل',
                value: 'اضغط لتحديد موقعك على الخريطة',
                isPlaceholder: true,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE6E9E7)),
              ),
              child: Column(
                children: [
                  _costRow('سعر المواد', '${widget.item.itemPrice?.toStringAsFixed(2) ?? '0.00'} د.أ'),
                  const SizedBox(height: 8),
                  _costRow('رسوم المسافة  (${widget.item.distanceKm?.toStringAsFixed(1) ?? '–'} كم × 0.2)', '${_distanceFee.toStringAsFixed(2)} د.أ'),
                  const SizedBox(height: 8),
                  _costRow('رسوم الوزن  (${widget.item.weightCategory?.shortLabel ?? '–'})', '${_weightSurcharge.toStringAsFixed(2)} د.أ'),
                  const SizedBox(height: 8),
                  _costRow('رسوم التوصيل الأساسية', '1.50 د.أ'),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                  _costRow('الإجمالي', '${_totalCost.toStringAsFixed(2)} د.أ', isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => widget.onConfirm('عنواني الحالي', _deliveryFee),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06402B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'تأكيد الشراء — ${_totalCost.toStringAsFixed(2)} د.أ',
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _addressTile({
    required IconData icon,
    required Color bg,
    required Color color,
    required String label,
    required String value,
    bool isPlaceholder = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isPlaceholder ? const Color(0xFFF9FAFB) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isPlaceholder ? const Color(0xFFE6E9E7) : Colors.transparent),
        boxShadow: isPlaceholder
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(label, style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF9CA3AF))),
              const SizedBox(height: 2),
              Text(
                value,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isPlaceholder ? const Color(0xFF9CA3AF) : const Color(0xFF002819),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: color),
          ),
        ],
      ),
    );
  }

  Widget _costRow(String label, String value, {bool isBold = false}) {
    return Row(
      children: [
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: isBold ? 18 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? const Color(0xFF06402B) : const Color(0xFF404943),
          ),
        ),
        const Spacer(),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? const Color(0xFF002819) : const Color(0xFF717973),
          ),
        ),
      ],
    );
  }
}
