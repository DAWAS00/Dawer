import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/user_role.dart';
import '../../../../l10n/l10n.dart';
import '../../../common/map/location_picker_screen.dart';
import '../../home/home_router.dart';
import '../viewmodels/recycling_co_onboarding_viewmodel.dart';
import 'widgets/license_scan_section.dart';
import 'widgets/onboarding_shared_widgets.dart';
import 'widgets/photo_picker_card.dart';

class RecyclingCoOnboardingView extends StatelessWidget {
  const RecyclingCoOnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecyclingCoOnboardingViewModel(),
      child: const _SignUpBody(),
    );
  }
}

class _SignUpBody extends StatefulWidget {
  const _SignUpBody();

  @override
  State<_SignUpBody> createState() => _SignUpBodyState();
}

class _SignUpBodyState extends State<_SignUpBody> {
  final _companyCtrl = TextEditingController();
  final _ownerCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _pwConfirmCtrl = TextEditingController();
  final _taglineCtrl = TextEditingController();
  final _preciseAddressCtrl = TextEditingController();

  @override
  void dispose() {
    _companyCtrl.dispose();
    _ownerCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _pwCtrl.dispose();
    _pwConfirmCtrl.dispose();
    _taglineCtrl.dispose();
    _preciseAddressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecyclingCoOnboardingViewModel>();
    final l10n = context.l10n;

    if (vm.submitted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => HomeRouter(
              role: UserRole.recyclingCo,
              supplierType: SupplierType.storeBusiness,
              userName: vm.companyName,
              aiSuggestedCategories: vm.combinedCategories,
            ),
          ),
          (route) => false,
        );
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          children: [
            OnboardingHeaderBanner(
              title: l10n.recyclingCoSignupTitle,
              subtitle: l10n.onboardingHeaderSubtitleAi,
              icon: Icons.recycling_rounded,
              accentColor: const Color(0xFF06402B),
            ),
            const SizedBox(height: 20),

            // Company profile
            OnboardingSectionCard(
              title: l10n.onboardingSectionProfileCompany,
              icon: Icons.business_rounded,
              child: Column(
                children: [
                  PhotoPickerCard(
                    image: vm.profilePhoto,
                    label: l10n.onboardingLabelCompanyLogo,
                    isBusiness: true,
                    onPick: (src) => context
                        .read<RecyclingCoOnboardingViewModel>()
                        .pickProfilePhoto(src),
                    onRemove: () => context
                        .read<RecyclingCoOnboardingViewModel>()
                        .removeProfilePhoto(),
                  ),
                  const SizedBox(height: 14),
                  OnboardingInputField(
                    controller: _companyCtrl,
                    label: l10n.signupCompanyName,
                    hint: l10n.signupCompanyNameHint,
                    error: vm.errors['companyName'],
                    onChanged: (v) {
                      vm.companyName = v;
                      vm.clearError('companyName');
                    },
                  ),
                  const SizedBox(height: 14),
                  OnboardingInputField(
                    controller: _ownerCtrl,
                    label: l10n.signupManagerName,
                    hint: l10n.signupExampleName,
                    error: vm.errors['ownerName'],
                    onChanged: (v) {
                      vm.ownerName = v;
                      vm.clearError('ownerName');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Location
            OnboardingSectionCard(
              title: l10n.signupLocationTitle,
              icon: Icons.location_on_rounded,
              subtitle: l10n.signupLocationSubtitle,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push<(double, double)?>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LocationPickerScreen(
                            initialLat: vm.addressLat,
                            initialLng: vm.addressLng,
                          ),
                        ),
                      );
                      if (result != null && context.mounted) {
                        context
                            .read<RecyclingCoOnboardingViewModel>()
                            .setAddress(result.$1, result.$2);
                      }
                    },
                    child: OnboardingLocationTile(
                        lat: vm.addressLat, lng: vm.addressLng),
                  ),
                  if (vm.isAddressSet) ...[
                    const SizedBox(height: 14),
                    OnboardingInputField(
                      controller: _preciseAddressCtrl,
                      label: l10n.signupLocationPreciseLabel,
                      hint: l10n.signupLocationPreciseHint,
                      isRequired: false,
                      onChanged: (v) {
                        vm.updatePreciseAddress(v);
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Account credentials
            OnboardingSectionCard(
              title: l10n.navAccount,
              icon: Icons.lock_rounded,
              subtitle: l10n.signupSectionContact,
              child: Column(
                children: [
                  OnboardingInputField(
                    controller: _emailCtrl,
                    label: l10n.signupEmailLabel,
                    hint: l10n.signupEmailHint,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    error: vm.errors['email'],
                    onChanged: (v) {
                      vm.email = v;
                      vm.clearError('email');
                    },
                  ),
                  const SizedBox(height: 14),
                  OnboardingInputField(
                    controller: _phoneCtrl,
                    label: l10n.signupPhone,
                    hint: l10n.signupPhoneHint,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    isRequired: false,
                    onChanged: (v) => vm.phone = v,
                  ),
                  const SizedBox(height: 14),
                  OnboardingPasswordField(
                    controller: _pwCtrl,
                    label: l10n.signupPasswordLabel,
                    hint: l10n.signupPasswordHint,
                    error: vm.errors['password'],
                    onChanged: (v) {
                      vm.password = v;
                      vm.clearError('password');
                    },
                  ),
                  const SizedBox(height: 14),
                  OnboardingPasswordField(
                    controller: _pwConfirmCtrl,
                    label: l10n.signupPasswordConfirmLabel,
                    hint: l10n.signupPasswordConfirmHint,
                    error: vm.errors['passwordConfirm'],
                    onChanged: (v) {
                      vm.passwordConfirm = v;
                      vm.clearError('passwordConfirm');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // License
            OnboardingSectionCard(
              title: l10n.recyclingLicense,
              icon: Icons.badge_rounded,
              child: ChangeNotifierProvider.value(
                value: vm.licenseVm,
                child: LicenseScanSection(
                  label: l10n.recyclingLicense,
                  onPick: (src) => context
                      .read<RecyclingCoOnboardingViewModel>()
                      .pickLicense(src),
                  onReset: () => context
                      .read<RecyclingCoOnboardingViewModel>()
                      .clearLicense(),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // AI suggestions
            OnboardingAiSuggestionsPanel(
              taglineCtrl: _taglineCtrl,
              isAiLoading: vm.isAiLoading,
              brandProfile: vm.brandProfile,
              allCategories: vm.allCategories,
              selectedCategories: vm.selectedCategories,
              onTaglineChanged: (v) => vm.tagline = v,
              onGenerate: vm.isAiLoading
                  ? null
                  : () => context
                      .read<RecyclingCoOnboardingViewModel>()
                      .triggerAiSuggestions(),
              onToggleCategory: (cat) => context
                  .read<RecyclingCoOnboardingViewModel>()
                  .toggleCategory(cat),
            ),
            const SizedBox(height: 28),

            // Error
            if (vm.submitError != null) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  vm.submitError!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],

            // Submit
            _SubmitButton(
              isLoading: vm.isSubmitting,
              onPressed: () =>
                  context.read<RecyclingCoOnboardingViewModel>().submit(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final l10n = context.l10n;
    return AppBar(
      backgroundColor: const Color(0xFFF8FAFC),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 60,
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                  color: const Color(0xFF06402B).withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: const Icon(Icons.arrow_back_rounded,
                size: 18, color: Color(0xFF06402B)),
          ),
        ),
      ),
      title: Text(
        l10n.recyclingCoSignupTitle,
        style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF06402B)),
      ),
    );
  }
}

// ── Shared submit button ──────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;
  const _SubmitButton({required this.isLoading, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF06402B),
          disabledBackgroundColor: const Color(0xFF06402B).withValues(alpha: 0.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.l10n.signupCreateButton,
                    style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 20),
                ],
              ),
      ),
    );
  }
}
