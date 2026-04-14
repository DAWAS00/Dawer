import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../viewmodels/login_viewmodel.dart';
import 'verification_view.dart';

import 'widgets/role_selection_grid.dart';
import 'widgets/login_form.dart';
import 'widgets/footer.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the ViewModel to this screen and its children
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: const _LoginScreen(),
    );
  }
}

class _LoginScreen extends StatelessWidget {
  const _LoginScreen();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    if (viewModel.verificationSent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        viewModel.resetVerificationSent();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VerificationView(
              destination: viewModel.currentInput,
              isEmail: viewModel.isEmailMethod,
              role: viewModel.selectedRole,
              supplierType: viewModel.supplierType,
              userName: viewModel.currentInput,
            ),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: SafeArea(
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
                      'نظام إدارة تدوير النفايات الذكي',
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
                  children: const [
                    RoleSelectionGrid(),
                    SizedBox(height: 32),
                    LoginForm(),
                  ],
                ),
              ),

              // Footer
              const LoginFooter(),
            ],
          ),
        ),
      ),
    );
  }
}
