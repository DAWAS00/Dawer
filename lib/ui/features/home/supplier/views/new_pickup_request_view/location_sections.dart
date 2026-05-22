part of '../new_pickup_request_view.dart';

extension _LocationSectionsExt on _NewPickupRequestViewState {
  // ── Section 4: Location ───────────────────────────────────────────────────

  Widget _buildSection4Location() {
    final hasLocation = _pickedLat != null && _pickedLng != null;
    return _SectionCard(
      title: 'موقع الاستلام *',
      child: GestureDetector(
        onTap: _pickLocation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE6E9E7)),
          ),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: hasLocation
                    ? const Color(0xFF06402B).withValues(alpha: 0.1)
                    : const Color(0xFFE6E9E7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                hasLocation ? Icons.check_circle_rounded : Icons.location_on_rounded,
                size: 20,
                color: hasLocation ? const Color(0xFF06402B) : const Color(0xFF717973),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                if (_resolvingAddress)
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text('جارٍ تحديد العنوان...', textAlign: TextAlign.right,
                        style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF717973))),
                    const SizedBox(width: 6),
                    const SizedBox(width: 10, height: 10,
                        child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF06402B))),
                  ])
                else
                  Text(
                    hasLocation ? _pickupAddressLabel : 'تحديد الموقع على الخريطة',
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(
                      fontSize: hasLocation ? 12 : 14,
                      fontWeight: hasLocation ? FontWeight.w600 : FontWeight.bold,
                      color: hasLocation ? const Color(0xFF404943) : const Color(0xFF002819),
                    ),
                  ),
                if (!hasLocation && !_resolvingAddress)
                  Text('اضغط لفتح الخريطة', textAlign: TextAlign.right,
                      style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF717973))),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Section 5: Pickup target (pickup mode only) ───────────────────────────

  Widget _buildSection5PickupTarget() {
    return _SectionCard(
      title: 'وجهة المخلفات *',
      child: Row(
        children: PickupTarget.values.reversed.map((target) {
          final isSelected = _pickupTarget == target;
          final icon = target == PickupTarget.company
              ? Icons.business_rounded
              : Icons.delivery_dining_rounded;
          return Expanded(
            child: GestureDetector(
              onTap: () => _updateState(() => _pickupTarget = target),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: EdgeInsets.only(left: target == PickupTarget.riderBuy ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF06402B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF06402B) : const Color(0xFFE6E9E7),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(children: [
                  Icon(icon, size: 28,
                      color: isSelected ? Colors.white : const Color(0xFF717973)),
                  const SizedBox(height: 8),
                  Text(target.label, textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF404943))),
                  if (isSelected)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Icon(Icons.check_circle_rounded,
                          color: Colors.white.withValues(alpha: 0.8), size: 18),
                    ),
                ]),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Section 6: Price ──────────────────────────────────────────────────────

  Widget _buildSection6Price() {
    final subtitle = _mode == _OrderMode.marketplace
        ? 'السعر الذي تطلبه للمواد في السوق'
        : _pickupTarget == PickupTarget.riderBuy
            ? 'السعر الذي تريده مقابل بيع المواد للسائق'
            : 'السعر الذي تريده مقابل بيع المواد للشركة';
    return _SectionCard(
      title: 'سعر المواد',
      subtitle: subtitle,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F2), borderRadius: BorderRadius.circular(14)),
        child: TextField(
          controller: _priceCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold,
              color: const Color(0xFF191C1B)),
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: GoogleFonts.dmSans(fontSize: 16,
                color: const Color(0xFF6B7280).withValues(alpha: 0.4)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Text('د.أ',
                  style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold,
                      color: const Color(0xFF717973))),
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            prefixIcon: Icon(
              _mode == _OrderMode.marketplace
                  ? Icons.storefront_rounded
                  : _pickupTarget == PickupTarget.riderBuy
                      ? Icons.sell_rounded
                      : Icons.storefront_rounded,
              color: const Color(0xFF717973), size: 20,
            ),
          ),
        ),
      ),
    );
  }

  // ── Section 7: Notes ──────────────────────────────────────────────────────

  Widget _buildSection7Notes() {
    return _SectionCard(
      title: 'ملاحظات',
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F2), borderRadius: BorderRadius.circular(14)),
        child: TextField(
          controller: _notesCtrl,
          maxLines: 3,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF191C1B)),
          decoration: InputDecoration(
            hintText: 'مثال: الكميّة تقريباً ٢٠ كيس بلاستيك...',
            hintStyle: GoogleFonts.cairo(fontSize: 13,
                color: const Color(0xFF6B7280).withValues(alpha: 0.5)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ),
    );
  }
}
