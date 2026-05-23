import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dwaar/data/models/user_role.dart';
import 'package:dwaar/ui/features/auth/controllers/signup_wizard_controller.dart';
import 'package:dwaar/ui/features/auth/views/signup_wizard/fx/ai_photo_picker.dart';

class Step1Identity extends StatelessWidget {
  final SignupWizardController controller;
  const Step1Identity({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          AiPhotoPicker(
            image: controller.profilePhoto,
            label: 'الصورة الشخصية',
            isVerified: controller.isPhotoVerified,
            isBusiness: controller.role == UserRole.recyclingCo || controller.supplierType == SupplierType.storeBusiness,
            onPick: (file) => controller.pickProfilePhoto(file),
            onRemove: () => controller.pickProfilePhoto(null as dynamic),
          ),
          const SizedBox(height: 32),
          _buildFieldLabel('الاسم الكامل *'),
          const SizedBox(height: 8),
          _buildTextField(
            hint: 'أدخل اسمك كما في الهوية',
            onChanged: (v) => controller.fullName = v,
            initialValue: controller.fullName,
          ),
          const SizedBox(height: 24),
          _buildFieldLabel('نوع الحساب *'),
          const SizedBox(height: 12),
          _buildRoleSelector(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'أهلاً بك في دوّر!',
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A1A),
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 4),
        Text(
          'لنبدأ بإنشاء هويتك الرقمية',
          style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF6B6B6B)),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.cairo(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF4B5563),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required ValueChanged<String> onChanged,
    String? initialValue,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        textAlign: TextAlign.right,
        style: GoogleFonts.cairo(fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.cairo(color: const Color(0xFFAAAAAA), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return Row(
      children: [
        _RoleCard(
          label: 'سائق',
          icon: Icons.local_shipping_rounded,
          isSelected: controller.role == UserRole.driver,
          onTap: () => controller.updateRole(UserRole.driver),
        ),
        const SizedBox(width: 12),
        _RoleCard(
          label: 'مورد',
          icon: Icons.inventory_2_rounded,
          isSelected: controller.role == UserRole.supplier,
          onTap: () => controller.updateRole(UserRole.supplier),
        ),
        const SizedBox(width: 12),
        _RoleCard(
          label: 'شركة تدوير',
          icon: Icons.recycling_rounded,
          isSelected: controller.role == UserRole.recyclingCo,
          onTap: () => controller.updateRole(UserRole.recyclingCo),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFFE0E0E0),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFF6B6B6B), size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? const Color(0xFF2E7D32) : const Color(0xFF6B6B6B),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
