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
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    controller.phone,
                    textAlign: TextAlign.left,
                    textDirection: TextDirection.ltr,
                    style: GoogleFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildFieldLabel('البريد الإلكتروني'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: TextFormField(
              initialValue: controller.email,
              onChanged: (v) => controller.email = v,
              textAlign: TextAlign.left,
              textDirection: TextDirection.ltr,
              keyboardType: TextInputType.emailAddress,
              style: GoogleFonts.dmSans(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'example@domain.com',
                hintStyle: GoogleFonts.dmSans(color: const Color(0xFFAAAAAA), fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
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
          'بيانات التواصل',
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
}
