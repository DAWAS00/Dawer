import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/user_role.dart';
import '../../../../l10n/l10n.dart';
import '../../../common/map/location_picker_screen.dart';
import '../../home/home_router.dart';
import '../viewmodels/store_onboarding_viewmodel.dart';
import 'widgets/identity_upload_card.dart';
import 'widgets/onboarding_shared_widgets.dart';
import 'widgets/photo_picker_card.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// StoreOnboardingView — single-page sign-up for stores / businesses
// Accent: #00695C (dark teal)
// ═══════════════════════════════════════════════════════════════════════════════

const _kAccent = Color(0xFF00695C);

class StoreOnboardingView extends StatelessWidget {
  const StoreOnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoreOnboardingViewModel(),
      child: const _Body(),
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _companyCtrl = TextEditingController();
  final _ownerCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _pwConfirmCtrl = TextEditingController();
  final _taglineCtrl = TextEditingController();

  @override
  void dispose() {
    _companyCtrl.dispose();
    _ownerCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _pwCtrl.dispose();
    _pwConfirmCtrl.dispose();
    _taglineCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StoreOnboardingViewModel>();
    final l10n = context.l10n;

    if (vm.submitted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => HomeRouter(
              role: UserRole.supplier,
              supplierType: SupplierType.storeBusiness,
              userName: vm.companyName,
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
            // 1 · Header
            OnboardingHeaderBanner(
              title: l10n.storeSignupTitle,
              subtitle: l10n.onboardingHeaderSubtitleAi,
              icon: Icons.storefront_rounded,
              accentColor: _kAccent,
            ),
            const SizedBox(height: 20),

            // 2 · Company profile
            OnboardingSectionCard(
              title: l10n.onboardingSectionProfileStore,
              icon: Icons.business_center_rounded,
              child: Column(
                children: [
                  PhotoPickerCard(
                    image: vm.profilePhoto,
                    label: l10n.signupPhotoOrganization,
                    isBusiness: true,
                    onPick: (src) => context
                        .read<StoreOnboardingViewModel>()
                        .pickProfilePhoto(src),
                    onRemove: () => context
                        .read<StoreOnboardingViewModel>()
                        .removeProfilePhoto(),
                  ),
                  const SizedBox(height: 14),
                  OnboardingInputField(
                    controller: _companyCtrl,
                    label: l10n.signupStoreName,
                    hint: l10n.signupStoreNameHint,
                    error: vm.errors['companyName'],
                    onChanged: (v) {
                      vm.companyName = v;
                      vm.clearError('companyName');
                    },
                  ),
                  const SizedBox(height: 14),
                  OnboardingInputField(
                    controller: _ownerCtrl,
                    label: l10n.signupStoreOwnerName,
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

            // 3 · Location
            OnboardingSectionCard(
              title: l10n.signupLocationTitle,
              icon: Icons.location_on_rounded,
              subtitle: l10n.signupLocationSubtitle,
              child: GestureDetector(
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
                        .read<StoreOnboardingViewModel>()
                        .setAddress(result.$1, result.$2);
                  }
                },
                child: OnboardingLocationTile(
                    lat: vm.addressLat, lng: vm.addressLng),
              ),
            ),
            const SizedBox(height: 16),

            // 4 · Account credentials
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

            // 5 · Official documents
            OnboardingSectionCard(
              title: l10n.signupSectionDocuments,
              icon: Icons.badge_rounded,
              child: IdentityUploadCard(
                document: vm.identityDocument,
                label: l10n.signupCommercialRegisterDocument,
                error: null,
                onPick: (src) => context
                    .read<StoreOnboardingViewModel>()
                    .pickIdentityDocument(src),
                onRemove: () => context
                    .read<StoreOnboardingViewModel>()
                    .removeIdentityDocument(),
              ),
            ),
            const SizedBox(height: 16),

            // 6 · AI suggestions
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
                      .read<StoreOnboardingViewModel>()
                      .triggerAiSuggestions(),
              onToggleCategory: (cat) => context
                  .read<StoreOnboardingViewModel>()
                  .toggleCategory(cat),
            ),
            const SizedBox(height: 28),

            // Error banner
            if (vm.submitError != null)
              _ErrorBanner(message: vm.submitError!),

            // 7 · Submit
            _SubmitButton(
              isLoading: vm.isSubmitting,
              accentColor: _kAccent,
              onPressed: () =>
                  context.read<StoreOnboardingViewModel>().submit(),
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
              border: Border.all(color: _kAccent.withValues(alpha: 0.18)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: const Icon(Icons.arrow_back_rounded,
                size: 18, color: _kAccent),
          ),
        ),
      ),
      title: Text(
        l10n.storeSignupTitle,
        style: GoogleFonts.cairo(
            fontSize: 17, fontWeight: FontWeight.bold, color: _kAccent),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(
            fontSize: 13,
            color: Colors.red.shade700,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final bool isLoading;
  final Color accentColor;
  final VoidCallback? onPressed;
  const _SubmitButton(
      {required this.isLoading, required this.accentColor, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          disabledBackgroundColor: accentColor.withValues(alpha: 0.5),
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
                  Text(context.l10n.signupCreateButton,
                      style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 20),
                ],
              ),
      ),
    );
  }
}
