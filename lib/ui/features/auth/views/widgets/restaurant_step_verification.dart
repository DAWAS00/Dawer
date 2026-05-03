import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/restaurant_signup_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';

class RestaurantStepVerification extends StatelessWidget {
  const RestaurantStepVerification({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RestaurantSignupViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Location & Verification',
          style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Provide your physical address and upload verification documents. Our AI will automatically verify your details.',
          style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        TextFormField(
          initialValue: vm.data.address,
          onChanged: vm.updateAddress,
          decoration: InputDecoration(
            labelText: 'Restaurant Address',
            hintText: 'Enter full street address',
            errorText: vm.errors['address'],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // [FUTURE IMPLEMENTATION: Address Autocomplete]
        // Replace standard text input with Google Places / Mapbox autocomplete widget.
        const SizedBox(height: 24),
        
        if (vm.data.isCertificationVerified)
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
                        'Status: Verified',
                        style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade800),
                      ),
                      Text(
                        'Your documents and address have been automatically verified.',
                        style: GoogleFonts.cairo(fontSize: 14, color: Colors.green.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
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
                label: Text('Upload License & Verify'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              if (vm.errors.containsKey('verification'))
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    vm.errors['verification']!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
