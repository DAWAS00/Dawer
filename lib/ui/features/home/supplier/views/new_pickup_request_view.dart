import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dwaar/data/models/order/order.dart';
import 'package:dwaar/data/models/user_role.dart';
import 'package:dwaar/data/services/location_service.dart';
import 'package:dwaar/ui/features/home/shared/controllers/post_market_controller.dart';
import 'package:dwaar/ui/features/home/supplier/controllers/publish_form_controller.dart';
import 'package:dwaar/ui/features/home/shared/viewmodels/base_supplier_viewmodel.dart';
import 'package:dwaar/domain/requests/create_pickup_request.dart';
import 'package:dwaar/core/utils/haptic_util.dart';
import 'package:dwaar/l10n/l10n.dart';

import 'package:dwaar/ui/features/home/supplier/widgets/wizard/top_bar.dart';
import 'package:dwaar/ui/features/home/supplier/widgets/wizard/progress_bar.dart';
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
  })?
  onSubmit;

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
        pickupAddress:
            _controller.pickedAddress ?? context.l10n.wizardLocationDefined,
        images: List.from(_controller.images),
        notes: _controller.notesCtrl.text.trim().isNotEmpty
            ? _controller.notesCtrl.text.trim()
            : null,
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
    final l10n = context.l10n;
    final vm = context.read<BaseSupplierViewModel>();
    final wasteTypes = _controller.selectedTypes.toList();
    final pickupAddress =
        _controller.pickedAddress ?? l10n.wizardLocationDefined;
    final notes = _controller.notesCtrl.text.trim().isNotEmpty
        ? _controller.notesCtrl.text.trim()
        : null;
    final itemPrice = double.tryParse(_controller.priceCtrl.text.trim());

    if (_controller.mode == OrderMode.marketplace) {
      final order = vm.createListing(
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
      vm.addOrder(order);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.wizardPublishedToMarket),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      final success = await vm.submitPickupRequest(
        CreatePickupRequest(
          supplierId: vm.user.id,
          wasteTypes: wasteTypes,
          wasteForm: _controller.wasteForm ?? WasteForm.solid,
          weightCategory: _controller.weightCategory ?? WeightCategory.light,
          pickupAddress: pickupAddress,
          notes: notes,
          images: List.from(_controller.images),
          itemPrice: itemPrice,
          pickupLat: _controller.pickedLat,
          pickupLng: _controller.pickedLng,
        ),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.wizardPickupRequestSent),
              backgroundColor: const Color(0xFF2E7D32),
              behavior: SnackBarBehavior.floating,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                vm.pickupSubmitError?.message ?? l10n.wizardPickupRequestFailed,
              ),
              backgroundColor: const Color(0xFFC62828),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
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
              title: _controller.mode == OrderMode.marketplace
                  ? context.l10n.wizardPublishToMarket
                  : context.l10n.wizardNewPickupTitle,
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
            WizardBottomActions(controller: _controller, onPublish: _onPublish),
          ],
        ),
      ),
    );
  }
}
