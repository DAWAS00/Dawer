import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../domain/repositories/i_auth_repository.dart';
import '../../../common/green_button.dart';
import '../viewmodels/verification_viewmodel.dart';

class VerificationView extends StatelessWidget {
  final String phoneNumber;

  const VerificationView({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => VerificationViewModel(
        authRepository: context.read<IAuthRepository>(),
        phoneNumber: phoneNumber,
      ),
      child: const _VerificationScreen(),
    );
  }
}

class _VerificationScreen extends StatelessWidget {
  const _VerificationScreen();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VerificationViewModel>();

    if (viewModel.verified) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/home');
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('تأكيد الرمز', style: GoogleFonts.cairo()),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'أدخل رمز التحقق المرسل إلى الرقم\n${viewModel.phoneNumber}',
              style: GoogleFonts.cairo(fontSize: 16, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              onChanged: viewModel.setOtp,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: GoogleFonts.dmSans(
                fontSize: 24,
                letterSpacing: 8,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: const Color(0xFFE6E9E7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (viewModel.error != null) ...[
              const SizedBox(height: 16),
              Text(
                viewModel.error!,
                style: GoogleFonts.cairo(
                  color: AppColors.statusCancelledText,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            GreenButton(
              text: 'تأكيد الرمز',
              onPressed: () => viewModel.verify(),
              isLoading: viewModel.isLoading,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: viewModel.isLoading ? null : () => viewModel.resendOtp(),
              child: Text(
                'إعادة إرسال الرمز',
                style: GoogleFonts.cairo(
                  color: const Color(0xFF06402B),
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
