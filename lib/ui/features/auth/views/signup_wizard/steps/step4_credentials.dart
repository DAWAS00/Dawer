import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dwaar/ui/features/auth/controllers/signup_wizard_controller.dart';

class Step4Credentials extends StatelessWidget {
  final SignupWizardController controller;
  const Step4Credentials({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          _buildFieldLabel('رقم الهاتف *'),
          const SizedBox(height: 8),
          _buildTextField(
            hint: '07X XXX XXXX',
            onChanged: (v) => controller.phone = v,
            initialValue: controller.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          _buildFieldLabel('البريد الإلكتروني'),
          const SizedBox(height: 8),
          _buildTextField(
            hint: 'example@domain.com',
            onChanged: (v) => controller.email = v,
            initialValue: controller.email,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          _buildFieldLabel('كلمة المرور *'),
          const SizedBox(height: 8),
          _buildTextField(
            hint: '••••••••',
            onChanged: (v) => controller.password = v,
            initialValue: controller.password,
            obscureText: true,
          ),
          const SizedBox(height: 24),
          _buildFieldLabel('تأكيد كلمة المرور *'),
          const SizedBox(height: 8),
          _buildTextField(
            hint: '••••••••',
            onChanged: (v) => controller.passwordConfirm = v,
            initialValue: controller.passwordConfirm,
            obscureText: true,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'بيانات الدخول',
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A1A),
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 4),
        Text(
          'الخطوة الأخيرة لتأمين حسابك',
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
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
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
        obscureText: obscureText,
        keyboardType: keyboardType,
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
