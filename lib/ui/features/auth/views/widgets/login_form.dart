import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../common/green_button.dart';
import '../../../../../l10n/l10n.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../signup_wizard_view.dart';
import 'supplier_portal_selector.dart';

class LoginForm extends StatelessWidget {
  // [CHANGE] Login validation has been disabled in the ViewModel to allow bypassing checks.
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    final l10n = context.l10n;

    // For supplier role: show credentials only once a sub-type is chosen.
    final showCredentials = viewModel.selectedRole != UserRole.supplier ||
        viewModel.supplierType != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Portal selector — only for Supplier role
        if (viewModel.selectedRole == UserRole.supplier) ...[
          const SupplierPortalSelector(),
          const SizedBox(height: 20),
        ],

        // Credentials — animate in when supplier sub-type is chosen
        AnimatedSize(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
          child: showCredentials
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _EmailField(
                      label: l10n.loginEmailLabel,
                      hint: l10n.loginEmailHint,
                      onChanged: viewModel.setEmail,
                    ),
                    const SizedBox(height: 16),
                    _PasswordField(
                      onChanged: viewModel.setPassword,
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () => viewModel.requestPasswordReset(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          l10n.forgotPasswordLink,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: const Color(0xFF06402B),
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: const Color(0xFF06402B),
                          ),
                        ),
                      ),
                    ),
                    if (viewModel.error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        viewModel.error!,
                        style: GoogleFonts.cairo(
                          color: AppColors.statusCancelledText,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                    const SizedBox(height: 24),
                    GreenButton(
                      text: l10n.loginButton,
                      onPressed: () => viewModel.signIn(),
                      isLoading: viewModel.isLoading,
                      borderRadius: 14,
                      leadingIcon: const Icon(
                        Icons.login_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _navigateToSignUp(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.loginNoAccount,
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                color: const Color(0xFF717973),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.loginSignUpNow,
                              style: GoogleFonts.cairo(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF06402B),
                                decoration: TextDecoration.underline,
                                decorationColor: const Color(0xFF06402B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  void _navigateToSignUp(BuildContext context) {
    final vm = context.read<LoginViewModel>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SignUpWizardView(
          initialRole: vm.selectedRole,
          initialSupplierType: vm.supplierType ?? SupplierType.individual,
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;

  const _EmailField({
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
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
          child: TextField(
            key: const ValueKey('email_input'),
            onChanged: onChanged,
            keyboardType: TextInputType.emailAddress,
            textAlign: isEnglish ? TextAlign.left : TextAlign.left,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.dmSans(
                fontSize: 16,
                color: const Color(0xFF6B7280).withValues(alpha: 0.5),
              ),
              prefixIcon: const Icon(
                Icons.email_outlined,
                color: Color(0xFF9099A2),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 16),
            ),
            style: GoogleFonts.dmSans(
              fontSize: 16,
              color: const Color(0xFF191C1B),
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const _PasswordField({required this.onChanged});

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          l10n.loginPasswordLabel,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF404943),
          ),
          textAlign: TextAlign.right,
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
                  _obscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF6B7280),
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              ),
              Expanded(
                child: TextField(
                  onChanged: widget.onChanged,
                  obscureText: _obscured,
                  textAlign: isEnglish ? TextAlign.left : TextAlign.right,
                  textDirection: isEnglish ? TextDirection.ltr : null,
                  decoration: InputDecoration(
                    hintText: l10n.loginPasswordHint,
                    hintStyle: GoogleFonts.cairo(
                      fontSize: 14,
                      color: const Color(0xFF6B7280).withValues(alpha: 0.6),
                    ),
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
