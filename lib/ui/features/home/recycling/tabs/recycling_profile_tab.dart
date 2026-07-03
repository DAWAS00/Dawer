import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../core/services/app_theme_notifier.dart';
import '../../../../../core/services/app_lang_notifier.dart';
import '../../../../../l10n/l10n.dart';
import '../../../../common/theme_mode_sheet.dart';
import '../../../../common/lang_picker_sheet.dart';
import '../../shared/profile/profile_actions.dart';
import '../../shared/profile/widgets/profile_header.dart';
import '../../shared/profile/widgets/profile_stat_card.dart';
import '../../shared/profile/widgets/profile_section_header.dart';
import '../../shared/profile/widgets/profile_tile.dart';
import '../../shared/profile/widgets/profile_action_tile.dart';
import '../../shared/profile/widgets/payment_wallet_card.dart';
import '../viewmodels/recycling_home_viewmodel.dart';

class RecyclingProfileTab extends StatelessWidget {
  final String userName;
  const RecyclingProfileTab({super.key, required this.userName});

  List<String> _months(AppLocalizations l10n) => [
    l10n.monthJanuary,
    l10n.monthFebruary,
    l10n.monthMarch,
    l10n.monthApril,
    l10n.monthMay,
    l10n.monthJune,
    l10n.monthJuly,
    l10n.monthAugust,
    l10n.monthSeptember,
    l10n.monthOctober,
    l10n.monthNovember,
    l10n.monthDecember,
  ];

  String _currentPeriodLabel(AppLocalizations l10n) {
    final now = DateTime.now();
    return '${_months(l10n)[now.month - 1]} ${now.year}';
  }

  void _showEditProfileSheet(BuildContext context) {
    final vm = context.read<RecyclingHomeViewModel>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditCompanyProfileSheet(viewModel: vm),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RecyclingHomeViewModel>();
    final company = vm.company;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                ProfileHeader(
                  name: company.name,
                  badgeLabel: context.l10n.recyclingCompanyLabel,
                  avatarIcon: Icons.recycling_rounded,
                  isVerified: company.isVerified,
                  idCode: company.id,
                ),
                ProfileStatCard(
                  stats: [
                    ProfileStat(
                      value: vm.totalShipments.toString(),
                      label: context.l10n.recyclingReceivedShipments,
                    ),
                    ProfileStat(
                      value: _formatNumber(vm.totalWeightProcessed),
                      label: context.l10n.recyclingProcessedWeight,
                    ),
                    ProfileStat(
                      value: vm.activeJobs.toString(),
                      label: context.l10n.recyclingActiveJobsLabel,
                    ),
                  ],
                ),

                // ── Billing / Payment ──
                PaymentWalletCard.company(
                  periodLabel: _currentPeriodLabel(context.l10n),
                  shipments: vm.totalShipments,
                  weightLabel: _formatNumber(vm.totalWeightProcessed),
                  onViewInvoice: () {},
                ),

                // ── Company info ──
                ProfileSectionHeader(
                  title: context.l10n.recyclingCompanyInfo,
                  onEdit: () => _showEditProfileSheet(context),
                ),
                ProfileTile(
                  icon: Icons.phone_rounded,
                  label: context.l10n.recyclingCompanyPhone,
                  value: company.phone,
                  valueLtr: true,
                ),
                ProfileTile(
                  icon: Icons.location_on_rounded,
                  label: context.l10n.recyclingServiceArea,
                  value: vm.serviceArea,
                ),
                ProfileTile(
                  icon: Icons.access_time_rounded,
                  label: context.l10n.recyclingWorkingHours,
                  value: vm.workingHours,
                ),
                ProfileTile(
                  icon: Icons.badge_rounded,
                  label: context.l10n.recyclingLicense,
                  value: company.isVerified
                      ? '${context.l10n.recyclingLicenseVerified}  ·  ${vm.licenseNumber}'
                      : context.l10n.recyclingLicenseNotVerified,
                  valueColor: company.isVerified
                      ? const Color(0xFF166534)
                      : const Color(0xFFC8860A),
                ),

                const SizedBox(height: 24),
                ProfileSectionHeader(title: context.l10n.profileAppSettings),
                Consumer<AppLangNotifier>(
                  builder: (context, langNotifier, _) {
                    final langLabel = langNotifier.locale.languageCode == 'ar'
                        ? context.l10n.languageArabic
                        : context.l10n.languageEnglish;
                    return ProfileTile(
                      icon: Icons.language_rounded,
                      label: context.l10n.profileLanguage,
                      value: langLabel,
                      showArrow: true,
                      onTap: () => showLangPickerSheet(context),
                    );
                  },
                ),
                Consumer<AppThemeNotifier>(
                  builder: (context, themeNotifier, _) {
                    String modeLabel = context.l10n.themeAutoShort;
                    if (themeNotifier.mode == ThemeMode.light)
                      modeLabel = context.l10n.themeLight;
                    if (themeNotifier.mode == ThemeMode.dark)
                      modeLabel = context.l10n.themeDark;
                    return ProfileTile(
                      icon: Icons.dark_mode_rounded,
                      label: context.l10n.profileTheme,
                      value: modeLabel,
                      showArrow: true,
                      onTap: () => showThemeModeSheet(context),
                    );
                  },
                ),
                ProfileTile(
                  icon: Icons.notifications_active_rounded,
                  label: context.l10n.profileNotifications,
                  value: context.l10n.profileNotificationsEnabled,
                ),

                const SizedBox(height: 32),
                ProfileActionTile(
                  icon: Icons.logout_rounded,
                  title: context.l10n.logout,
                  color: Colors.red.shade700,
                  onTap: () => showLogoutDialog(context),
                ),
                ProfileActionTile(
                  icon: Icons.delete_forever_rounded,
                  title: context.l10n.profileDeleteAccount,
                  color: Colors.red.shade700,
                  onTap: () {},
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double n) {
    final intVal = n.toInt();
    final str = intVal.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

// ── Edit Company Profile Bottom Sheet ─────────────────────────────────────────

class _EditCompanyProfileSheet extends StatefulWidget {
  final RecyclingHomeViewModel viewModel;
  const _EditCompanyProfileSheet({required this.viewModel});

  @override
  State<_EditCompanyProfileSheet> createState() =>
      _EditCompanyProfileSheetState();
}

class _EditCompanyProfileSheetState extends State<_EditCompanyProfileSheet> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _hoursCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final vm = widget.viewModel;
    _nameCtrl.text = vm.company.name;
    _phoneCtrl.text = vm.company.phone;
    _emailCtrl.text = vm.email;
    _areaCtrl.text = vm.serviceArea;
    _hoursCtrl.text = vm.workingHours;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _areaCtrl.dispose();
    _hoursCtrl.dispose();
    super.dispose();
  }

  void _save() {
    widget.viewModel.updateProfile(
      name: _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : null,
      phone: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
      email: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
      serviceArea: _areaCtrl.text.trim().isNotEmpty
          ? _areaCtrl.text.trim()
          : null,
      workingHours: _hoursCtrl.text.trim().isNotEmpty
          ? _hoursCtrl.text.trim()
          : null,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE6E9E7),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.recyclingEditCompany,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002819),
              ),
            ),
            const SizedBox(height: 24),
            _buildField(
              label: context.l10n.recyclingCompanyNameLabel,
              controller: _nameCtrl,
              hint: context.l10n.recyclingCompanyNameHint,
            ),
            const SizedBox(height: 16),
            _buildField(
              label: context.l10n.recyclingPhoneLabel,
              controller: _phoneCtrl,
              hint: context.l10n.recyclingPhoneHint,
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 16),
            _buildField(
              label: context.l10n.recyclingEmailLabel,
              controller: _emailCtrl,
              hint: context.l10n.recyclingEmailHint,
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 16),
            _buildField(
              label: context.l10n.recyclingAreaLabel,
              controller: _areaCtrl,
              hint: context.l10n.recyclingAreaHint,
            ),
            const SizedBox(height: 16),
            _buildField(
              label: context.l10n.recyclingHoursLabel,
              controller: _hoursCtrl,
              hint: context.l10n.recyclingHoursHint,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14401F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  context.l10n.saveChanges,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextDirection textDirection = TextDirection.rtl,
  }) {
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
            color: const Color(0xFFF2F4F2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            textDirection: textDirection,
            textAlign: textDirection == TextDirection.rtl
                ? TextAlign.right
                : TextAlign.left,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.cairo(color: const Color(0xFF9099A2)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            style: GoogleFonts.cairo(
              fontSize: 16,
              color: const Color(0xFF002819),
            ),
          ),
        ),
      ],
    );
  }
}
