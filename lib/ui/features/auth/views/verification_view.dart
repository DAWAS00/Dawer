import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../data/models/user_role.dart';
import '../../../../domain/repositories/i_auth_repository.dart';
import '../../../../l10n/l10n.dart';
import '../../../common/green_button.dart';
import '../../home/home_router.dart';
import '../viewmodels/verification_viewmodel.dart';
import 'signup_identity_screen.dart';

class VerificationView extends StatelessWidget {
  final String phoneNumber;
  final UserRole initialRole;
  final SupplierType? initialSupplierType;

  const VerificationView({
    super.key,
    required this.phoneNumber,
    required this.initialRole,
    this.initialSupplierType,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => VerificationViewModel(
        authRepository: context.read<IAuthRepository>(),
        phoneNumber: phoneNumber,
      ),
      child: _VerificationScreen(
        initialRole: initialRole,
        initialSupplierType: initialSupplierType,
      ),
    );
  }
}

class _VerificationScreen extends StatelessWidget {
  final UserRole initialRole;
  final SupplierType? initialSupplierType;

  const _VerificationScreen({
    required this.initialRole,
    this.initialSupplierType,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VerificationViewModel>();
    final l10n = context.l10n;

    if (viewModel.verified) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => HomeRouter(
              role: viewModel.session!.role,
              supplierType:
                  viewModel.session!.supplierType ?? SupplierType.individual,
              userName: viewModel.session!.userName,
            ),
          ),
          (route) => false,
        );
      });
    } else if (viewModel.needsSignup) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => SignupIdentityScreen(phone: viewModel.phoneNumber),
          ),
        );
      });
    }

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 64,
      textStyle: GoogleFonts.dmSans(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF191C1B),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E9E7),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.otpTitle, style: GoogleFonts.cairo()),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: context.dt.onSurface,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.otpSubtitle(viewModel.phoneNumber),
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  height: 1.5,
                  color: const Color(0xFF404943),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.otpSimulatedHint,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: const Color(0xFF717973),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Pinput(
                  length: 6,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: defaultPinTheme.copyWith(
                    decoration: defaultPinTheme.decoration!.copyWith(
                      border: Border.all(
                        color: const Color(0xFF06402B),
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: viewModel.setOtp,
                  onCompleted: (_) => viewModel.verify(),
                  autofocus: true,
                ),
              ),
              if (viewModel.error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _translateError(viewModel.error!, l10n),
                  style: GoogleFonts.cairo(
                    color: AppColors.statusCancelledText,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 32),
              GreenButton(
                text: l10n.otpVerifyButton,
                onPressed: () => viewModel.verify(),
                isLoading: viewModel.isLoading,
                borderRadius: 14,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () => viewModel.resendOtp(),
                child: Text(
                  l10n.otpResendButton,
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
      ),
    );
  }

  String _translateError(String errorKey, AppLocalizations l10n) {
    if (errorKey == 'otpErrorIncomplete') return l10n.otpErrorIncomplete;
    if (errorKey == 'otpResentMessage') return l10n.otpResentMessage;
    return errorKey;
  }
}
