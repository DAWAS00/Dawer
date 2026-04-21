import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../viewmodels/login_viewmodel.dart';
import '../viewmodels/signup_viewmodel.dart';
import '../../../../l10n/l10n.dart';
import '../../../common/green_button.dart';
import 'verification_view.dart';
import 'widgets/footer.dart';
import 'widgets/photo_picker_card.dart';
import 'widgets/identity_upload_card.dart';

class SignUpView extends StatelessWidget {
  final UserRole role;
  final SupplierType supplierType;

  const SignUpView({
    super.key,
    required this.role,
    required this.supplierType,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignUpViewModel(role: role, supplierType: supplierType),
      child: const _SignUpScreen(),
    );
  }
}

class _SignUpScreen extends StatefulWidget {
  const _SignUpScreen();

  @override
  State<_SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<_SignUpScreen> {
  final _fullNameCtrl = TextEditingController();
  final _businessNameCtrl = TextEditingController();
  final _ownerManagerCtrl = TextEditingController();
  final _coverageCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _businessNameCtrl.dispose();
    _ownerManagerCtrl.dispose();
    _coverageCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SignUpViewModel>();
    final l10n = context.l10n;

    if (vm.submitted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        vm.resetSubmitted();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => VerificationView(
              destination: vm.contactPhone.isNotEmpty
                  ? vm.contactPhone
                  : vm.contactEmail,
              isEmail: vm.contactPhone.isEmpty,
              role: vm.role,
              supplierType: vm.supplierType,
              userName: vm.isBusinessRole
                  ? vm.businessName
                  : vm.fullName,
            ),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: _buildAppBar(context, vm),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          children: [
            _buildHeroCard(context, vm),
            const SizedBox(height: 20),
            _buildPhotoSection(context, vm),
            const SizedBox(height: 20),
            _buildInfoSection(context, vm),
            const SizedBox(height: 20),
            _buildIdentitySection(context, vm),
            const SizedBox(height: 20),
            _buildContactSection(context, vm),
            const SizedBox(height: 28),
            GreenButton(
              text: l10n.signupCreateButton,
              onPressed: () => context.read<SignUpViewModel>().submit(),
              isLoading: vm.isLoading,
              height: 58,
              borderRadius: 16,
              trailingIcon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            const LoginFooter(),
          ],
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context, SignUpViewModel vm) {
    final l10n = context.l10n;
    return AppBar(
      backgroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFF06402B).withValues(alpha: 0.12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: Color(0xFF06402B),
            ),
          ),
        ),
      ),
      title: Text(
        l10n.signupTitle,
        style: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF06402B),
          letterSpacing: -0.45,
        ),
      ),
    );
  }

  // ── Hero ────────────────────────────────────────────────────────────────────

  Widget _buildHeroCard(BuildContext context, SignUpViewModel vm) {
    final l10n = context.l10n;
    final (IconData icon, Color bg) = switch (vm.role) {
      UserRole.driver => (Icons.local_shipping_rounded, const Color(0xFFC3EAC4)),
      UserRole.supplier when vm.supplierType == SupplierType.storeBusiness =>
        (Icons.storefront_rounded, const Color(0xFFD4EBAB)),
      UserRole.supplier => (Icons.inventory_2_rounded, const Color(0xFFC3EAC4)),
      UserRole.recyclingCo => (Icons.recycling_rounded, const Color(0xFFD4EBAB)),
    };

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF06402B), Color(0xFF0A5E3E)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  vm.roleTitle,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.signupSubtitle,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: bg.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  // ── Photo section ───────────────────────────────────────────────────────────

  Widget _buildPhotoSection(BuildContext context, SignUpViewModel vm) {
    return _SectionCard(
      title: vm.photoLabel,
      icon: Icons.photo_camera_rounded,
      child: PhotoPickerCard(
        image: vm.profilePhoto,
        label: vm.photoLabel,
        isBusiness: vm.isBusinessRole,
        onPick: (source) => context.read<SignUpViewModel>().pickProfilePhoto(source),
        onRemove: () => context.read<SignUpViewModel>().removeProfilePhoto(),
      ),
    );
  }

  // ── Info section (role-specific text fields) ─────────────────────────────

  Widget _buildInfoSection(BuildContext context, SignUpViewModel vm) {
    final l10n = context.l10n;
    if (vm.isBusinessRole) {
      return _SectionCard(
        title: l10n.signupSectionBusiness,
        icon: Icons.business_rounded,
        child: Column(
          children: [
            _InputField(
              controller: _businessNameCtrl,
              label: vm.role == UserRole.recyclingCo
                  ? l10n.signupCompanyName
                  : l10n.signupStoreName,
              hint: vm.role == UserRole.recyclingCo
                  ? l10n.signupCompanyNameHint
                  : l10n.signupStoreNameHint,
              error: vm.errors['businessName'],
              onChanged: (v) {
                context.read<SignUpViewModel>().businessName = v;
                context.read<SignUpViewModel>().clearError('businessName');
              },
            ),
            const SizedBox(height: 16),
            _InputField(
              controller: _ownerManagerCtrl,
              label: vm.role == UserRole.recyclingCo ? l10n.signupManagerName : l10n.signupStoreOwnerName,
              hint: l10n.signupExampleName,
              error: vm.errors['ownerOrManagerName'],
              onChanged: (v) {
                context.read<SignUpViewModel>().ownerOrManagerName = v;
                context.read<SignUpViewModel>().clearError('ownerOrManagerName');
              },
            ),
            if (vm.role == UserRole.recyclingCo) ...[
              const SizedBox(height: 16),
              _InputField(
                controller: _coverageCtrl,
                label: l10n.signupCoverageArea,
                hint: l10n.signupCoverageHint,
                isRequired: false,
                onChanged: (v) {
                  context.read<SignUpViewModel>().coverageArea = v;
                },
              ),
            ],
          ],
        ),
      );
    }

    // Personal info (driver / individual supplier)
    return _SectionCard(
      title: l10n.signupSectionPersonal,
      icon: Icons.person_rounded,
      child: Column(
        children: [
          _InputField(
            controller: _fullNameCtrl,
            label: l10n.signupFullName,
            hint: l10n.signupFullNameHint,
            error: vm.errors['fullName'],
            onChanged: (v) {
              context.read<SignUpViewModel>().fullName = v;
              context.read<SignUpViewModel>().clearError('fullName');
            },
          ),
          const SizedBox(height: 16),
          // Nationality chip selector
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    l10n.signupNationality,
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF404943),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _NationalityChip(
                    label: l10n.signupOther,
                    isSelected: vm.nationality == 'غير ذلك',
                    onTap: () => context
                        .read<SignUpViewModel>()
                        .setNationality('غير ذلك'),
                  ),
                  const SizedBox(width: 10),
                  _NationalityChip(
                    label: l10n.signupJordanian,
                    isSelected: vm.nationality == 'أردني',
                    onTap: () => context
                        .read<SignUpViewModel>()
                        .setNationality('أردني'),
                    isDefault: true,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Identity document section ─────────────────────────────────────────────

  Widget _buildIdentitySection(BuildContext context, SignUpViewModel vm) {
    final l10n = context.l10n;
    return _SectionCard(
      title: l10n.signupSectionDocuments,
      icon: Icons.badge_rounded,
      child: IdentityUploadCard(
        document: vm.identityDocument,
        label: vm.idDocLabel,
        error: vm.errors['identityDocument'],
        onPick: (source) =>
            context.read<SignUpViewModel>().pickIdentityDocument(source),
        onRemove: () =>
            context.read<SignUpViewModel>().removeIdentityDocument(),
      ),
    );
  }

  // ── Contact section ──────────────────────────────────────────────────────

  Widget _buildContactSection(BuildContext context, SignUpViewModel vm) {
    final l10n = context.l10n;
    return _SectionCard(
      title: l10n.signupSectionContact,
      icon: Icons.contact_phone_rounded,
      subtitle: l10n.signupContactRequired,
      child: Column(
        children: [
          _InputField(
            controller: _phoneCtrl,
            label: l10n.signupPhone,
            hint: l10n.signupPhoneHint,
            keyboardType: TextInputType.phone,
            prefixText: '+962  ',
            isRequired: false,
            onChanged: (v) {
              context.read<SignUpViewModel>().contactPhone = v;
              context.read<SignUpViewModel>().clearError('contact');
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Divider(color: const Color(0xFFC0C9C1).withValues(alpha: 0.5))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  l10n.or,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: const Color(0xFF717973),
                  ),
                ),
              ),
              Expanded(child: Divider(color: const Color(0xFFC0C9C1).withValues(alpha: 0.5))),
            ],
          ),
          const SizedBox(height: 16),
          _InputField(
            controller: _emailCtrl,
            label: l10n.signupEmailLabel,
            hint: l10n.signupEmailHint,
            keyboardType: TextInputType.emailAddress,
            isRequired: false,
            onChanged: (v) {
              context.read<SignUpViewModel>().contactEmail = v;
              context.read<SignUpViewModel>().clearError('contact');
            },
          ),
          if (vm.errors['contact'] != null) ...[
            const SizedBox(height: 8),
            Text(
              vm.errors['contact']!,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.red.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Reusable section card ───────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F2),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF002819),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        color: const Color(0xFF717973),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF06402B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: const Color(0xFF06402B)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ── Reusable labelled input ─────────────────────────────────────────────────

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? error;
  final String? prefixText;
  final bool isRequired;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.error,
    this.prefixText,
    this.isRequired = true,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF404943),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: error != null ? Colors.red.shade50 : const Color(0xFFE6E9E7),
            borderRadius: BorderRadius.circular(12),
            border: error != null
                ? Border.all(color: Colors.red.shade300)
                : null,
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textAlign: TextAlign.right,
            onChanged: onChanged,
            style: GoogleFonts.cairo(
              fontSize: 15,
              color: const Color(0xFF191C1B),
            ),
            decoration: InputDecoration(
              hintText: hint,
              prefixText: prefixText,
              prefixStyle: GoogleFonts.dmSans(
                fontSize: 14,
                color: const Color(0xFF717973),
              ),
              hintStyle: GoogleFonts.cairo(
                fontSize: 14,
                color: const Color(0xFF6B7280).withValues(alpha: 0.5),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 4),
          Text(
            error!,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: Colors.red.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}

// ── Nationality chip ────────────────────────────────────────────────────────

class _NationalityChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDefault;
  final VoidCallback onTap;

  const _NationalityChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isDefault = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF06402B) : const Color(0xFFE6E9E7),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF06402B)
                : const Color(0xFFC0C9C1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF404943),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
