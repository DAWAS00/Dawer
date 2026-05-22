import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/waste_type_icons.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/models/user_role.dart';
import '../../../../common/green_button.dart';
import '../../../../common/map/location_picker_screen.dart';
import '../../supplier/widgets/image_picker_grid.dart';
import 'order_form_viewmodel.dart';
import '../../../../../data/services/location_service.dart';

part 'order_form_view/step_indicator.dart';
part 'order_form_view/role_banner.dart';
part 'order_form_view/step1_details.dart';
part 'order_form_view/step2_logistics.dart';
part 'order_form_view/step3_review.dart';
part 'order_form_view/submit_bar.dart';

class OrderFormView extends StatefulWidget {
  final SupplierType supplierType;
  final String userName;
  final Future<bool> Function(OrderFormData) onPickupSubmit;
  final Future<bool> Function(OrderFormData) onMarketSubmit;

  const OrderFormView({
    super.key,
    required this.supplierType,
    required this.userName,
    required this.onPickupSubmit,
    required this.onMarketSubmit,
  });

  @override
  State<OrderFormView> createState() => _OrderFormViewState();
}

class _OrderFormViewState extends State<OrderFormView> {
  late final OrderFormViewModel _vm;
  late final PageController _pageCtrl;
  bool _isSubmitting = false;
  final _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _vm = OrderFormViewModel(supplierType: widget.supplierType);
    _vm.ai.addListener(_onAi);
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _vm.ai.removeListener(_onAi);
    _vm.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  void _onAi() => setState(() {});

  void _next() {
    final ok = _vm.advance();
    if (ok) {
      _pageCtrl.animateToPage(_vm.step,
          duration: const Duration(milliseconds: 320), curve: Curves.easeInOut);
    }
  }

  void _back() {
    if (_vm.step > 0) {
      _vm.goBack();
      _pageCtrl.animateToPage(_vm.step,
          duration: const Duration(milliseconds: 280), curve: Curves.easeInOut);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _submit() async {
    if (!_vm.validateStep(2)) return;
    setState(() => _isSubmitting = true);
    final data = _vm.buildData();
    final ok = data.isMarketplace
        ? await widget.onMarketSubmit(data)
        : await widget.onPickupSubmit(data);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    if (!ok) return;
    if (data.isMarketplace) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('تم النشر في السوق بنجاح ✓', style: GoogleFonts.cairo()),
        backgroundColor: const Color(0xFF065F46),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      if (mounted) Navigator.pop(context);
    } else {
      if (mounted) Navigator.pop(context, data);
    }
  }

  static const _stepTitles = ['تفاصيل المخلفات', 'الموقع والوقت', 'المراجعة والتأكيد'];

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<OrderFormViewModel>(
        builder: (ctx, vm, _) => Scaffold(
          backgroundColor: AppColors.background,
          appBar: _buildAppBar(vm),
          body: SafeArea(
            top: false,
            child: PageView(
              controller: _pageCtrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [_buildStep1(vm), _buildStep2(vm), _buildStep3(vm)],
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: _buildSubmitBar(vm),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(OrderFormViewModel vm) => AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    scrolledUnderElevation: 0,
    automaticallyImplyLeading: false,
    leading: Padding(
      padding: const EdgeInsets.all(8),
      child: GestureDetector(
        onTap: _back,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF2F4F2), shape: BoxShape.circle),
          child: const Icon(Icons.arrow_forward_rounded,
              size: 20, color: Color(0xFF717973)),
        ),
      ),
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(_stepTitles[vm.step],
              key: ValueKey(vm.step),
              style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: const Color(0xFF002819))),
        ),
        const SizedBox(height: 4),
        _StepDotsIndicator(currentStep: vm.step),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared section card used by all part files
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool hasError;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
    this.subtitle,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: hasError
            ? Border.all(color: AppColors.statusCancelledBg, width: 1.5)
            : null,
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title,
              style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002819))),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!,
                style: GoogleFonts.cairo(
                    fontSize: 11, color: const Color(0xFF9CA3AF))),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
