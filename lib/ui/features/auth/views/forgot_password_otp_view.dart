import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../domain/repositories/i_auth_repository.dart';
import '../../../../l10n/l10n.dart';
import '../../../common/green_button.dart';
import '../viewmodels/forgot_password_viewmodel.dart';
import 'reset_password_view.dart';

class ForgotPasswordOtpView extends StatelessWidget {
  const ForgotPasswordOtpView({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ForgotPasswordViewModel(
        authRepository: ctx.read<IAuthRepository>(),
      ),
      child: _ForgotPasswordOtpScreen(email: email),
    );
  }
}

class _ForgotPasswordOtpScreen extends StatefulWidget {
  const _ForgotPasswordOtpScreen({required this.email});

  final String email;

  @override
  State<_ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<_ForgotPasswordOtpScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ForgotPasswordViewModel>();
    final l10n = context.l10n;

    if (vm.verified) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        vm.resetVerified();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ResetPasswordView()),
        );
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAF8),
        elevation: 0,
        leading: BackButton(color: const Color(0xFF06402B)),
        title: Text(
          l10n.forgotPasswordOtpTitle,
          style: GoogleFonts.cairo(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF191C1B),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF06402B).withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_read_outlined,
                    size: 40,
                    color: Color(0xFF06402B),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.forgotPasswordOtpSubtitle(widget.email),
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  color: const Color(0xFF404943),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Text(
                l10n.forgotPasswordOtpLabel,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF404943),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE6E9E7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: GoogleFonts.dmSans(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                    color: const Color(0xFF191C1B),
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                  ),
                ),
              ),
              if (vm.error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _localiseError(vm.error!, l10n),
                  style: GoogleFonts.cairo(
                    color: AppColors.statusCancelledText,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              GreenButton(
                text: l10n.forgotPasswordVerifyButton,
                onPressed: vm.isLoading
                    ? null
                    : () => context
                        .read<ForgotPasswordViewModel>()
                        .verifyCode(widget.email, _controller.text),
                isLoading: vm.isLoading,
                borderRadius: 14,
              ),
              const SizedBox(height: 16),
              Center(
                child: vm.canResend
                    ? TextButton(
                        onPressed: () {
                          context
                              .read<ForgotPasswordViewModel>()
                              .resendCode(widget.email);
                        },
                        child: Text(
                          l10n.forgotPasswordResend,
                          style: GoogleFonts.cairo(
                            fontSize: 14,
                            color: const Color(0xFF06402B),
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFF06402B),
                          ),
                        ),
                      )
                    : Text(
                        l10n.forgotPasswordResendIn(vm.resendCountdown),
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _localiseError(String key, dynamic l10n) {
    switch (key) {
      case 'forgotPasswordErrorCodeLength':
        return (l10n as dynamic).forgotPasswordErrorCodeLength as String;
      default:
        return key;
    }
  }
}
