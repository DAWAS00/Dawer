import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../data/models/user_role.dart';
import '../../../common/green_button.dart';
import '../../../common/map/location_picker_screen.dart';
import '../../home/home_router.dart';
import '../viewmodels/recycling_co_onboarding_viewmodel.dart';
import 'widgets/identity_upload_card.dart';
import 'widgets/photo_picker_card.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// RecyclingCoOnboardingView — single-page company sign-up
//
// Layout:
//   1. Header banner
//   2. Company profile  (logo + name + owner)
//   3. Location picker
//   4. Account credentials  (email · phone · password)
//   5. Business license upload
//   6. AI category suggestions  (tagline → generate → checkboxes + highlights)
//   7. Submit
// ═══════════════════════════════════════════════════════════════════════════════

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

// ── Main scaffold ─────────────────────────────────────────────────────────────

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
    final vm = context.watch<RecyclingCoOnboardingViewModel>();

    if (vm.submitted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => HomeRouter(
              role: UserRole.recyclingCo,
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
            _HeaderBanner(),
            const SizedBox(height: 20),

            // 2 · Company profile
            _SectionCard(
              title: 'الملف الشخصي للشركة',
              icon: Icons.business_rounded,
              child: Column(
                children: [
                  PhotoPickerCard(
                    image: vm.profilePhoto,
                    label: 'شعار الشركة',
                    isBusiness: true,
                    onPick: (src) => context
                        .read<RecyclingCoOnboardingViewModel>()
                        .pickProfilePhoto(src),
                    onRemove: () => context
                        .read<RecyclingCoOnboardingViewModel>()
                        .removeProfilePhoto(),
                  ),
                  const SizedBox(height: 14),
                  _InputField(
                    controller: _companyCtrl,
                    label: 'اسم الشركة',
                    hint: 'مثال: شركة دوار للتدوير',
                    error: vm.errors['companyName'],
                    onChanged: (v) {
                      vm.companyName = v;
                      vm.clearError('companyName');
                    },
                  ),
                  const SizedBox(height: 14),
                  _InputField(
                    controller: _ownerCtrl,
                    label: 'اسم المدير / المالك',
                    hint: 'مثال: محمد العبدالله',
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
            _SectionCard(
              title: 'الموقع الجغرافي',
              icon: Icons.location_on_rounded,
              subtitle: 'اختياري — يساعد الموردين القريبين على اكتشافك',
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
                        .read<RecyclingCoOnboardingViewModel>()
                        .setAddress(result.$1, result.$2);
                  }
                },
                child: _LocationTile(lat: vm.addressLat, lng: vm.addressLng),
              ),
            ),
            const SizedBox(height: 16),

            // 4 · Account credentials
            _SectionCard(
              title: 'بيانات الحساب',
              icon: Icons.lock_rounded,
              subtitle: 'ستستخدمها لتسجيل الدخول لاحقاً',
              child: Column(
                children: [
                  _InputField(
                    controller: _emailCtrl,
                    label: 'البريد الإلكتروني',
                    hint: 'example@company.com',
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    error: vm.errors['email'],
                    onChanged: (v) {
                      vm.email = v;
                      vm.clearError('email');
                    },
                  ),
                  const SizedBox(height: 14),
                  _InputField(
                    controller: _phoneCtrl,
                    label: 'رقم الهاتف',
                    hint: '+962 7x xxx xxxx',
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    isRequired: false,
                    onChanged: (v) => vm.phone = v,
                  ),
                  const SizedBox(height: 14),
                  _PasswordField(
                    controller: _pwCtrl,
                    label: 'كلمة المرور',
                    hint: '8 أحرف على الأقل + رقم',
                    error: vm.errors['password'],
                    onChanged: (v) {
                      vm.password = v;
                      vm.clearError('password');
                    },
                  ),
                  const SizedBox(height: 14),
                  _PasswordField(
                    controller: _pwConfirmCtrl,
                    label: 'تأكيد كلمة المرور',
                    hint: 'أعد كتابة كلمة المرور',
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

            // 5 · Business license
            _SectionCard(
              title: 'الترخيص التجاري',
              icon: Icons.badge_rounded,
              child: IdentityUploadCard(
                document: vm.licenseDocument,
                label: 'الترخيص التجاري',
                error: null,
                onPick: (src) => context
                    .read<RecyclingCoOnboardingViewModel>()
                    .pickLicense(src),
                onRemove: () => context
                    .read<RecyclingCoOnboardingViewModel>()
                    .removeLicense(),
              ),
            ),
            const SizedBox(height: 16),

            // 6 · AI category suggestions
            _AiSuggestionsPanel(taglineCtrl: _taglineCtrl),
            const SizedBox(height: 16),

            // 6.5 · Marketplace Interests
            _MarketplaceInterestsPanel(),
            const SizedBox(height: 28),

            // 7 · Submit
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

            GreenButton(
              text: 'إنشاء الحساب',
              height: 58,
              borderRadius: 16,
              isLoading: vm.isSubmitting,
              trailingIcon: vm.isSubmitting
                  ? null
                  : const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 20),
              onPressed: vm.isSubmitting
                  ? null
                  : () =>
                      context.read<RecyclingCoOnboardingViewModel>().submit(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
                  color: const Color(0xFF06402B).withValues(alpha: 0.12)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2)),
              ],
            ),
            child: const Icon(Icons.arrow_forward_rounded,
                size: 18, color: Color(0xFF06402B)),
          ),
        ),
      ),
      title: Text(
        'تسجيل شركة تدوير',
        style: GoogleFonts.cairo(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF06402B)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// AI category suggestions panel
// ═══════════════════════════════════════════════════════════════════════════════

class _AiSuggestionsPanel extends StatelessWidget {
  final TextEditingController taglineCtrl;
  const _AiSuggestionsPanel({required this.taglineCtrl});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecyclingCoOnboardingViewModel>();

    return _SectionCard(
      title: 'اقتراحات الذكاء الاصطناعي',
      icon: Icons.auto_awesome_rounded,
      subtitle: 'فئات موصى بها وما يميز شركتك في التطبيق',
      accentIcon: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── AI context note ──────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Container(
              key: ValueKey(vm.aiStatus),
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: switch (vm.aiStatus) {
                  AiAnalysisStatus.analyzing => Colors.blue.shade50,
                  AiAnalysisStatus.verified => const Color(0xFFD1FAE5),
                  AiAnalysisStatus.failed => Colors.red.shade50,
                  _ => const Color(0xFF7C3AED).withValues(alpha: 0.07),
                },
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: switch (vm.aiStatus) {
                    AiAnalysisStatus.analyzing => Colors.blue.shade200,
                    AiAnalysisStatus.verified => const Color(0xFF1E5C35).withValues(alpha: 0.2),
                    AiAnalysisStatus.failed => Colors.red.shade200,
                    _ => const Color(0xFF7C3AED).withValues(alpha: 0.18),
                  },
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      switch (vm.aiStatus) {
                        AiAnalysisStatus.analyzing => 'جارٍ تحليل البيانات باستخدام الذكاء الاصطناعي للتحقق من الصحة...',
                        AiAnalysisStatus.verified => 'تم التحقق من صحة البيانات بنجاح بواسطة الذكاء الاصطناعي.',
                        AiAnalysisStatus.failed => 'فشل تحليل الذكاء الاصطناعي. يرجى التحقق من البيانات والمحاولة مرة أخرى.',
                        _ => 'سيحلل الذكاء الاصطناعي اسم شركتك وشعارها ويقترح الفئات الأنسب لها.',
                      },
                      textAlign: TextAlign.right,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: vm.aiStatus == AiAnalysisStatus.none ? FontWeight.normal : FontWeight.bold,
                        color: switch (vm.aiStatus) {
                          AiAnalysisStatus.analyzing => Colors.blue.shade800,
                          AiAnalysisStatus.verified => const Color(0xFF1E5C35),
                          AiAnalysisStatus.failed => Colors.red.shade800,
                          _ => const Color(0xFF5B21B6),
                        },
                      ),
                    ),
                  ),
                  if (vm.aiStatus == AiAnalysisStatus.analyzing) ...[
                    const SizedBox(width: 10),
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
                    ),
                  ] else if (vm.aiStatus == AiAnalysisStatus.verified) ...[
                    const SizedBox(width: 10),
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF1E5C35), size: 18),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Tagline input ────────────────────────────────────────────────
          _InputField(
            controller: taglineCtrl,
            label: 'شعار الشركة أو رؤيتها',
            hint: 'مثال: تدوير أفضل لغد أجمل',
            isRequired: false,
            onChanged: (v) => vm.tagline = v,
          ),
          const SizedBox(height: 14),

          // ── Generate button ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GreenButton(
              text: vm.isAiLoading
                  ? 'جارٍ التوليد...'
                  : 'احصل على اقتراحات الذكاء الاصطناعي',
              height: 56,
              borderRadius: 14,
              isLoading: vm.isAiLoading,
              leadingIcon: vm.isAiLoading
                  ? null
                  : const Icon(Icons.auto_awesome_rounded,
                      color: Colors.white, size: 18),
              onPressed: vm.isAiLoading
                  ? null
                  : () => context
                      .read<RecyclingCoOnboardingViewModel>()
                      .triggerAiSuggestions(),
            ),
          ),

          // ── Loading shimmer ──────────────────────────────────────────────
          if (vm.isAiLoading) ...[
            const SizedBox(height: 16),
            const _ShimmerBox(width: double.infinity, height: 13),
            const SizedBox(height: 7),
            const _ShimmerBox(width: double.infinity, height: 13),
            const SizedBox(height: 7),
            const _ShimmerBox(width: 180, height: 13),
            const SizedBox(height: 12),
            const _ShimmerBox(width: double.infinity, height: 13),
            const SizedBox(height: 7),
            const _ShimmerBox(width: 220, height: 13),
          ],

          // ── Results: categories + highlights ─────────────────────────────
          if (vm.brandProfile != null && !vm.isAiLoading) ...[
            const SizedBox(height: 20),
            _CategoriesSection(
              categories: vm.allCategories,
              selected: vm.selectedCategories,
              onToggle: (cat) => context
                  .read<RecyclingCoOnboardingViewModel>()
                  .toggleCategory(cat),
            ),
            const SizedBox(height: 20),
            _HighlightsSection(
                highlights: vm.brandProfile!.companyHighlights),
          ],
        ],
      ),
    );
  }
}

// ── Categories with checkboxes ────────────────────────────────────────────────

class _CategoriesSection extends StatelessWidget {
  final List<String> categories;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _CategoriesSection({
    required this.categories,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${selected.length} محددة',
              style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: const Color(0xFF06402B),
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            Text(
              'الفئات المقترحة — اختر ما ينطبق على شركتك',
              style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002819)),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'يمكنك تعديل اختياراتك في أي وقت من إعدادات الملف الشخصي',
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(
              fontSize: 11, color: const Color(0xFF717973)),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border:
                Border.all(color: const Color(0xFFE6E9E7)),
          ),
          child: Column(
            children: List.generate(categories.length, (i) {
              final cat = categories[i];
              final isSelected = selected.contains(cat);
              final isLast = i == categories.length - 1;
              return Column(
                children: [
                  InkWell(
                    onTap: () => onToggle(cat),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isSelected,
                            onChanged: (_) => onToggle(cat),
                            activeColor: const Color(0xFF06402B),
                            side: const BorderSide(
                                color: Color(0xFFC0C9C1), width: 1.5),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4)),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              cat,
                              textAlign: TextAlign.right,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? const Color(0xFF002819)
                                    : const Color(0xFF404943),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    const Divider(
                        height: 1,
                        indent: 14,
                        endIndent: 14,
                        color: Color(0xFFEEF1EE)),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ── Company highlights (AI-generated) ────────────────────────────────────────

class _HighlightsSection extends StatelessWidget {
  final List<String> highlights;
  const _HighlightsSection({required this.highlights});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'ما يميز شركتك في التطبيق',
          style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819)),
        ),
        const SizedBox(height: 4),
        Text(
          'مزايا ستحصل عليها بمجرد إنشاء الحساب',
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(
              fontSize: 11, color: const Color(0xFF717973)),
        ),
        const SizedBox(height: 10),
        ...List.generate(highlights.length, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    highlights[i],
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(
                        fontSize: 13, color: const Color(0xFF191C1B)),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xFF06402B).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: GoogleFonts.cairo(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF06402B)),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Marketplace interests selection + AI content preview
// ═══════════════════════════════════════════════════════════════════════════════

class _MarketplaceInterestsPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecyclingCoOnboardingViewModel>();
    final interests = [
      'تدوير البلاستيك',
      'إدارة النفايات العضوية',
      'تكنولوجيا التدوير',
      'السوق المحلي',
      'الاستدامة البيئية'
    ];

    return _SectionCard(
      title: 'اهتمامات السوق',
      icon: Icons.shopping_bag_rounded,
      subtitle: 'اختر اهتماماتك للحصول على محتوى مخصص في السوق',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 8,
            children: interests.map((interest) {
              final isSelected = vm.selectedInterests.contains(interest);
              return FilterChip(
                label: Text(interest, style: GoogleFonts.cairo(fontSize: 12)),
                selected: isSelected,
                onSelected: (_) => vm.toggleInterest(interest),
                selectedColor: const Color(0xFF06402B).withValues(alpha: 0.2),
                checkmarkColor: const Color(0xFF06402B),
                labelStyle: GoogleFonts.cairo(
                  color: isSelected ? const Color(0xFF06402B) : const Color(0xFF404943),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          GreenButton(
            text: vm.isGeneratingMarketplace ? 'جاري التحليل...' : 'توليد محتوى مخصص للسوق',
            height: 50,
            borderRadius: 12,
            isLoading: vm.isGeneratingMarketplace,
            onPressed: vm.selectedInterests.isEmpty
                ? null
                : () => vm.generateMarketplaceContent(),
          ),
          if (vm.marketplaceContent != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF06402B).withValues(alpha: 0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'محتوى السوق المخصص بالذكاء الاصطناعي',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF06402B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.auto_awesome_rounded, size: 16, color: Color(0xFF06402B)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    vm.marketplaceContent!,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF191C1B)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Shared private widgets
// ═══════════════════════════════════════════════════════════════════════════════

class _HeaderBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF06402B), Color(0xFF0A5E3E)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('إنشاء حساب شركة تدوير',
                    style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                const SizedBox(height: 3),
                Text(
                  'أكمل النموذج وسيساعدك الذكاء الاصطناعي في اختيار الفئات',
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.recycling_rounded,
                color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? subtitle;
  final bool accentIcon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.subtitle,
    this.accentIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor =
        accentIcon ? const Color(0xFF7C3AED) : const Color(0xFF06402B);
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F2),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(title,
                      style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF002819))),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: GoogleFonts.cairo(
                            fontSize: 11, color: const Color(0xFF717973))),
                ],
              ),
              const SizedBox(width: 10),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 17, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? error;
  final bool isRequired;
  final TextInputType keyboardType;
  final TextDirection? textDirection;
  final ValueChanged<String> onChanged;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.error,
    this.isRequired = true,
    this.keyboardType = TextInputType.text,
    this.textDirection,
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
              const Text(' *',
                  style: TextStyle(color: Colors.red, fontSize: 13)),
            Text(label,
                style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF404943))),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color:
                error != null ? Colors.red.shade50 : const Color(0xFFE6E9E7),
            borderRadius: BorderRadius.circular(10),
            border: error != null
                ? Border.all(color: Colors.red.shade300)
                : null,
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            textAlign: textDirection == TextDirection.ltr
                ? TextAlign.left
                : TextAlign.right,
            textDirection: textDirection,
            onChanged: onChanged,
            style: GoogleFonts.cairo(
                fontSize: 14, color: const Color(0xFF191C1B)),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.cairo(
                  fontSize: 13,
                  color: const Color(0xFF6B7280).withValues(alpha: 0.5)),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 3),
          Text(error!,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.bold)),
        ],
      ],
    );
  }
}

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String? error;
  final ValueChanged<String> onChanged;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.onChanged,
    this.error,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text(' *',
                style: TextStyle(color: Colors.red, fontSize: 13)),
            Text(widget.label,
                style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF404943))),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: widget.error != null
                ? Colors.red.shade50
                : const Color(0xFFE6E9E7),
            borderRadius: BorderRadius.circular(10),
            border: widget.error != null
                ? Border.all(color: Colors.red.shade300)
                : null,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: const Color(0xFF6B7280),
                  size: 20,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  obscureText: _obscure,
                  textAlign: TextAlign.right,
                  onChanged: widget.onChanged,
                  style: GoogleFonts.cairo(
                      fontSize: 14, color: const Color(0xFF191C1B)),
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: GoogleFonts.cairo(
                        fontSize: 13,
                        color:
                            const Color(0xFF6B7280).withValues(alpha: 0.5)),
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.error != null) ...[
          const SizedBox(height: 3),
          Text(widget.error!,
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: Colors.red.shade600,
                  fontWeight: FontWeight.bold)),
        ],
      ],
    );
  }
}

class _LocationTile extends StatelessWidget {
  final double? lat;
  final double? lng;
  const _LocationTile({this.lat, this.lng});

  @override
  Widget build(BuildContext context) {
    final hasCoords = lat != null && lng != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: hasCoords
            ? const Color(0xFF06402B).withValues(alpha: 0.06)
            : const Color(0xFFE6E9E7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: hasCoords
              ? const Color(0xFF06402B).withValues(alpha: 0.4)
              : const Color(0xFFC0C9C1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF06402B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              hasCoords ? 'تغيير' : 'تحديد',
              style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF06402B)),
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hasCoords
                    ? '${lat!.toStringAsFixed(4)}, ${lng!.toStringAsFixed(4)}'
                    : 'اضغط لتحديد موقعك',
                style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: hasCoords
                        ? const Color(0xFF06402B)
                        : const Color(0xFF404943)),
              ),
              Text('اضغط لفتح خريطة الموقع',
                  style: GoogleFonts.cairo(
                      fontSize: 11, color: const Color(0xFF717973))),
            ],
          ),
          const SizedBox(width: 12),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFF06402B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              hasCoords
                  ? Icons.location_on_rounded
                  : Icons.add_location_alt_rounded,
              size: 18,
              color: const Color(0xFF06402B),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shimmer animation box ─────────────────────────────────────────────────────

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;
  const _ShimmerBox({required this.width, required this.height});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.25, end: 0.7)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: Colors.grey.shade300.withValues(alpha: _anim.value),
        ),
      ),
    );
  }
}
