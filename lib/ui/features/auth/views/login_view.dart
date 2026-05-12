import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:go_router/go_router.dart';
import '../viewmodels/login_viewmodel.dart';
import '../../../../l10n/l10n.dart';

import 'widgets/role_selection_grid.dart';
import 'widgets/login_form.dart';
import 'widgets/footer.dart';
import '../../../../core/services/app_lang_notifier.dart';
import '../../../common/lang_picker_sheet.dart';
import 'restaurant_signup_view.dart';

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

    if (viewModel.signedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.resetSignedIn();
        context.go('/home');
      });
    }

    if (viewModel.otpSent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final phone = viewModel.phone;
        viewModel.resetOtpSent();
        context.push('/login/verify', extra: phone);
      });
    }

    if (viewModel.passwordResetRequested) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final email = viewModel.email;
        viewModel.resetPasswordResetRequested();
        context.push('/login/forgot', extra: email);
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
          child: Column(
            children: [
              // Top Branding Section
              SizedBox(
                height: 250,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/LoginScreenPhoto.png',
                      height: 140,
                      errorBuilder: (context, error, stackTrace) => const SizedBox(
                        height: 140,
                        child: Center(
                          child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.appSystemTitle,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF446649).withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),

              // Main Form Container
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const RoleSelectionGrid(),
                    const SizedBox(height: 32),
                    const LoginForm(),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RestaurantSignupView(),
                          ),
                        );
                      }, // TODO(Sprint2): replace with context.push('/signup/restaurant')
                      icon: const Icon(Icons.storefront),
                      label: const Text('Register as Restaurant / Company'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF06402B),
                      ),
                    ),
                  ],
                ),
              ),

              // Footer
              const LoginFooter(),
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
