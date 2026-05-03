import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/services/mock_ai_simulation_service.dart';
import '../viewmodels/restaurant_signup_viewmodel.dart';
import 'widgets/restaurant_step_basic_profile.dart';
import 'widgets/restaurant_step_ai_identity.dart';
import 'widgets/restaurant_step_verification.dart';
import 'widgets/restaurant_step_review.dart';
import '../../../../l10n/l10n.dart';

class RestaurantSignupView extends StatelessWidget {
  const RestaurantSignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RestaurantSignupViewModel(
        aiService: MockAiSimulationService(),
      ),
      child: const _RestaurantSignupContent(),
    );
  }
}

class _RestaurantSignupContent extends StatelessWidget {
  const _RestaurantSignupContent();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RestaurantSignupViewModel>();
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(l10n.restaurantSignupAppBarTitle),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: vm.currentStep / vm.totalSteps,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: _buildCurrentStep(vm.currentStep),
              ),
            ),
            _buildBottomBar(context, vm),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStep(int step) {
    switch (step) {
      case 1:
        return const RestaurantStepBasicProfile();
      case 2:
        return const RestaurantStepAiIdentity();
      case 3:
        return const RestaurantStepVerification();
      case 4:
        return const RestaurantStepReview();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomBar(BuildContext context, RestaurantSignupViewModel vm) {
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (vm.currentStep > 1)
            TextButton(
              onPressed: vm.isSubmitted ? null : vm.previousStep,
              child: Text(l10n.restaurantSignupBackButton),
            )
          else
            const SizedBox(width: 64),

          ElevatedButton(
            onPressed: vm.isSubmitted 
                ? null 
                : () async {
                    if (vm.currentStep == vm.totalSteps) {
                      final success = await vm.submit();
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.restaurantSignupSuccess)),
                        );
                        Navigator.of(context).pop();
                      }
                    } else {
                      vm.nextStep();
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: vm.isSubmitted
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(vm.currentStep == vm.totalSteps
                    ? l10n.restaurantSignupSubmitButton
                    : l10n.restaurantSignupNextButton),
          ),
        ],
      ),
    );
  }
}
