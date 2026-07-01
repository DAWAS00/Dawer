import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../viewmodels/login_viewmodel.dart';
import 'verification_view.dart';
import '../../../../l10n/l10n.dart';

import 'widgets/login_form.dart';
import 'widgets/footer.dart';
import '../../../../core/services/app_lang_notifier.dart';
import '../../../common/lang_picker_sheet.dart';
import 'signup_phone_screen.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LoginScreen();
  }
}

class _LoginScreen extends StatelessWidget {
  const _LoginScreen();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    if (viewModel.otpSent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final phone = viewModel.phone;
        final initialRole = viewModel.selectedRole;
        final initialSupplierType = viewModel.supplierType;

        viewModel.resetOtpSent();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VerificationView(
              phoneNumber: phone,
              initialRole: initialRole,
              initialSupplierType: initialSupplierType,
            ),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: Stack(
        children: [
          // Background soft shapes for a friendly feel
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                color: const Color(0xFFC3EAC4).withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9).withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  // Welcoming Header
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/LoginScreenPhoto.png',
                          height: 160,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.eco_rounded,
                            size: 80,
                            color: Color(0xFF06402B),
                          ),
                        ).animate().fadeIn(duration: 600.ms).scale(
                              begin: const Offset(0.9, 0.9),
                              curve: Curves.easeOutBack,
                            ),
                        const SizedBox(height: 24),
                        Text(
                          context.l10n.appTitle,
                          style: GoogleFonts.cairo(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF06402B),
                            letterSpacing: -0.5,
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                        Text(
                          context.l10n.appTagline,
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF446649),
                          ),
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Main Interaction Sections
                  const LoginForm(),
                  const SizedBox(height: 32),

                  // Secondary actions
                  const _DynamicRegisterButton(),

                  const SizedBox(height: 40),
                  const LoginFooter(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          const _LangToggleButton(),
        ],
      ),
    );
  }
}

class _DynamicRegisterButton extends StatelessWidget {
  const _DynamicRegisterButton();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Phone-first signup: the user enters their phone, verifies via OTP, then
    // picks their role + name on Screen 3. See docs/signup-redesign-plan.md.
    final label = l10n.loginSignUpNow;
    final icon = Icons.person_add_rounded;
    const destination = SignupPhoneScreen();

    return Center(
      child: TextButton.icon(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => destination,
            ),
          );
        },
        icon: Icon(icon),
        label: Text(
          label,
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
        ),
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF06402B),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          backgroundColor: const Color(0xFF06402B).withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class _LangToggleButton extends StatelessWidget {
  const _LangToggleButton();

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<AppLangNotifier>().locale.languageCode == 'ar';
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GestureDetector(
              onTap: () => showLangPickerSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF06402B).withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.language_rounded,
                      size: 14,
                      color: Color(0xFF06402B),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isAr ? 'EN' : 'عر',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF06402B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
