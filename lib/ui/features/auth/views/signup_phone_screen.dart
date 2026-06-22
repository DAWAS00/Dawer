import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/l10n.dart';
import '../../../common/green_button.dart';
import '../viewmodels/login_viewmodel.dart';
import 'verification_view.dart';

/// Screen 1 of the phone-first signup flow.
///
/// Collects the phone number, requests an OTP via [LoginViewModel.requestOtp],
/// and on success navigates to [VerificationView] (Screen 2). Role is NOT
/// collected here — the user picks it on Screen 3 after OTP verification.
///
/// Phone input is LTR-forced even in the RTL Arabic layout (the documented
/// FlutterFire #9379 fix for numeric/country-code fields in RTL).
class SignupPhoneScreen extends StatefulWidget {
  const SignupPhoneScreen({super.key});

  @override
  State<SignupPhoneScreen> createState() => _SignupPhoneScreenState();
}

class _SignupPhoneScreenState extends State<SignupPhoneScreen> {
  final _phoneController = TextEditingController();
  bool _touched = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vm = context.watch<LoginViewModel>();

    // Navigate to OTP screen when the viewmodel signals otpSent.
    if (vm.otpSent) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        vm.resetOtpSent();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VerificationView(
              phoneNumber: vm.phone,
              // Role is chosen later on Screen 3; pass neutral defaults.
              initialRole: UserRole.supplier,
              initialSupplierType: SupplierType.individual,
            ),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(l10n.signupTitle, style: GoogleFonts.cairo()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF191C1B),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Header
              Text(
                l10n.signupSubtitle,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  height: 1.5,
                  color: const Color(0xFF404943),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Country code + phone input (LTR-forced).
              Text(
                l10n.signupPhone,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF404943),
                ),
              ),
              const SizedBox(height: 8),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  children: [
                    // Jordan country code prefix (fixed).
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6E9E7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '🇯🇴 +962',
                        style: GoogleFonts.dmSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF191C1B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        maxLength: 9,
                        // 9 digits after stripping the leading 0 (7XXXXXXXX).
                        style: GoogleFonts.dmSans(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: l10n.signupPhoneHint,
                          counterText: '',
                          fillColor: const Color(0xFFE6E9E7),
                          errorText: _touched && _phoneController.text.isEmpty
                              ? l10n.signupPhone
                              : vm.error,
                        ),
                        onChanged: (v) {
                          vm.setPhone(v);
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Helper text.
              Text(
                'سنتحقق من رقمك عبر رسالة نصية',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: const Color(0xFF717973),
                ),
              ),

              const SizedBox(height: 32),

              // Error banner (e.g., rate-limited, invalid format).
              if (vm.error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Text(
                    vm.error!,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              GreenButton(
                text: l10n.loginContinueButton,
                onPressed: () {
                  setState(() => _touched = true);
                  final raw = _phoneController.text.trim();
                  // Normalize to the 07XXXXXXXX format the viewmodel expects.
                  final normalized =
                      raw.startsWith('0') ? raw : '0$raw';
                  vm.setPhone(normalized);
                  vm.requestOtp(normalized);
                },
                isLoading: vm.isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
