part of '../new_pickup_request_view.dart';

extension _SubmitBarExt on _NewPickupRequestViewState {
  Future<void> _pickLocation() async {
    final result = await Navigator.push<(double, double)?>(
      context,
      MaterialPageRoute(builder: (_) => LocationPickerScreen(
        initialLat: _pickedLat, initialLng: _pickedLng)),
    );
    if (result == null || !mounted) return;
    _updateState(() {
      _pickedLat = result.$1; _pickedLng = result.$2;
      _pickedAddress = null; _resolvingAddress = true;
    });
    final address = await _locationService.reverseGeocode(result.$1, result.$2);
    if (mounted) _updateState(() { _pickedAddress = address; _resolvingAddress = false; });
  }

  Future<void> _handleSubmit(BuildContext context, SupplierHomeViewModel vm) async {
    if (_selectedTypes.isEmpty) {
      _updateState(() => _showTypeError = true);
      return;
    }
    if (_pickedLat == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('يرجى تحديد موقع الاستلام', style: GoogleFonts.cairo()),
        backgroundColor: AppColors.statusCancelledBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }

    final request = CreatePickupRequest(
      supplierId: vm.user.id,
      wasteTypes: _selectedTypes.toList(),
      wasteForm: _wasteForm ?? WasteForm.mixed,
      weightCategory: _weightCategory ?? WeightCategory.light,
      pickupAddress: _pickupAddressLabel,
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
    );

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final success = await vm.submitPickupRequest(request);
    if (!mounted) return;

    if (!success) {
      messenger.showSnackBar(SnackBar(
        content: Text(vm.pickupSubmitError?.message ?? 'حدث خطأ، حاول مجدداً',
            style: GoogleFonts.cairo()),
        backgroundColor: AppColors.statusCancelledBg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }

    if (_mode == _OrderMode.marketplace) {
      messenger.showSnackBar(SnackBar(
        content: Text('تم النشر في السوق بنجاح ✓', style: GoogleFonts.cairo()),
        backgroundColor: const Color(0xFF065F46),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      navigator.pop();
    } else if (vm.lastCreatedOrder != null) {
      navigator.pushReplacement(MaterialPageRoute(
        builder: (_) => DriverSelectionView(order: vm.lastCreatedOrder!),
      ));
    }
  }

  Widget _buildDeliveryFeeCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.amberContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(children: [
        Text('${_deliveryFee.toStringAsFixed(1)} د.أ',
            style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold,
                color: AppColors.accentAmber)),
        const Spacer(),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('رسوم التوصيل',
              style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold,
                  color: const Color(0xFF92400E))),
          Text('تُحسب تلقائياً حسب المسافة والحجم',
              style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFFB45309))),
        ]),
        const SizedBox(width: 12),
        const Icon(Icons.local_shipping_rounded, color: AppColors.accentAmber, size: 22),
      ]),
    );
  }

  Widget _buildSubmitBar() {
    final isMarket = _mode == _OrderMode.marketplace;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Consumer<SupplierHomeViewModel>(
          builder: (context, vm, _) => GreenButton(
            text: isMarket ? 'نشر في السوق' : 'إرسال الطلب',
            isLoading: vm.isSubmittingPickup,
            onPressed: vm.isSubmittingPickup ? null : () => _handleSubmit(context, vm),
            trailingIcon: Icon(
              isMarket ? Icons.storefront_rounded : Icons.send_rounded,
              color: Colors.white, size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
