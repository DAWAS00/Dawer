import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../common/green_button.dart';
import '../../../../../l10n/l10n.dart';
import '../../viewmodels/login_viewmodel.dart';
import 'supplier_portal_selector.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    final l10n = context.l10n;

    // For supplier role: show credentials only once a sub-type is chosen.
    final showCredentials =
        viewModel.selectedRole != UserRole.supplier ||
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
                    Text(
                      l10n.loginPhoneLabel,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF404943),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.loginPhoneHelp,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: const Color(0xFF717973),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Row(
                        children: [
                          // Jordan country-code badge (fixed, non-editable)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6E9E7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '🇯🇴 +962',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF191C1B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              key: const ValueKey('phone_input'),
                              decoration: InputDecoration(
                                hintText: '7XXXXXXXX',
                                hintStyle: GoogleFonts.dmSans(
                                  fontSize: 16,
                                  color: const Color(
                                    0xFF6B7280,
                                  ).withValues(alpha: 0.5),
                                ),
                                filled: true,
                                fillColor: const Color(0xFFE6E9E7),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                counterText: '',
                              ),
                              keyboardType: TextInputType.phone,
                              maxLength: 9,
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                color: const Color(0xFF191C1B),
                              ),
                              onChanged: (val) {
                                // Normalize to 07XXXXXXXX before storing
                                final normalized = val.startsWith('0')
                                    ? val
                                    : '0$val';
                                viewModel.setPhone(normalized);
                              },
                            ),
                          ),
                        ],
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
                      text: l10n.loginContinueButton,
                      onPressed: () => viewModel.requestOtp(viewModel.phone),
                      isLoading: viewModel.isLoading,
                      borderRadius: 14,
                      leadingIcon: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.loginNewNumberHint,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: const Color(0xFF717973),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
