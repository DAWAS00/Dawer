part of '../order_form_view.dart';

extension _Step2Ext on _OrderFormViewState {
  Widget _buildStep2(OrderFormViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLocationCard(vm),
          _buildModeSelectorCard(vm),
          if (vm.mode == OrderMode.pickup) _buildPickupTargetCard(vm),
          _buildNotesCard(vm),
        ],
      ),
    );
  }

  // ── Location ──────────────────────────────────────────────────────────────

  Widget _buildLocationCard(OrderFormViewModel vm) {
    return _SectionCard(
      title: 'موقع الاستلام *',
      hasError: vm.errors.containsKey('location'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Semantics(
          label: vm.hasLocation ? vm.addressLabel : 'تحديد الموقع على الخريطة، اضغط لفتح',
          button: true,
          child: GestureDetector(
            onTap: () => _pickLocation(vm),
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
                    color: vm.hasLocation
                        ? const Color(0xFF06402B).withValues(alpha: 0.1)
                        : const Color(0xFFE6E9E7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    vm.hasLocation ? Icons.check_circle_rounded : Icons.location_on_rounded,
                    size: 20,
                    color: vm.hasLocation ? const Color(0xFF06402B) : const Color(0xFF717973),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    if (vm.resolvingAddress)
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                        Text('جارٍ تحديد العنوان...', textAlign: TextAlign.right,
                            style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF717973))),
                        const SizedBox(width: 6),
                        const SizedBox(width: 10, height: 10,
                            child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFF06402B))),
                      ])
                    else
                      Text(
                        vm.hasLocation ? vm.addressLabel : 'تحديد الموقع على الخريطة',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.cairo(
                          fontSize: vm.hasLocation ? 12 : 14,
                          fontWeight: vm.hasLocation ? FontWeight.w600 : FontWeight.bold,
                          color: vm.hasLocation ? const Color(0xFF404943) : const Color(0xFF002819),
                        ),
                      ),
                    if (!vm.hasLocation && !vm.resolvingAddress)
                      Text('اضغط لفتح الخريطة',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF717973))),
                  ]),
                ),
              ]),
            ),
          ),
        ),
        if (vm.errors.containsKey('location'))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(vm.errors['location']!,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.red)),
          ),
      ]),
    );
  }

  Future<void> _pickLocation(OrderFormViewModel vm) async {
    final result = await Navigator.push<(double, double)?>(
      context,
      MaterialPageRoute(builder: (_) => LocationPickerScreen(
          initialLat: vm.pickupLat, initialLng: vm.pickupLng)),
    );
    if (result == null || !mounted) return;
    vm.setLocation(result.$1, result.$2);
    final address = await _locationService.reverseGeocode(result.$1, result.$2);
    if (mounted) vm.setAddress(address);
  }

  // ── Mode selector ─────────────────────────────────────────────────────────

  Widget _buildModeSelectorCard(OrderFormViewModel vm) {
    final isMarket = vm.mode == OrderMode.marketplace;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMarket
              ? const Color(0xFF1E40AF).withValues(alpha: 0.4)
              : const Color(0xFFE6E9E7),
        ),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Row(children: [
        Switch.adaptive(
          value: isMarket,
          onChanged: (v) =>
              vm.setMode(v ? OrderMode.marketplace : OrderMode.pickup),
          activeTrackColor: const Color(0xFF1E40AF),
          activeThumbColor: Colors.white,
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'مشاركة في السوق',
              style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002819)),
            ),
            Text(
              'نشر الطلب في السوق للمشترين',
              style: GoogleFonts.cairo(
                  fontSize: 11, color: const Color(0xFF9CA3AF)),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Icon(
          Icons.storefront_rounded,
          size: 22,
          color: isMarket
              ? const Color(0xFF1E40AF)
              : const Color(0xFF9CA3AF),
        ),
      ]),
    );
  }

  // ── Pickup Target ─────────────────────────────────────────────────────────

  Widget _buildPickupTargetCard(OrderFormViewModel vm) {
    return _SectionCard(
      title: 'وجهة المخلفات',
      child: Row(
        children: PickupTarget.values.reversed.map((target) {
          final sel = vm.pickupTarget == target;
          final icon = target == PickupTarget.company
              ? Icons.business_rounded
              : Icons.delivery_dining_rounded;
          final label = target == PickupTarget.company ? 'للشركة' : 'للسائق';
          return Expanded(
            child: GestureDetector(
              onTap: () => vm.setPickupTarget(target),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: EdgeInsets.only(left: target == PickupTarget.riderBuy ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color: sel ? const Color(0xFF06402B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: sel ? const Color(0xFF06402B) : const Color(0xFFE6E9E7),
                      width: sel ? 2 : 1),
                ),
                child: Column(children: [
                  Icon(icon, size: 28, color: sel ? Colors.white : const Color(0xFF717973)),
                  const SizedBox(height: 8),
                  Text(label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold,
                          color: sel ? Colors.white : const Color(0xFF404943))),
                  if (sel)
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

  // ── Notes ─────────────────────────────────────────────────────────────────

  Widget _buildNotesCard(OrderFormViewModel vm) {
    return _SectionCard(
      title: 'ملاحظات',
      child: Container(
        decoration: BoxDecoration(
            color: const Color(0xFFF2F4F2), borderRadius: BorderRadius.circular(14)),
        child: TextField(
          controller: vm.notesCtrl,
          maxLines: 3,
          maxLength: 300,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF191C1B)),
          decoration: InputDecoration(
            hintText: 'مثال: الكميّة تقريباً ٢٠ كيس بلاستيك...',
            hintStyle: GoogleFonts.cairo(fontSize: 13,
                color: const Color(0xFF6B7280).withValues(alpha: 0.5)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(14),
            counterStyle: GoogleFonts.cairo(fontSize: 10, color: const Color(0xFF9CA3AF)),
          ),
        ),
      ),
    );
  }
}

