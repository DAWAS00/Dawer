import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/restaurant_signup_viewmodel.dart';
import '../../viewmodels/license_validation_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../l10n/l10n.dart';
import '../../../../../core/utils/error_key_resolver.dart';
import 'license_scan_section.dart';

class RestaurantStepVerification extends StatelessWidget {
  const RestaurantStepVerification({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RestaurantSignupViewModel>();
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.restaurantSignupStep3Title,
          style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.restaurantSignupStep3Subtitle,
          style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextFormField(
          initialValue: vm.data.address,
          onChanged: vm.updateAddress,
          decoration: InputDecoration(
            labelText: l10n.restaurantSignupAddressLabel,
            hintText: l10n.restaurantSignupAddressHint,
            errorText: resolveErrorKey(context, vm.errors['address']),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ChangeNotifierProvider.value(
          value: vm.licenseVm,
          child: LicenseScanSection(
            label: l10n.restaurantSignupUploadVerifyButton, // TODO: add dedicated l10n key
            onPick: (src) =>
                context.read<RestaurantSignupViewModel>().pickLicense(src),
            onReset: () =>
                context.read<RestaurantSignupViewModel>().clearLicense(),
          ),
        ),
        if (vm.errors.containsKey('verification') &&
            vm.licenseVm.state != LicenseValidationState.valid) ...[
          const SizedBox(height: 8),
          Text(
            resolveErrorKey(context, vm.errors['verification']) ?? '',
            style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.red.shade700,
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
