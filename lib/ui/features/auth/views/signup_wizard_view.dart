import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dwaar/data/models/user_role.dart';
import 'package:dwaar/ui/common/wizard/common_wizard_top_bar.dart';
import 'package:dwaar/ui/common/wizard/common_wizard_progress_bar.dart';
import 'package:dwaar/ui/features/auth/controllers/signup_wizard_controller.dart';
import 'package:dwaar/ui/features/auth/views/signup_wizard/steps/step1_identity.dart';
import 'package:dwaar/ui/features/auth/views/signup_wizard/steps/step2_ai_scan.dart';
import 'package:dwaar/ui/features/auth/views/signup_wizard/steps/step3_role_details.dart';
import 'package:dwaar/ui/features/auth/views/signup_wizard/steps/step4_credentials.dart';
import 'package:dwaar/ui/features/auth/views/signup_wizard/fx/wizard_bottom_actions.dart';
import 'package:dwaar/ui/features/home/home_router.dart';

class SignUpWizardView extends StatefulWidget {
  final UserRole initialRole;
  final SupplierType initialSupplierType;

  const SignUpWizardView({
    super.key,
    required this.initialRole,
    required this.initialSupplierType,
  });

  @override
  State<SignUpWizardView> createState() => _SignUpWizardViewState();
}

class _SignUpWizardViewState extends State<SignUpWizardView> {
  late final SignupWizardController _controller;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _controller = SignupWizardController();
    _controller.updateRole(widget.initialRole, widget.initialSupplierType);
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
    
    if (_controller.submitted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => HomeRouter(
              role: _controller.role,
              supplierType: _controller.supplierType,
              userName: _controller.buildRequest().name,
              aiSuggestedCategories: _controller.licenseVm.suggestedCategories,
            ),
          ),
          (route) => false,
        );
      });
    }
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              CommonWizardTopBar(
                currentStep: _controller.currentStep,
                totalSteps: 4,
                title: 'إنشاء حساب جديد',
                onBack: () {
                  if (_controller.currentStep > 0) {
                    _controller.prevStep();
                  } else {
                    Navigator.pop(context);
                  }
                },
                stepTitles: const [
                  'الهوية والدور',
                  'التحقق الذكي',
                  'تفاصيل العمل',
                  'بيانات الدخول',
                ],
              ),
              CommonWizardProgressBar(
                currentStep: _controller.currentStep,
                totalSteps: 4,
              ),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Step1Identity(controller: _controller),
                    Step2AiScan(controller: _controller),
                    Step3RoleDetails(controller: _controller),
                    Step4Credentials(controller: _controller),
                  ],
                ),
              ),
              SignupWizardBottomActions(controller: _controller),
            ],
          ),
        ),
      ),
    );
  }
}
