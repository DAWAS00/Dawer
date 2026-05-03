import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/restaurant_signup_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../l10n/l10n.dart';
import '../../../../../core/utils/error_key_resolver.dart';
import 'ai_suggestion_card.dart';

class RestaurantStepBasicProfile extends StatelessWidget {
  const RestaurantStepBasicProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RestaurantSignupViewModel>();
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.restaurantSignupStep1Title,
          style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.restaurantSignupStep1Subtitle,
          style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Center(
          child: GestureDetector(
            onTap: () {
              // Simulated image picking
              vm.updateBasicProfile(photoPath: 'dummy/path/to/photo.jpg');
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: vm.data.photoPath != null
                  ? const Icon(Icons.check_circle, color: Colors.green, size: 40)
                  : const Icon(Icons.camera_alt, color: Colors.grey, size: 40),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: vm.data.companyName,
          onChanged: (val) => vm.updateBasicProfile(companyName: val, ownerName: vm.data.ownerName),
          decoration: InputDecoration(
            labelText: l10n.restaurantSignupCompanyNameLabel,
            hintText: l10n.restaurantSignupCompanyNameHint,
            errorText: resolveErrorKey(context, vm.errors['companyName']),
            border: OutlineBinding.border(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: vm.data.ownerName,
          onChanged: (val) => vm.updateBasicProfile(ownerName: val, companyName: vm.data.companyName),
          decoration: InputDecoration(
            labelText: l10n.restaurantSignupOwnerNameLabel,
            hintText: l10n.restaurantSignupOwnerNameHint,
            errorText: resolveErrorKey(context, vm.errors['ownerName']),
            border: OutlineBinding.border(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          initialValue: vm.cuisineType,
          onChanged: vm.updateCuisineType,
          decoration: InputDecoration(
            labelText: l10n.signupCuisineType,
            hintText: l10n.signupCuisineTypeHint,
            errorText: resolveErrorKey(context, vm.errors['cuisineType']),
            border: OutlineBinding.border(),
          ),
        ),
        if (vm.cuisineType.isNotEmpty || vm.isLoadingSuggestion) ...[
          const SizedBox(height: 16),
          AiSuggestionCard(
            isLoading: vm.isLoadingSuggestion,
            marketplaceLookupPrompt: vm.suggestion?.marketplaceLookupPrompt,
            appDiscoverySuggestion: vm.suggestion?.appDiscoverySuggestion,
          ),
        ],
      ],
    );
  }
}

class OutlineBinding {
  static OutlineInputBorder border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey),
    );
  }
}
