import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/user.dart';
import '../../../../../data/models/user_role.dart';
import '../../../../../core/services/app_theme_notifier.dart';
import 'package:provider/provider.dart';
import '../../../../common/theme_mode_sheet.dart';
import '../../../../../l10n/l10n.dart';
import '../../shared/profile/profile_actions.dart';
import '../../shared/profile/widgets/profile_header.dart';
import '../../shared/profile/widgets/profile_stat_card.dart';
import '../../shared/profile/widgets/profile_section_header.dart';
import '../../shared/profile/widgets/profile_tile.dart';
import '../../shared/profile/widgets/profile_action_tile.dart';
import '../../shared/profile/widgets/payment_wallet_card.dart';
import '../views/rewards_view.dart';

class SupplierProfileTab extends StatelessWidget {
  final User user;
  final int totalPoints;
  final int totalOrders;
  final SupplierType supplierType;
  final void Function({String? name, String? phone, String? address}) onUpdateProfile;

  const SupplierProfileTab({
    super.key,
    required this.user,
    required this.totalPoints,
    required this.totalOrders,
    required this.supplierType,
    required this.onUpdateProfile,
  });

  void _openRewards(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RewardsView(userId: user.id),
    ));
  }

  void _showEditProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditProfileSheet(
        user: user,
        onUpdateProfile: onUpdateProfile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isStore = supplierType == SupplierType.storeBusiness;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              ProfileHeader(
                name: user.name,
                badgeLabel: isStore ? context.l10n.supplierStoreType : context.l10n.supplierIndividualType,
                avatarIcon: isStore ? Icons.storefront_rounded : Icons.person_rounded,
                isVerified: user.isVerified,
              ),
              ProfileStatCard(
                stats: [
                  ProfileStat(value: totalPoints.toString(), label: context.l10n.supplierRecyclingPoints),
                  ProfileStat(value: totalOrders.toString(), label: context.l10n.supplierTotalOrders),
                ],
              ),

              // ── Rewards / Payment ──
              PaymentWalletCard.supplier(
                points: totalPoints,
                onViewRewards: () => _openRewards(context),
              ),

              // ── Personal info ──
              ProfileSectionHeader(
                title: context.l10n.supplierPersonalInfo,
                onEdit: () => _showEditProfileSheet(context),
              ),
              ProfileTile(icon: Icons.phone_rounded, label: context.l10n.profilePhone, value: user.phone, valueLtr: true),
              ProfileTile(icon: Icons.location_on_rounded, label: context.l10n.supplierAddressLabel, value: user.address ?? context.l10n.supplierAddAddress),
              ProfileTile(
                icon: Icons.badge_rounded,
                label: context.l10n.supplierIdentity,
                value: user.isVerified ? context.l10n.supplierVerified : context.l10n.supplierNotVerified,
                valueColor: user.isVerified ? const Color(0xFF166534) : const Color(0xFFC8860A),
              ),

              const SizedBox(height: 24),
              ProfileSectionHeader(title: context.l10n.profileAppSettings),
              ProfileTile(
                icon: Icons.language_rounded,
                label: context.l10n.profileLanguage,
                value: Localizations.localeOf(context).languageCode == 'ar' ? context.l10n.languageArabic : context.l10n.languageEnglish,
              ),
              Consumer<AppThemeNotifier>(
                builder: (context, themeNotifier, _) {
                  String modeLabel = context.l10n.themeAutoShort;
                  if (themeNotifier.mode == ThemeMode.light) modeLabel = context.l10n.themeLight;
                  if (themeNotifier.mode == ThemeMode.dark) modeLabel = context.l10n.themeDark;
                  return ProfileTile(
                    icon: Icons.dark_mode_rounded,
                    label: context.l10n.profileTheme,
                    value: modeLabel,
                    showArrow: true,
                    onTap: () => showThemeModeSheet(context),
                  );
                },
              ),
              ProfileTile(icon: Icons.notifications_active_rounded, label: context.l10n.profileNotifications, value: context.l10n.profileNotificationsEnabled),

              const SizedBox(height: 32),
              ProfileActionTile(icon: Icons.logout_rounded, title: context.l10n.logout, color: Colors.red.shade700, onTap: () => showLogoutDialog(context)),
              ProfileActionTile(icon: Icons.person_remove_rounded, title: context.l10n.profileDeleteAccount, color: Colors.red.shade700, onTap: () {}),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Edit Profile Bottom Sheet ────────────────────────────────────────────────

class _EditProfileSheet extends StatefulWidget {
  final User user;
  final void Function({String? name, String? phone, String? address}) onUpdateProfile;
  const _EditProfileSheet({required this.user, required this.onUpdateProfile});

  @override
  State<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<_EditProfileSheet> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameCtrl.text = widget.user.name;
    _phoneCtrl.text = widget.user.phone;
    _addressCtrl.text = widget.user.address ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _save() {
    widget.onUpdateProfile(
      name: _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : null,
      phone: _phoneCtrl.text.trim().isNotEmpty ? _phoneCtrl.text.trim() : null,
      address: _addressCtrl.text.trim().isNotEmpty ? _addressCtrl.text.trim() : null,
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
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE6E9E7), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text(context.l10n.profileEditProfile, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002819))),
            const SizedBox(height: 24),
            _buildField(label: context.l10n.supplierNameLabel, controller: _nameCtrl, hint: context.l10n.supplierNameHint),
            const SizedBox(height: 16),
            _buildField(label: context.l10n.profilePhone, controller: _phoneCtrl, hint: context.l10n.supplierPhoneHint, textDirection: TextDirection.ltr),
            const SizedBox(height: 16),
            _buildField(label: context.l10n.supplierAddressLabel, controller: _addressCtrl, hint: context.l10n.supplierAddressHint),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E5C35),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text(context.l10n.saveChanges, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
        Text(label, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF404943))),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: const Color(0xFFF2F4F2), borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: controller,
            textDirection: textDirection,
            textAlign: textDirection == TextDirection.rtl ? TextAlign.right : TextAlign.left,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.cairo(color: const Color(0xFF9099A2)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: GoogleFonts.cairo(fontSize: 16, color: const Color(0xFF002819)),
          ),
        ),
      ],
    );
  }
}
