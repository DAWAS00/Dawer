import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../l10n/l10n.dart';
import '../../../common/green_button.dart';
import '../viewmodels/forgot_password_viewmodel.dart';

class ResetPasswordView extends StatelessWidget {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ResetPasswordScreen();
  }
}

class _ResetPasswordScreen extends StatefulWidget {
  const _ResetPasswordScreen();

  @override
  State<_ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<_ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _newObscured = true;
  bool _confirmObscured = true;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ForgotPasswordViewModel>();
    final l10n = context.l10n;

    if (vm.resetDone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        vm.resetResetDone();
        // Pop back to the LoginView (root of this navigation stack).
        Navigator.of(context).popUntil((route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.resetPasswordSuccess,
              style: GoogleFonts.cairo(fontSize: 14),
            ),
            backgroundColor: const Color(0xFF166534),
            duration: const Duration(seconds: 4),
          ),
        );
      });
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAF8),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF8FAF8),
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            l10n.resetPasswordTitle,
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
                      Icons.lock_reset_outlined,
                      size: 40,
                      color: Color(0xFF06402B),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _PasswordInputField(
                  label: l10n.resetPasswordNewLabel,
                  controller: _newPasswordController,
                  obscured: _newObscured,
                  onToggle: () =>
                      setState(() => _newObscured = !_newObscured),
                ),
                const SizedBox(height: 16),
                _PasswordInputField(
                  label: l10n.resetPasswordConfirmLabel,
                  controller: _confirmPasswordController,
                  obscured: _confirmObscured,
                  onToggle: () =>
                      setState(() => _confirmObscured = !_confirmObscured),
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
                const SizedBox(height: 28),
                GreenButton(
                  text: l10n.resetPasswordButton,
                  onPressed: vm.isLoading
                      ? null
                      : () => context.read<ForgotPasswordViewModel>().resetPassword(
                            _newPasswordController.text,
                            _confirmPasswordController.text,
                          ),
                  isLoading: vm.isLoading,
                  borderRadius: 14,
                  leadingIcon: const Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _localiseError(String key, dynamic l10n) {
    switch (key) {
      case 'resetPasswordErrorMinLength':
        return (l10n as dynamic).resetPasswordErrorMinLength as String;
      case 'resetPasswordErrorMismatch':
        return (l10n as dynamic).resetPasswordErrorMismatch as String;
      default:
        return key;
    }
  }
}

class _PasswordInputField extends StatelessWidget {
  const _PasswordInputField({
    required this.label,
    required this.controller,
    required this.obscured,
    required this.onToggle,
  });

  final String label;
  final TextEditingController controller;
  final bool obscured;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF404943),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFE6E9E7),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  obscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF6B7280),
                ),
                onPressed: onToggle,
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscured,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 16),
                  ),
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    color: const Color(0xFF191C1B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
