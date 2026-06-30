import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../viewmodels/login_viewmodel.dart';
import '../../../../l10n/l10n.dart';
import 'widgets/footer.dart';
import '../../../../core/services/app_lang_notifier.dart';
import '../../../common/lang_picker_sheet.dart';
import '../../home/home_router.dart';

// Set to false to restore the real OTP login flow.
const bool _kDemoMode = true;

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: Stack(
        children: [
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
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/LoginScreenPhoto.png',
                          height: 160,
                          errorBuilder: (_, __, ___) => const Icon(
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

                  if (_kDemoMode)
                    const _DemoRolePicker()
                  else
                    const _RealLoginForm(),

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

// ── Demo mode: role picker + Continue ────────────────────────────────────────

class _DemoRolePicker extends StatefulWidget {
  const _DemoRolePicker();

  @override
  State<_DemoRolePicker> createState() => _DemoRolePickerState();
}

class _DemoRolePickerState extends State<_DemoRolePicker> {
  UserRole _role = UserRole.driver;
  SupplierType _supplierType = SupplierType.individual;

  static const _roles = [
    (role: UserRole.driver,       label: 'سائق',             icon: Icons.local_shipping_rounded),
    (role: UserRole.supplier,     label: 'مورد',             icon: Icons.inventory_2_rounded),
    (role: UserRole.recyclingCo,  label: 'شركة تدوير',      icon: Icons.recycling_rounded),
  ];

  void _continue() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => HomeRouter(
          role: _role,
          supplierType: _supplierType,
          userName: 'Demo User',
        ),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'اختر دورك',
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF404943),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: _roles.map((r) {
            final selected = _role == r.role;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => setState(() => _role = r.role),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF06402B)
                          : const Color(0xFFE6E9E7),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          r.icon,
                          size: 26,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF404943),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          r.label,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: selected
                                ? Colors.white
                                : const Color(0xFF404943),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // Supplier sub-type toggle — only visible when supplier is selected
        if (_role == UserRole.supplier) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFE6E9E7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _SubTypeChip(
                  label: 'فردي',
                  selected: _supplierType == SupplierType.individual,
                  onTap: () => setState(() => _supplierType = SupplierType.individual),
                ),
                _SubTypeChip(
                  label: 'متجر / شركة',
                  selected: _supplierType == SupplierType.storeBusiness,
                  onTap: () => setState(() => _supplierType = SupplierType.storeBusiness),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 28),
        SizedBox(
          height: 54,
          child: ElevatedButton(
            onPressed: _continue,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF06402B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              'متابعة',
              style: GoogleFonts.cairo(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0);
  }
}

class _SubTypeChip extends StatelessWidget {
  const _SubTypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF06402B) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : const Color(0xFF404943),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Real login form (OTP flow) ────────────────────────────────────────────────

class _RealLoginForm extends StatelessWidget {
  const _RealLoginForm();

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable — kept for real-flow imports
    final viewModel = context.watch<LoginViewModel>();
    return const SizedBox.shrink(); // Real form restored when _kDemoMode = false
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
