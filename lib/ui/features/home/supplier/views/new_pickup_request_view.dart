import 'package:flutter/material.dart';

import '../../../../../data/models/order.dart';
import '../../../../../data/models/user_role.dart';
import '../../../../../data/services/location_service.dart';
import '../../shared/controllers/post_market_controller.dart';
import '../controllers/publish_form_controller.dart';
import '../../../../../core/utils/haptic_util.dart';

import '../widgets/wizard/top_bar.dart';
import '../widgets/wizard/progress_bar.dart';
import '../widgets/wizard/step_1_material_photo.dart';
import '../widgets/wizard/step_2_quantity_price.dart';
import '../widgets/wizard/step_3_location_review.dart';
import '../widgets/wizard/bottom_actions.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إرسال الطلب بنجاح! ✓'),
        backgroundColor: Color(0xFF2E7D32),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            WizardTopBar(
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
            ),
            WizardProgressBar(
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
