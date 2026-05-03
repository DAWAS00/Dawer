import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/restaurant_signup_viewmodel.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../l10n/l10n.dart';

class RestaurantStepReview extends StatelessWidget {
  const RestaurantStepReview({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RestaurantSignupViewModel>();
    final data = vm.data;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.restaurantSignupStep4Title,
          style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.restaurantSignupStep4Subtitle,
          style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        
        _buildSectionTitle(context, l10n.restaurantSignupSectionBasic),
        _buildDetailRow(context, l10n.signupCompanyName, data.companyName ?? '-'),
        _buildDetailRow(context, l10n.restaurantSignupOwnerNameLabel, data.ownerName ?? '-'),
        const Divider(),
        
        _buildSectionTitle(context, l10n.restaurantSignupSectionAi),
        _buildDetailRow(context, l10n.restaurantSignupTaglineLabel, data.tagline ?? '-'),
        const SizedBox(height: 8),
        Text(l10n.restaurantSignupGeneratedStoryLabel, style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey.shade600)),
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
        _buildDetailRow(context, l10n.restaurantSignupCategoriesLabel, data.selectedCategories.join(', ')),
        const Divider(),
        
        _buildSectionTitle(context, l10n.restaurantSignupSectionLocation),
        _buildDetailRow(context, l10n.restaurantSignupAddressLabel, data.address ?? '-'),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.shield, size: 20, color: data.isCertificationVerified ? Colors.green : Colors.red),
            const SizedBox(width: 8),
            Text(
              data.isCertificationVerified ? l10n.restaurantSignupStatusVerified : l10n.restaurantSignupNotVerified,
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
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
