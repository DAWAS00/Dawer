part of '../order_form_view.dart';

extension _Step3Ext on _OrderFormViewState {
  Widget _buildStep3(OrderFormViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (vm.isRestaurant) _buildEstablishmentCard(vm),
          _buildPricingCard(vm),
          _buildReviewSummaryCard(vm),
        ],
      ),
    );
  }

  // ── Establishment (restaurant only) ───────────────────────────────────────

  Widget _buildEstablishmentCard(OrderFormViewModel vm) {
    return _SectionCard(
      title: 'بيانات المنشأة',
      subtitle: 'هذه الحقول خاصة بالمطاعم والمنشآت التجارية',
      hasError: vm.errors.containsKey('establishment'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _styledField(
          controller: vm.establishmentCtrl,
          hint: 'مثال: مطعم الزيتونة',
          label: 'اسم المنشأة *',
          icon: Icons.business_rounded,
          keyboardType: TextInputType.text,
          maxLength: 60,
        ),
        if (vm.errors.containsKey('establishment'))
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 4),
            child: Text(vm.errors['establishment']!,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.red)),
          ),
        const SizedBox(height: 12),
        _styledField(
          controller: vm.contactCtrl,
          hint: '07XXXXXXXX',
          label: 'رقم التواصل (اختياري)',
          icon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
        ),
      ]),
    );
  }

  Widget _styledField({
    required TextEditingController controller,
    required String hint,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextDirection textDirection = TextDirection.rtl,
    TextAlign textAlign = TextAlign.right,
    int? maxLength,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text(label, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600,
          color: const Color(0xFF404943))),
      const SizedBox(height: 6),
      Container(
        decoration: BoxDecoration(
            color: const Color(0xFFF2F4F2), borderRadius: BorderRadius.circular(12)),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          textDirection: textDirection,
          textAlign: textAlign,
          maxLength: maxLength,
          style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF191C1B)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.cairo(fontSize: 13,
                color: const Color(0xFF6B7280).withValues(alpha: 0.5)),
            border: InputBorder.none,
            prefixIcon: Icon(icon, color: const Color(0xFF717973), size: 18),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            counterStyle: GoogleFonts.cairo(fontSize: 10, color: const Color(0xFF9CA3AF)),
          ),
        ),
      ),
    ]);
  }

  // ── Pricing ───────────────────────────────────────────────────────────────

  Widget _buildPricingCard(OrderFormViewModel vm) {
    final subtitle = vm.isMarketplace
        ? 'السعر الذي تطلبه للمواد في السوق'
        : vm.pickupTarget == PickupTarget.riderBuy
            ? 'السعر الذي تريده مقابل بيع المواد للسائق'
            : 'السعر الذي تريده مقابل بيع المواد للشركة';

    return _SectionCard(
      title: 'سعر المواد',
      subtitle: subtitle,
      hasError: vm.errors.containsKey('price'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          decoration: BoxDecoration(
              color: const Color(0xFFF2F4F2), borderRadius: BorderRadius.circular(14)),
          child: TextField(
            controller: vm.priceCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.left,
            style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold,
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
                vm.isMarketplace ? Icons.storefront_rounded : Icons.sell_rounded,
                color: const Color(0xFF717973), size: 20),
            ),
          ),
        ),
        if (vm.errors.containsKey('price'))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(vm.errors['price']!,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.red)),
          ),
        if (!vm.isMarketplace) ...[
          const SizedBox(height: 12),
          _deliveryFeeCard(vm),
        ],
      ]),
    );
  }

  Widget _deliveryFeeCard(OrderFormViewModel vm) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.amberContainer,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFFDE68A)),
    ),
    child: Row(children: [
      Text('${vm.deliveryFee.toStringAsFixed(1)} د.أ',
          style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold,
              color: AppColors.accentAmber)),
      const Spacer(),
      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        Text('رسوم التوصيل',
            style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold,
                color: const Color(0xFF92400E))),
        Text('تُحسب تلقائياً حسب المسافة',
            style: GoogleFonts.cairo(fontSize: 10, color: const Color(0xFFB45309))),
      ]),
      const SizedBox(width: 10),
      const Icon(Icons.local_shipping_rounded, color: AppColors.accentAmber, size: 20),
    ]),
  );

  // ── Review summary ────────────────────────────────────────────────────────

  Widget _buildReviewSummaryCard(OrderFormViewModel vm) {
    return _SectionCard(
      title: 'ملخص الطلب',
      subtitle: 'راجع تفاصيل طلبك قبل الإرسال',
      child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
        _reviewRow(Icons.category_rounded, 'أنواع المخلفات',
            vm.wasteTypes.isEmpty ? '—' : vm.wasteTypes.map((t) => t.label).join('، ')),
        _reviewRow(Icons.science_rounded, 'الحالة',
            vm.wasteForm?.label ?? 'غير محدد'),
        _reviewRow(Icons.scale_rounded, 'الكمية',
            vm.weightCategory?.shortLabel ?? 'غير محدد'),
        _reviewRow(Icons.location_on_rounded, 'الموقع',
            vm.hasLocation ? vm.addressLabel : 'غير محدد'),
        _reviewRow(
          vm.isMarketplace ? Icons.storefront_rounded : Icons.local_shipping_rounded,
          'نوع الطلب',
          vm.isMarketplace ? 'نشر في السوق' : 'طلب استلام',
          valueColor: vm.isMarketplace ? const Color(0xFF1E40AF) : const Color(0xFF06402B),
        ),
        if (vm.images.isNotEmpty)
          _reviewRow(Icons.photo_library_rounded, 'الصور',
              '${vm.images.length} صورة مرفقة'),
        if (vm.notesCtrl.text.isNotEmpty)
          _reviewRow(Icons.notes_rounded, 'الملاحظات', vm.notesCtrl.text),
      ]),
    );
  }

  Widget _reviewRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: Text(value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold,
                  color: valueColor ?? const Color(0xFF191C1B))),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: const Color(0xFFF2F4F2), borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(label, style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF717973))),
              const SizedBox(width: 6),
              Icon(icon, size: 14, color: const Color(0xFF9CA3AF)),
            ]),
          ),
        ]),
      ]),
    );
  }
}
