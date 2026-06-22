import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/user_role.dart';
import '../../../../domain/services/i_signup_orchestrator.dart';
import '../../../../l10n/l10n.dart';
import '../../../common/green_button.dart';
import '../controllers/signup_controller.dart';
import 'signup_role_details_screen.dart';
import 'widgets/friendly_role_card.dart';
import 'widgets/onboarding_shared_widgets.dart';
import 'widgets/photo_picker_card.dart';

/// Screen 3 of the phone-first signup flow: identity + role.
///
/// Collects a profile photo, the full name, the account role (driver/supplier/
/// recycling co), and — for suppliers — the sub-type (individual/store).
/// On submit, creates the `profiles` row (progressive insert via the signup
/// orchestrator) and navigates to [HomeRouter]. Role-specific details and
/// documents are collected later on Screens 4 & 5 (progressive).
///
/// See `docs/signup-redesign-plan.md`.
class SignupIdentityScreen extends StatelessWidget {
  final String phone;

  const SignupIdentityScreen({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => SignupController(
        orchestrator: ctx.read<ISignupOrchestrator>(),
        phone: phone,
      ),
      child: const _SignupIdentityBody(),
    );
  }
}

class _SignupIdentityBody extends StatefulWidget {
  const _SignupIdentityBody();

  @override
  State<_SignupIdentityBody> createState() => _SignupIdentityBodyState();
}

class _SignupIdentityBodyState extends State<_SignupIdentityBody> {
  late final SignupController _controller;
  late final TextEditingController _nameController;
  File? _photo;

  @override
  void initState() {
    super.initState();
    _controller = context.read<SignupController>();
    _controller.addListener(_onControllerChanged);
    _nameController = TextEditingController()
      ..addListener(() {
        _controller.fullName = _nameController.text;
      });
  }

  void _onControllerChanged() {
    // Navigate to Screen 4 (role details) when identity step succeeds.
    if (_controller.submitted && _controller.session != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SignupRoleDetailsScreen(
              controller: _controller,
              session: _controller.session!,
            ),
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: source, imageQuality: 90);
    if (xfile == null) return;
    final file = File(xfile.path);
    setState(() => _photo = file);
    _controller.profilePhoto = file;
  }

  void _clearPhoto() {
    setState(() => _photo = null);
    _controller.profilePhoto = null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = context.watch<SignupController>();
    final isBusiness = controller.role == UserRole.recyclingCo ||
        (controller.role == UserRole.supplier &&
            controller.supplierType == SupplierType.storeBusiness);

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
              // Header.
              Text(
                'أهلاً بك في دوّر!',
                style: GoogleFonts.cairo(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF191C1B),
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn().slideY(begin: 0.05),
              const SizedBox(height: 8),
              Text(
                'لنبدأ بإنشاء هويتك الرقمية',
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  color: const Color(0xFF404943),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Profile photo.
              Center(
                child: PhotoPickerCard(
                  image: _photo,
                  label: 'الصورة الشخصية',
                  isBusiness: isBusiness,
                  onPick: _pickPhoto,
                  onRemove: _clearPhoto,
                ),
              ),
              const SizedBox(height: 24),

              // Full name.
              OnboardingInputField(
                controller: _nameController,
                label: l10n.signupFullName,
                hint: l10n.signupFullNameHint,
                onChanged: (v) => controller.fullName = v,
                error: controller.fieldErrors['name'],
              ),
              const SizedBox(height: 24),

              // Role selector.
              Text(
                'ما نوع حسابك؟',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF404943),
                ),
              ),
              const SizedBox(height: 12),
              _RoleSelection(controller: controller),
              const SizedBox(height: 16),

              // Supplier sub-type toggle (only for suppliers).
              if (controller.role == UserRole.supplier) ...[
                _SupplierTypeToggle(controller: controller),
                const SizedBox(height: 16),
              ],

              // Field-level error display.
              if (controller.fieldErrors.isNotEmpty) ...[
                ...controller.fieldErrors.values.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      e,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ),
                ),
              ],

              // Top-level error.
              if (controller.error != null) ...[
                const SizedBox(height: 8),
                Text(
                  controller.error!,
                  style: GoogleFonts.cairo(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 32),

              GreenButton(
                text: l10n.signupCreateButton,
                onPressed: () => controller.submitIdentity(),
                isLoading: controller.isSubmitting,
              ),
              const SizedBox(height: 16),

              // "Why we need this" microcopy.
              Text(
                'سيتم استخدام بياناتك لإنشاء حسابك فقط، ولن تُشارك مع أي طرف ثالث.',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: const Color(0xFF717973),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Three role cards: driver / supplier / recycling co.
class _RoleSelection extends StatelessWidget {
  const _RoleSelection({required this.controller});

  final SignupController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FriendlyRoleCard(
          icon: LucideIcons.truck,
          title: 'سائق',
          subtitle: 'توصيل النفايات واستلامها',
          isSelected: controller.role == UserRole.driver,
          onTap: () => controller.updateRole(UserRole.driver),
        ),
        const SizedBox(height: 8),
        FriendlyRoleCard(
          icon: LucideIcons.package,
          title: 'مورد',
          subtitle: 'عرض النفايات القابلة للتدوير',
          isSelected: controller.role == UserRole.supplier,
          onTap: () => controller.updateRole(UserRole.supplier),
        ),
        const SizedBox(height: 8),
        FriendlyRoleCard(
          icon: LucideIcons.factory,
          title: 'شركة تدوير',
          subtitle: 'شراء النفايات ومعالجتها',
          isSelected: controller.role == UserRole.recyclingCo,
          onTap: () => controller.updateRole(UserRole.recyclingCo),
        ),
      ],
    );
  }
}

/// Individual vs store/business toggle for suppliers.
class _SupplierTypeToggle extends StatelessWidget {
  const _SupplierTypeToggle({required this.controller});

  final SignupController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleOption(
              label: 'فرد',
              icon: Icons.person_rounded,
              selected: controller.supplierType == SupplierType.individual,
              onTap: () => controller.setSupplierType(SupplierType.individual),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ToggleOption(
              label: 'متجر / مطعم',
              icon: Icons.storefront_rounded,
              selected:
                  controller.supplierType == SupplierType.storeBusiness,
              onTap: () =>
                  controller.setSupplierType(SupplierType.storeBusiness),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF06402B) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : const Color(0xFF404943),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : const Color(0xFF404943),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
