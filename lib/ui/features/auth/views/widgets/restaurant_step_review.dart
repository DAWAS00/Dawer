import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/restaurant_signup_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';

class RestaurantStepReview extends StatelessWidget {
  const RestaurantStepReview({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RestaurantSignupViewModel>();
    final data = vm.data;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Review & Submit',
          style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Please review your generated profile and details before final submission.',
          style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        
        _buildSectionTitle('Basic Information'),
        _buildDetailRow('Company Name', data.companyName ?? '-'),
        _buildDetailRow('Owner Name', data.ownerName ?? '-'),
        const Divider(),
        
        _buildSectionTitle('AI Generated Identity'),
        _buildDetailRow('Tagline', data.tagline ?? '-'),
        const SizedBox(height: 8),
        Text('Generated Story:', style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(data.aiGeneratedContent ?? '-'),
        ),
        const SizedBox(height: 8),
        _buildDetailRow('Categories', data.selectedCategories.join(', ')),
        const Divider(),
        
        _buildSectionTitle('Location & Verification'),
        _buildDetailRow('Address', data.address ?? '-'),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.shield, size: 20, color: Colors.green),
            const SizedBox(width: 8),
            Text(
              data.isCertificationVerified ? 'Status: Verified' : 'Not Verified',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: data.isCertificationVerified ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
