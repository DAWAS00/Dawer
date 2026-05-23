import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dwaar/data/models/order.dart';
import 'package:dwaar/data/models/user_role.dart';
import 'package:dwaar/data/services/location_service.dart';
import 'package:dwaar/ui/features/home/shared/controllers/post_market_controller.dart';
import 'package:dwaar/ui/features/home/supplier/controllers/publish_form_controller.dart';
import 'package:dwaar/ui/features/home/supplier/viewmodels/supplier_home_viewmodel.dart';
import 'package:dwaar/core/utils/haptic_util.dart';

import 'package:dwaar/ui/common/wizard/common_wizard_top_bar.dart';
import 'package:dwaar/ui/common/wizard/common_wizard_progress_bar.dart';
import 'package:dwaar/ui/features/home/supplier/widgets/wizard/step_1_material_photo.dart';
import 'package:dwaar/ui/features/home/supplier/widgets/wizard/step_2_quantity_price.dart';
import 'package:dwaar/ui/features/home/supplier/widgets/wizard/step_3_location_review.dart';
import 'package:dwaar/ui/features/home/supplier/widgets/wizard/bottom_actions.dart';

// ─── Main screen ───────────────────────────────────────────────────────────

class NewPickupRequestView extends StatefulWidget {
  final UserRole? role;
  final OrderMode? initialMode;
  final void Function({
    required List<WasteType> wasteTypes,
    required String pickupAddress,
    List<String> images,
    String? notes,
    WasteForm? wasteForm,
    WeightCategory? weightCategory,
    double? itemPrice,
    double? pickupLat,
    double? pickupLng,
  })? onSubmit;

  const NewPickupRequestView({
    super.key,
    this.role,
    this.initialMode,
    this.onSubmit,
  });

  @override
  State<NewPickupRequestView> createState() => _NewPickupRequestViewState();
}

class _NewPickupRequestViewState extends State<NewPickupRequestView> {
  late final PublishFormController _controller;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _controller = PublishFormController(
      aiController: PostMarketController(),
      locationService: LocationService(),
      mode: widget.initialMode ?? OrderMode.pickup,
    );
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (_controller.currentStep != _pageController.page?.round()) {
      _pageController.animateToPage(
        _controller.currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
    setState(() {});
  }

  void _onPublish() {
    HapticUtil.success();
    if (widget.onSubmit != null) {
      widget.onSubmit!(
        wasteTypes: _controller.selectedTypes.toList(),
        pickupAddress: _controller.pickedAddress ?? 'موقع محدد',
        images: List.from(_controller.images),
        notes: _controller.notesCtrl.text.trim().isNotEmpty ? _controller.notesCtrl.text.trim() : null,
        wasteForm: _controller.wasteForm,
        weightCategory: _controller.weightCategory,
        itemPrice: double.tryParse(_controller.priceCtrl.text.trim()),
        pickupLat: _controller.pickedLat,
        pickupLng: _controller.pickedLng,
      );
      Navigator.pop(context);
    } else {
      _handleDefaultSubmit();
    }
  }

  Future<void> _handleDefaultSubmit() async {
    final vm = context.read<SupplierHomeViewModel>();
    final wasteTypes = _controller.selectedTypes.toList();
    final pickupAddress = _controller.pickedAddress ?? 'موقع محدد';
    final notes = _controller.notesCtrl.text.trim().isNotEmpty 
        ? _controller.notesCtrl.text.trim() 
        : null;
    final itemPrice = double.tryParse(_controller.priceCtrl.text.trim());

    Order order;
    if (_controller.mode == OrderMode.marketplace) {
      order = vm.createListing(
        wasteTypes: wasteTypes,
        pickupAddress: pickupAddress,
        images: List.from(_controller.images),
        notes: notes,
        wasteForm: _controller.wasteForm,
        weightCategory: _controller.weightCategory,
        itemPrice: itemPrice,
        pickupLat: _controller.pickedLat,
        pickupLng: _controller.pickedLng,
      );
    } else {
      order = vm.createOrder(
        wasteTypes: wasteTypes,
        pickupAddress: pickupAddress,
        images: List.from(_controller.images),
        notes: notes,
        wasteForm: _controller.wasteForm,
        weightCategory: _controller.weightCategory,
        itemPrice: itemPrice,
      );
    }

    vm.addOrder(order);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.mode == OrderMode.marketplace 
              ? 'تم النشر في السوق بنجاح! ✓' 
              : 'تم إرسال طلب الاستلام بنجاح! ✓'),
          backgroundColor: const Color(0xFF2E7D32),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            CommonWizardTopBar(
              currentStep: _controller.currentStep,
              totalSteps: 3,
              title: _controller.mode == OrderMode.marketplace ? 'نشر في السوق' : 'طلب استلام جديد',
              onBack: () {
                HapticUtil.light();
                if (_controller.currentStep > 0) {
                  _controller.prevStep();
                } else {
                  Navigator.pop(context);
                }
              },
              stepTitles: const [
                'نوع المواد والصور',
                'الكمية والسعر',
                'الموقع والنشر',
              ],
            ),
            CommonWizardProgressBar(
              currentStep: _controller.currentStep,
              totalSteps: 3,
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  Step1MaterialAndPhoto(controller: _controller),
                  Step2QuantityAndPrice(controller: _controller),
                  Step3LocationAndReview(controller: _controller),
                ],
              ),
            ),
            WizardBottomActions(
              controller: _controller,
              onPublish: _onPublish,
            ),
          ],
        ),
      ),
    );
  }
}
