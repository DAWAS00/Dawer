import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../viewmodels/login_viewmodel.dart';
import 'verification_view.dart';
import '../../../../l10n/l10n.dart';

import 'widgets/role_selection_grid.dart';
import 'widgets/login_form.dart';
import 'widgets/footer.dart';
import '../../../../core/services/app_lang_notifier.dart';
import '../../../common/lang_picker_sheet.dart';
import 'restaurant_signup_view.dart';
import 'signup_view.dart';
import '../../home/home_router.dart';
import '../../../../domain/repositories/i_auth_repository.dart';

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

    if (viewModel.quickSession != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final s = viewModel.quickSession!;
        viewModel.resetQuickSession();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => HomeRouter(
              role: s.role,
              supplierType: s.supplierType ?? SupplierType.individual,
              userName: s.userName,
            ),
          ),
          (route) => false,
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
                  const RoleSelectionGrid(),
                  const SizedBox(height: 40),
                  const LoginForm(),
                  const SizedBox(height: 32),
                  
                  // Secondary actions
                  const _DynamicRegisterButton(),
                  const SizedBox(height: 24),

                  // Dev quick-login panel
                  const _DevQuickLoginPanel(),

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

class _DevQuickLoginPanel extends StatefulWidget {
  const _DevQuickLoginPanel();

  @override
  State<_DevQuickLoginPanel> createState() => _DevQuickLoginPanelState();
}

class _DevQuickLoginPanelState extends State<_DevQuickLoginPanel> {
  bool _expanded = false;

  static const _users = [
    (
      label: 'Driver',
      sublabel: 'أحمد السائق',
      icon: Icons.local_shipping_rounded,
      session: AuthSession(
        userId: 'm-driver-123',
        userName: 'أحمد السائق (تجريبي)',
        role: UserRole.driver,
      ),
    ),
    (
      label: 'Supplier (Individual)',
      sublabel: 'خالد المورد',
      icon: Icons.person_rounded,
      session: AuthSession(
        userId: 'm-supp-456',
        userName: 'خالد المورد (فردي)',
        role: UserRole.supplier,
        supplierType: SupplierType.individual,
      ),
    ),
    (
      label: 'Restaurant / Business',
      sublabel: 'مطعم أبو علي',
      icon: Icons.restaurant_rounded,
      session: AuthSession(
        userId: 'm-store-789',
        userName: 'مطعم أبو علي (تجاري)',
        role: UserRole.supplier,
        supplierType: SupplierType.storeBusiness,
      ),
    ),
    (
      label: 'Recycling Co',
      sublabel: 'شركة تدويركم',
      icon: Icons.recycling_rounded,
      session: AuthSession(
        userId: 'm-recy-000',
        userName: 'شركة تدويركم (تجريبي)',
        role: UserRole.recyclingCo,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final vm = context.read<LoginViewModel>();
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF06402B).withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.developer_mode_rounded, size: 16, color: Color(0xFF06402B)),
                const SizedBox(width: 6),
                Text(
                  'DEV — Quick Login',
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF06402B),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  size: 16,
                  color: const Color(0xFF06402B),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: _expanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: _users.map((u) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => vm.quickLogin(u.session),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFDDE3DD)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFC3EAC4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(u.icon, size: 18, color: const Color(0xFF06402B)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        u.label,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF191C1B),
                                        ),
                                      ),
                                      Text(
                                        u.sublabel,
                                        style: GoogleFonts.cairo(
                                          fontSize: 11,
                                          color: const Color(0xFF717973),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF9099A2)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _DynamicRegisterButton extends StatelessWidget {
  const _DynamicRegisterButton();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    final l10n = context.l10n;

    final (label, icon, destination) = switch (viewModel.selectedRole) {
      UserRole.driver => (
          l10n.registerAsDriver,
          Icons.local_shipping_rounded,
          const SignUpView(
            role: UserRole.driver,
            supplierType: SupplierType.individual,
          ),
        ),
      UserRole.recyclingCo => (
          l10n.registerAsRecyclingCo,
          Icons.recycling_rounded,
          const SignUpView(
            role: UserRole.recyclingCo,
            supplierType: SupplierType.individual,
          ),
        ),
      UserRole.supplier => viewModel.supplierType == SupplierType.storeBusiness
          ? (
              l10n.registerAsStore,
              Icons.storefront_rounded,
              const RestaurantSignupView(),
            )
          : (
              l10n.registerAsIndividual,
              Icons.person_rounded,
              const SignUpView(
                role: UserRole.supplier,
                supplierType: SupplierType.individual,
              ),
            ),
    };

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
