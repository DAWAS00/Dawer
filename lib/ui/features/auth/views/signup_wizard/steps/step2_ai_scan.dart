import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dwaar/ui/features/auth/controllers/signup_wizard_controller.dart';
import 'package:dwaar/ui/features/auth/views/signup_wizard/fx/laser_scanner.dart';
import 'package:dwaar/ui/features/auth/views/signup_wizard/fx/data_pulse.dart';
import 'package:dwaar/ui/features/auth/views/signup_wizard/fx/extracted_data_card.dart';
import 'package:dwaar/ui/features/auth/viewmodels/license_validation_viewmodel.dart';

class Step2AiScan extends StatelessWidget {
  final SignupWizardController controller;
  const Step2AiScan({super.key, required this.controller});

  Future<void> _pickDoc(ImageSource source) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: source, imageQuality: 90);
    if (xFile != null) {
      controller.startScan(File(xFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = controller.licenseVm;
    final hasDoc = vm.licenseFile != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildHeader(),
          const SizedBox(height: 32),
          
          AspectRatio(
            aspectRatio: 1.6,
            child: GestureDetector(
              onTap: !controller.isScanning ? () => _pickDoc(ImageSource.gallery) : null,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: controller.isScanning ? const Color(0xFF4ADE80) : const Color(0xFFE0E0E0),
                    width: 2,
                  ),
                  image: hasDoc ? DecorationImage(image: FileImage(vm.licenseFile!), fit: BoxFit.cover) : null,
                ),
                child: Stack(
                  children: [
                    if (!hasDoc && !controller.isScanning)
                      const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.badge_outlined, size: 48, color: Color(0xFFBDBDBD)),
                            SizedBox(height: 12),
                            Text('اضغط لرفع وثيقة إثبات الشخصية', style: TextStyle(color: Color(0xFF717973), fontSize: 13)),
                          ],
                        ),
                      ),
                    
                    if (controller.isScanning) ...[
                      const LaserScanner(height: 200),
                      const DataPulseOverlay(active: true),
                    ],

                    if (hasDoc && !controller.isScanning && vm.state == LicenseValidationState.valid)
                      Positioned(
                        top: 12,
                        left: 12,
                        child: const Icon(Icons.check_circle_rounded, color: Color(0xFF4ADE80), size: 32)
                            .animate().scale(duration: 400.ms, curve: Curves.elasticOut),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          if (vm.state == LicenseValidationState.valid && controller.extractedData != null)
            ExtractedDataCard(
              title: 'البيانات المستخرجة',
              fields: {
                'رقم الوثيقة': controller.extractedData!.docId,
                'الجهة المصدرة': controller.extractedData!.organization,
                'تاريخ الانتهاء': controller.extractedData!.expiryDate.toString().split(' ').first,
              },
              score: controller.extractedData!.confidenceScore,
            ).animate().fadeIn().slideY(begin: 0.1),

          if (controller.isScanning)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  'جاري مطابقة البيانات مع السجلات الرسمية...',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF06402B),
                  ),
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true)).fadeOut(duration: 800.ms),

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
          'التحقق الذكي',
          style: GoogleFonts.cairo(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1A1A1A),
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 4),
        Text(
          'قم بمسح وثيقتك الرسمية لتسريع عملية التسجيل',
          style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF6B6B6B)),
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}
