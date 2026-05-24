import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../core/services/app_theme_notifier.dart';
import '../../../../../domain/repositories/i_auth_repository.dart';
import '../../../../../l10n/l10n.dart';
import '../../../../common/theme_mode_sheet.dart';
import '../../../../features/auth/views/login_view.dart';
import '../viewmodels/recycling_home_viewmodel.dart';

class RecyclingProfileTab extends StatelessWidget {
  final String userName;
  const RecyclingProfileTab({super.key, required this.userName});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(ctx.l10n.logout, textAlign: TextAlign.right, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text(ctx.l10n.logoutConfirm, textAlign: TextAlign.right, style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.cancel, style: GoogleFonts.cairo(color: const Color(0xFF717973))),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final nav = Navigator.of(context);
              await context.read<IAuthRepository>().signOut();
              nav.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginView()),
                (route) => false,
              );
            },
            child: Text(ctx.l10n.logoutExit, style: GoogleFonts.cairo(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
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
              // Header — matches supplier layout
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF14401F), Color(0xFF1E6B35)],
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
                          child: const Icon(Icons.recycling_rounded, size: 40, color: Colors.white),
                        ),
                        if (company.isVerified)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.verified_rounded, color: Color(0xFF0A5E3E), size: 20),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      company.name,
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
                            context.l10n.recyclingCompanyLabel,
                            style: GoogleFonts.cairo(fontSize: 12, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white54, shape: BoxShape.circle)),
                        const SizedBox(width: 12),
                        Text(
                          company.id,
                          style: GoogleFonts.dmSans(fontSize: 14, color: Colors.white70, letterSpacing: 1.2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Stats row — 3 items for company
              Transform.translate(
                offset: const Offset(0, -20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        _buildStatItem(vm.totalShipments.toString(), context.l10n.recyclingReceivedShipments),
                        Container(width: 1, height: 40, color: const Color(0xFFE6E9E7)),
                        _buildStatItem(_formatNumber(vm.totalWeightProcessed), context.l10n.recyclingProcessedWeight),
                        Container(width: 1, height: 40, color: const Color(0xFFE6E9E7)),
                        _buildStatItem(vm.activeJobs.toString(), context.l10n.recyclingActiveJobsLabel),
                      ],
                    ),
                  ),
                ),
              ),

              // Company info section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    _buildSectionTitle(context.l10n.recyclingCompanyInfo),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => _showEditProfileSheet(context),
                      icon: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFF14401F)),
                      label: Text(context.l10n.edit, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF14401F))),
                    ),
                  ],
                ),
              ),
              _buildProfileTile(Icons.phone_rounded, context.l10n.recyclingCompanyPhone, company.phone),
              _buildProfileTile(Icons.location_on_rounded, context.l10n.recyclingServiceArea, vm.serviceArea),
              _buildProfileTile(Icons.access_time_rounded, context.l10n.recyclingWorkingHours, vm.workingHours),
              _buildProfileTile(
                Icons.badge_rounded,
                context.l10n.recyclingLicense,
                company.isVerified ? '${context.l10n.recyclingLicenseVerified}  ·  ${vm.licenseNumber}' : context.l10n.recyclingLicenseNotVerified,
                valueColor: company.isVerified ? const Color(0xFF166534) : const Color(0xFFC8860A),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle(context.l10n.profileAppSettings, withPadding: true),
              _buildProfileTile(Icons.language_rounded, context.l10n.profileLanguage,
                Localizations.localeOf(context).languageCode == 'ar' ? context.l10n.languageArabic : context.l10n.languageEnglish),
              
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
                    ),
                  );
                },
              ),
              
              _buildProfileTile(Icons.notifications_active_rounded, context.l10n.profileNotifications, context.l10n.profileNotificationsEnabled),

              const SizedBox(height: 32),
              _buildActionTile(context, context.l10n.recyclingEditCompany, Icons.edit_rounded, const Color(0xFF002819), () => _showEditProfileSheet(context)),
              _buildActionTile(context, context.l10n.logout, Icons.logout_rounded, Colors.red.shade700, () => _showLogoutDialog(context)),
              _buildActionTile(context, context.l10n.profileDeleteAccount, Icons.delete_forever_rounded, Colors.red.shade700, () {}),

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

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(value, style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF002819))),
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF717973))),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool withPadding = false}) {
    final child = Text(
      title,
      style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF002819)),
    );
    if (!withPadding) return child;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Align(alignment: Alignment.centerRight, child: child),
    );
  }

  Widget _buildProfileTile(IconData icon, String label, String value, {Color? valueColor}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF14401F).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF14401F)),
          ),
          const SizedBox(width: 10),
          Text(label, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF002819))),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: GoogleFonts.cairo(fontSize: 13, color: valueColor ?? const Color(0xFF404943), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
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

// ── Edit Company Profile Bottom Sheet ─────────────────────────────────────────

class _EditCompanyProfileSheet extends StatefulWidget {
  final RecyclingHomeViewModel viewModel;
  const _EditCompanyProfileSheet({required this.viewModel});

  @override
  State<_EditCompanyProfileSheet> createState() => _EditCompanyProfileSheetState();
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
      serviceArea: _areaCtrl.text.trim().isNotEmpty ? _areaCtrl.text.trim() : null,
      workingHours: _hoursCtrl.text.trim().isNotEmpty ? _hoursCtrl.text.trim() : null,
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
            Text(context.l10n.recyclingEditCompany, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002819))),
            const SizedBox(height: 24),
            _buildField(label: context.l10n.recyclingCompanyNameLabel, controller: _nameCtrl, hint: context.l10n.recyclingCompanyNameHint),
            const SizedBox(height: 16),
            _buildField(label: context.l10n.recyclingPhoneLabel, controller: _phoneCtrl, hint: context.l10n.recyclingPhoneHint, textDirection: TextDirection.ltr),
            const SizedBox(height: 16),
            _buildField(label: context.l10n.recyclingEmailLabel, controller: _emailCtrl, hint: context.l10n.recyclingEmailHint, textDirection: TextDirection.ltr),
            const SizedBox(height: 16),
            _buildField(label: context.l10n.recyclingAreaLabel, controller: _areaCtrl, hint: context.l10n.recyclingAreaHint),
            const SizedBox(height: 16),
            _buildField(label: context.l10n.recyclingHoursLabel, controller: _hoursCtrl, hint: context.l10n.recyclingHoursHint),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14401F),
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
