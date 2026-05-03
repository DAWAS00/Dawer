import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../common/animated_status_text.dart';
import '../../../../common/ai_shimmer_loader.dart';
import '../../viewmodels/ai_photo_validation_viewmodel.dart';
import '../../../../../l10n/l10n.dart';
import '../../../../../core/utils/error_key_resolver.dart';

class AiPhotoValidationWidget extends StatelessWidget {
  const AiPhotoValidationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AiPhotoValidationViewModel>();
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (vm.state == ValidationState.idle)
          _buildUploadZone(context, vm, l10n),
          
        if (vm.state == ValidationState.analyzing)
          _buildAnalyzingZone(context, vm, l10n),
          
        if (vm.state == ValidationState.success)
          _buildSuccessZone(context, vm, l10n),
          
        if (vm.state == ValidationState.error)
          _buildErrorZone(context, vm, l10n),
      ],
    );
  }

  Widget _buildUploadZone(BuildContext context, AiPhotoValidationViewModel vm, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        // Mock photo picker trigger - use a valid path to succeed, or one with 'fail' to fail
        vm.pickAndValidatePhoto('dummy/path/to/photo.jpg');
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, size: 48, color: Colors.blue.shade600),
            const SizedBox(height: 16),
            Text(
              l10n.aiValidationUploadPrompt, // "Tap to capture or upload photo"
              style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey.shade800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyzingZone(BuildContext context, AiPhotoValidationViewModel vm, AppLocalizations l10n) {
    return Column(
      children: [
        const AiShimmerLoader(height: 180),
        const SizedBox(height: 24),
        AnimatedStatusText(
          phrases: [
            l10n.aiValidationAnalyzingStep1, // "AI is analyzing your photo..."
            l10n.aiValidationAnalyzingStep2, // "Checking document clarity..."
            l10n.aiValidationAnalyzingStep3, // "Verifying authenticity..."
          ],
          style: GoogleFonts.cairo(fontSize: 16, color: Colors.blue.shade700, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSuccessZone(BuildContext context, AiPhotoValidationViewModel vm, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        border: Border.all(color: Colors.green.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.aiValidationSuccessTitle, // "Photo Verified!"
                  style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                ),
                Text(
                  l10n.aiValidationSuccessSubtitle, // "Your photo meets all requirements."
                  style: GoogleFonts.cairo(fontSize: 14, color: Colors.green.shade700),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.green),
            onPressed: vm.reset,
            tooltip: l10n.aiValidationRetryButton,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorZone(BuildContext context, AiPhotoValidationViewModel vm, AppLocalizations l10n) {
    return Column(
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
              const Icon(Icons.error, color: Colors.red, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.aiValidationErrorTitle, // "Validation Failed"
                      style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red.shade800),
                    ),
                    Text(
                      resolveErrorKey(context, vm.errorMessageKey) ?? l10n.aiValidationErrorUnknown,
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
          onPressed: () {
            // Trigger failure to test the error loop
            vm.pickAndValidatePhoto('dummy/path/to/fail.jpg');
          },
          icon: const Icon(Icons.upload_file),
          label: Text(l10n.aiValidationRetryButton), // "Try Again"
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
