import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../data/models/user.dart';
import '../../../../../core/services/app_theme_notifier.dart';
import '../../../../common/theme_mode_sheet.dart';
import '../../../../../l10n/l10n.dart';
import '../../../../../domain/repositories/i_auth_repository.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/auth/viewmodels/login_viewmodel.dart';
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(context.l10n.logout, textAlign: TextAlign.right, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text(context.l10n.logoutConfirm, textAlign: TextAlign.right, style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel, style: GoogleFonts.cairo(color: const Color(0xFF717973))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<IAuthRepository>().signOut();
              if (context.mounted) context.go('/login');
            },
            child: Text(context.l10n.logoutExit, style: GoogleFonts.cairo(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
              // Header
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E5C35), Color(0xFF2D8052)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                ),
                padding: EdgeInsets.fromLTRB(24, MediaQuery.of(context).padding.top + 28, 24, 32),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          child: Icon(
                            isStore ? Icons.storefront_rounded : Icons.person_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        if (user.isVerified)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.verified_rounded, color: Color(0xFF0A5E3E), size: 20),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isStore ? context.l10n.supplierStoreType : context.l10n.supplierIndividualType,
                            style: GoogleFonts.cairo(fontSize: 12, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Stats row
              Transform.translate(
                offset: const Offset(0, -20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Theme.of(context).brightness == Brightness.dark ? Border.all(color: Theme.of(context).colorScheme.outline) : null,
                      boxShadow: [
                        if (Theme.of(context).brightness != Brightness.dark)
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        _buildStatItem(totalPoints.toString(), context.l10n.supplierRecyclingPoints, context),
                        Container(width: 1, height: 40, color: Theme.of(context).dividerColor),
                        _buildStatItem(totalOrders.toString(), context.l10n.supplierTotalOrders, context),
                      ],
                    ),
                  ),
                ),
              ),

              // Personal info section
              Row(
                children: [
                  _buildSectionTitle(context.l10n.supplierPersonalInfo, context),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _showEditProfileSheet(context),
                    icon: Icon(Icons.edit_rounded, size: 16, color: Theme.of(context).primaryColor),
                    label: Text(context.l10n.edit, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
              _buildProfileTile(Icons.phone_rounded, context.l10n.profilePhone, user.phone, context),
              _buildProfileTile(Icons.location_on_rounded, context.l10n.supplierAddressLabel, user.address ?? context.l10n.supplierAddAddress, context),
              _buildProfileTile(
                Icons.badge_rounded,
                context.l10n.supplierIdentity,
                user.isVerified ? context.l10n.supplierVerified : context.l10n.supplierNotVerified,
                context,
                valueColor: user.isVerified ? const Color(0xFF166534) : const Color(0xFFC8860A),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle(context.l10n.profileAppSettings, context),
              _buildProfileTile(Icons.language_rounded, context.l10n.profileLanguage,
                Localizations.localeOf(context).languageCode == 'ar' ? context.l10n.languageArabic : context.l10n.languageEnglish, context),
              
              Consumer<AppThemeNotifier>(
                builder: (context, themeNotifier, _) {
                  String modeLabel = context.l10n.themeAutoShort;
                  if (themeNotifier.mode == ThemeMode.light) modeLabel = context.l10n.themeLight;
                  if (themeNotifier.mode == ThemeMode.dark) modeLabel = context.l10n.themeDark;
                  
                  return InkWell(
                    onTap: () => showThemeModeSheet(context),
                    child: _buildProfileTile(
                      Icons.dark_mode_rounded,
                      context.l10n.profileTheme,
                      modeLabel,
                      context,
                    ),
                  );
                },
              ),
              
              _buildProfileTile(Icons.notifications_active_rounded, context.l10n.profileNotifications, context.l10n.profileNotificationsEnabled, context),

              const SizedBox(height: 32),
              _buildActionTile(context, context.l10n.supplierMyRewards, Icons.emoji_events_rounded, const Color(0xFFD97706), () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => RewardsView(totalPoints: totalPoints),
                ));
              }),
              _buildActionTile(context, context.l10n.profileEditProfile, Icons.edit_rounded, const Color(0xFF002819), () => _showEditProfileSheet(context)),
              _buildActionTile(context, context.l10n.logout, Icons.logout_rounded, Colors.red.shade700, () => _showLogoutDialog(context)),
              _buildActionTile(context, context.l10n.profileDeleteAccount, Icons.person_remove_rounded, Colors.red.shade700, () {}),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.cairo(fontSize: 13, color: Theme.of(context).textTheme.bodyMedium?.color)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
      ),
    );
  }

  Widget _buildProfileTile(IconData icon, String label, String value, BuildContext context, {Color? valueColor}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: isDark ? Border.all(color: theme.colorScheme.outline) : null,
        boxShadow: [
          if (!isDark)
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: theme.primaryColor),
          ),
          const SizedBox(width: 10),
          Text(label, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color)),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.cairo(fontSize: 14, color: valueColor ?? theme.textTheme.bodyMedium?.color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Use an adapted color for text if dark mode, else use provided color.
    // Assuming color is usually dark, so in dark mode we can use white or a lighter color.
    final textColor = isDark ? theme.textTheme.bodyLarge?.color : color;
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 16),
            Text(title, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
            const Spacer(),
            Icon(Icons.chevron_left_rounded, color: textColor?.withValues(alpha: 0.5), size: 20),
          ],
        ),
      ),
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
