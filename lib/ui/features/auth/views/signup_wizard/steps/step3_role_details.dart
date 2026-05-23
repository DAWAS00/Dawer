import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dwaar/data/models/user_role.dart';
import 'package:dwaar/ui/features/auth/controllers/signup_wizard_controller.dart';

class Step3RoleDetails extends StatelessWidget {
  final SignupWizardController controller;
  const Step3RoleDetails({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          if (controller.role == UserRole.driver) _buildDriverFields(),
          if (controller.role == UserRole.supplier) _buildSupplierFields(),
          if (controller.role == UserRole.recyclingCo) _buildRecyclingFields(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final title = controller.role == UserRole.driver ? 'تفاصيل المركبة' : 'تفاصيل العمل';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A1A),
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 4),
        Text(
          'أكمل البيانات المطلوبة لنوع حسابك',
          style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF6B6B6B)),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }

  Widget _buildDriverFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildFieldLabel('رقم لوحة المركبة *'),
        const SizedBox(height: 8),
        _buildTextField(
          hint: 'مثال: 12-34567',
          onChanged: (v) => controller.vehiclePlate = v,
          initialValue: controller.vehiclePlate,
        ),
        const SizedBox(height: 24),
        _buildFieldLabel('نوع وموديل المركبة'),
        const SizedBox(height: 8),
        _buildTextField(
          hint: 'مثال: تويوتا بريوس 2022',
          onChanged: (v) => {},
        ),
      ],
    );
  }

  Widget _buildSupplierFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildFieldLabel('الفئة الأساسية للمواد *'),
        const SizedBox(height: 8),
        _buildTextField(
          hint: 'مثال: بلاستيك، كرتون...',
          onChanged: (v) => controller.primaryCategory = v,
          initialValue: controller.primaryCategory,
        ),
        const SizedBox(height: 24),
        _buildFieldLabel('منطقة الخدمة'),
        const SizedBox(height: 8),
        _buildTextField(
          hint: 'مثال: عمان، الزرقاء...',
          onChanged: (v) => controller.coverageArea = v,
          initialValue: controller.coverageArea,
        ),
      ],
    );
  }

  Widget _buildRecyclingFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildFieldLabel('اسم المنشأة *'),
        const SizedBox(height: 8),
        _buildTextField(
          hint: 'أدخل الاسم التجاري المسجل',
          onChanged: (v) => controller.businessName = v,
          initialValue: controller.businessName,
        ),
        const SizedBox(height: 24),
        _buildFieldLabel('اسم المدير المسؤول *'),
        const SizedBox(height: 8),
        _buildTextField(
          hint: 'الاسم الكامل للمدير',
          onChanged: (v) => controller.ownerManagerName = v,
          initialValue: controller.ownerManagerName,
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
}
