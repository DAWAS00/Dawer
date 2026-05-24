import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../data/models/user_role.dart';
import 'signup_view.dart' show SignUpView;
import 'restaurant_signup_view.dart' show RestaurantSignupView;

class UnifiedSignupView extends StatefulWidget {
  const UnifiedSignupView({super.key});

  @override
  State<UnifiedSignupView> createState() => _UnifiedSignupViewState();
}

class _UnifiedSignupViewState extends State<UnifiedSignupView> {
  SupplierType? _selectedType;

  void _onTypeSelected(SupplierType type) {
    setState(() {
      _selectedType = type;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        title: Text(
          'Let\'s get your business set up', // To be localized
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF06402B),
          ),
        ),
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF06402B)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Role Selection Toggle/Cards
          if (_selectedType == null) ...[
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      'Choose your account type',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF002819),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _buildRoleCard(
                      context,
                      title: 'Individual Supplier',
                      subtitle: 'I am an independent supplier',
                      icon: Icons.person_rounded,
                      onTap: () => _onTypeSelected(SupplierType.individual),
                    ),
                    const SizedBox(height: 16),
                    _buildRoleCard(
                      context,
                      title: 'Restaurant (Company)',
                      subtitle: 'I am registering a restaurant or business',
                      icon: Icons.business_rounded,
                      onTap: () => _onTypeSelected(SupplierType.storeBusiness),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Render appropriate signup flow
            Expanded(
              child: ClipRRect(
                child: _selectedType == SupplierType.individual
                    ? const SignUpView(
                        role: UserRole.supplier,
                        supplierType: SupplierType.individual,
                      )
                    : const RestaurantSignupView(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE6E9E7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF166534), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF002819),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: const Color(0xFF717973),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFC0C9C1), size: 16),
          ],
        ),
      ),
    );
  }
}
