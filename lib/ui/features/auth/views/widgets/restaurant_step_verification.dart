import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/restaurant_signup_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../l10n/l10n.dart';
import '../../../../../core/utils/error_key_resolver.dart';
import '../../../../common/ai_shimmer_loader.dart';

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
        
        // AI Checking state — shimmer + spinner animation
        if (vm.isAiCheckingDoc)
          const Column(
            children: [
              AiShimmerLoader(height: 100),
              SizedBox(height: 16),
              CircularProgressIndicator(),
            ],
          )
        // Valid state — green badge
        else if (vm.isDocValid && vm.data.isCertificationVerified)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.restaurantSignupStatusVerified,
                        style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                      ),
                      Text(
                        l10n.restaurantSignupVerificationSuccess,
                        style: GoogleFonts.cairo(fontSize: 14, color: Colors.green.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        // Invalid state — red badge (mirrors green badge design)
        else if (!vm.isAiCheckingDoc && !vm.isDocValid && vm.errors.containsKey('verification'))
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade400),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cancel, color: Colors.red, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.restaurantSignupStatusInvalid,
                            style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red.shade800),
                          ),
                          Text(
                            resolveErrorKey(context, vm.errors['verification']) ?? '',
                            style: GoogleFonts.cairo(fontSize: 14, color: Colors.red.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: vm.isVerifying
                    ? null
                    : () {
                        vm.verifyLocationAndDocs('dummy/path/to/license.pdf');
                      },
                icon: vm.isVerifying
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh),
                label: Text(l10n.restaurantSignupUploadVerifyButton),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          )
        // Default — upload button
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OutlinedButton.icon(
                onPressed: vm.isVerifying
                    ? null
                    : () {
                        // Simulated document upload and verification
                        vm.verifyLocationAndDocs('dummy/path/to/license.pdf');
                      },
                icon: vm.isVerifying
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.upload_file),
                label: Text(l10n.restaurantSignupUploadVerifyButton),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.restaurantSignupAiVerificationNote,
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.blue.shade700, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              if (vm.errors.containsKey('verification') && !vm.isDocValid)
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    resolveErrorKey(context, vm.errors['verification']) ?? '',
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
