part of '../order_form_view.dart';

extension _SubmitBarExt on _OrderFormViewState {
  Widget _buildSubmitBar(OrderFormViewModel vm) {
    final isLastStep = vm.step == 2;
    final isMarket = vm.isMarketplace;

    final buttonText = isLastStep
        ? (isMarket ? 'نشر في السوق' : 'إرسال الطلب')
        : 'التالي';

    final buttonIcon = isLastStep
        ? Icon(isMarket ? Icons.storefront_rounded : Icons.send_rounded,
            color: Colors.white, size: 20)
        : const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE6E9E7))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLastStep && !isMarket && vm.hasLocation)
            _deliverySummaryChip(vm),
          const SizedBox(height: 8),
          Row(children: [
            if (vm.step > 0) ...[
              _backButton(),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: GreenButton(
                text: buttonText,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting
                    ? null
                    : isLastStep
                        ? _submit
                        : _next,
                trailingIcon: buttonIcon,
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _backButton() => SizedBox(
    width: 52,
    height: 60,
    child: OutlinedButton(
      onPressed: _back,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFFE6E9E7)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.zero,
      ),
      child: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF717973), size: 20),
    ),
  );

  Widget _deliverySummaryChip(OrderFormViewModel vm) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.amberContainer,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: const Color(0xFFFDE68A)),
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text('${vm.deliveryFee.toStringAsFixed(1)} د.أ',
          style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.bold,
              color: AppColors.accentAmber)),
      Text('رسوم التوصيل المقدّرة',
          style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF92400E))),
    ]),
  );
}
