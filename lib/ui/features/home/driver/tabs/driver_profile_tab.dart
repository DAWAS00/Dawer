import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../data/models/user.dart';
import '../../../../features/auth/views/login_view.dart';
import '../../../../common/theme_mode_sheet.dart';
import '../../../../common/lang_picker_sheet.dart';
import '../../../../../core/services/app_theme_notifier.dart';
import '../../../../../core/services/app_lang_notifier.dart';
import '../../../../../l10n/l10n.dart';
import '../viewmodels/driver_home_viewmodel.dart';
import '../widgets/driver_profile_tile.dart';

class DriverProfileTab extends StatelessWidget {
  const DriverProfileTab({super.key});

  Future<void> _launchHelpCenter() async {
    final Uri url = Uri.parse('mailto:support@dwaar.com?subject=مساعدة%20سائق');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(context.l10n.logout, textAlign: TextAlign.right, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text(context.l10n.logoutConfirm, textAlign: TextAlign.right, style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancel, style: GoogleFonts.cairo(color: const Color(0xFF717973))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginView()),
                (route) => false,
              );
            },
            child: Text(context.l10n.logoutExit, style: GoogleFonts.cairo(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditVehicleBottomSheet(BuildContext context, DriverHomeViewModel vm) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _EditVehicleBottomSheet(viewModel: vm),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DriverHomeViewModel>();
    final user = vm.user;

    final vehicleString = (user.vehicleModel?.isNotEmpty ?? false) || (user.vehicleColor?.isNotEmpty ?? false)
        ? '${user.vehicleModel ?? ''} - ${user.vehicleColor ?? ''}'.trim().replaceAll(RegExp(r'^-|-$'), '').trim()
        : context.l10n.profileAddVehicleInfo;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, user),
              _buildStatsRow(vm, context),
              const SizedBox(height: 24),
              Row(
                children: [
                  const SizedBox(width: 24),
                  TextButton.icon(
                    onPressed: () => _showEditVehicleBottomSheet(context, vm),
                    icon: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFF06402B)),
                    label: Text(context.l10n.edit, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF06402B))),
                  ),
                  const Spacer(),
                  _buildSectionTitle(context.l10n.profilePersonalAndVehicle, context),
                ],
              ),
              DriverProfileTile(icon: Icons.phone_rounded, label: context.l10n.profilePhone, value: user.phone, showArrow: true),
              DriverProfileTile(icon: Icons.directions_car_rounded, label: context.l10n.profileVehicle, value: vehicleString, showArrow: true),
              DriverProfileTile(icon: Icons.pin_rounded, label: context.l10n.profileLicensePlate, value: user.licensePlate ?? context.l10n.profileAddLicensePlate),
              if (user.vehiclePhotoPath != null && user.vehiclePhotoPath!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(user.vehiclePhotoPath!),
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              
              const SizedBox(height: 24),
              _buildSectionTitle(context.l10n.profileAppSettings, context),
              Consumer<AppLangNotifier>(
                builder: (context, langNotifier, _) {
                  final langLabel = langNotifier.locale.languageCode == 'ar'
                      ? context.l10n.languageArabic
                      : context.l10n.languageEnglish;
                  return InkWell(
                    onTap: () => showLangPickerSheet(context),
                    child: DriverProfileTile(
                      icon: Icons.language_rounded,
                      label: context.l10n.profileLanguage,
                      value: langLabel,
                      showArrow: true,
                    ),
                  );
                },
              ),

              Consumer<AppThemeNotifier>(
                builder: (context, themeNotifier, _) {
                  String modeLabel = context.l10n.themeAutoShort;
                  if (themeNotifier.mode == ThemeMode.light) modeLabel = context.l10n.themeLight;
                  if (themeNotifier.mode == ThemeMode.dark) modeLabel = context.l10n.themeDark;

                  return InkWell(
                    onTap: () => showThemeModeSheet(context),
                    child: DriverProfileTile(
                      icon: Icons.dark_mode_rounded,
                      label: context.l10n.profileTheme,
                      value: modeLabel,
                      showArrow: true,
                    ),
                  );
                },
              ),

              DriverProfileTile(icon: Icons.notifications_active_rounded, label: context.l10n.profileNotifications, value: context.l10n.profileNotificationsEnabled, showArrow: true),

              const SizedBox(height: 24),
              _buildSectionTitle(context.l10n.profileHelpSupport, context),
              InkWell(
                onTap: _launchHelpCenter,
                child: DriverProfileTile(icon: Icons.help_center_rounded, label: context.l10n.profileContactSupport, value: '', showArrow: true),
              ),

              const SizedBox(height: 32),
              _buildActionTile(context, context.l10n.profileEditProfile, Icons.edit_rounded, const Color(0xFF002819), () {}),
              _buildActionTile(context, context.l10n.logout, Icons.logout_rounded, Colors.red.shade700, () => _showLogoutDialog(context)),
              _buildActionTile(context, context.l10n.profileDeleteAccount, Icons.person_remove_rounded, Colors.red.shade700, () {}),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, User user) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF06402B), Color(0xFF0A5E3E)],
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
                child: Text(
                  user.name.isNotEmpty ? user.name[0] : 'س',
                  style: GoogleFonts.cairo(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.verified_rounded, color: Color(0xFF0A5E3E), size: 20),
              )
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
              Text(user.id, style: GoogleFonts.dmSans(fontSize: 14, color: Colors.white70, letterSpacing: 1.2)),
              const SizedBox(width: 12),
              Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white54, shape: BoxShape.circle)),
              const SizedBox(width: 12),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Color(0xFFFFC107), size: 16),
                  const SizedBox(width: 4),
                  Text(user.rating.toString(), style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(DriverHomeViewModel vm, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: isDark ? Border.all(color: theme.colorScheme.outline) : null,
            boxShadow: [
              if (!isDark)
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      vm.totalCompletedRides.toString(),
                      style: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
                    ),
                    const SizedBox(height: 4),
                    Text(context.l10n.profileTotalTrips, style: GoogleFonts.cairo(fontSize: 13, color: theme.textTheme.bodyMedium?.color)),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: theme.dividerColor),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${vm.totalEarnings.toStringAsFixed(1)} د.أ',
                      textDirection: TextDirection.ltr,
                      style: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.bold, color: theme.textTheme.bodyLarge?.color),
                    ),
                    const SizedBox(height: 4),
                    Text(context.l10n.profileTotalEarnings, style: GoogleFonts.cairo(fontSize: 13, color: theme.textTheme.bodyMedium?.color)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        textAlign: TextAlign.right,
        style: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
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
            Text(
              title,
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_left_rounded, color: textColor?.withValues(alpha: 0.5), size: 20),
          ],
        ),
      ),
    );
  }
}

class _EditVehicleBottomSheet extends StatefulWidget {
  final DriverHomeViewModel viewModel;
  const _EditVehicleBottomSheet({required this.viewModel});

  @override
  State<_EditVehicleBottomSheet> createState() => _EditVehicleBottomSheetState();
}

class _EditVehicleBottomSheetState extends State<_EditVehicleBottomSheet> {
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _plateController = TextEditingController();
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    final user = widget.viewModel.user;
    _modelController.text = user.vehicleModel ?? '';
    _colorController.text = user.vehicleColor ?? '';
    _plateController.text = user.licensePlate ?? '';
    _photoPath = user.vehiclePhotoPath;
  }

  @override
  void dispose() {
    _modelController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _photoPath = pickedFile.path;
      });
    }
  }

  void _save() {
    widget.viewModel.updateVehicleInfo(
      vehicleModel: _modelController.text.trim().isNotEmpty ? _modelController.text.trim() : null,
      vehicleColor: _colorController.text.trim().isNotEmpty ? _colorController.text.trim() : null,
      licensePlate: _plateController.text.trim().isNotEmpty ? _plateController.text.trim() : null,
      vehiclePhotoPath: _photoPath,
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
            Text(
              context.l10n.profileEditVehicle,
              style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002819)),
            ),
            const SizedBox(height: 24),
            _buildTextField(label: context.l10n.profileVehicleTypeModel, controller: _modelController, hint: context.l10n.profileVehicleTypeModelHint),
            const SizedBox(height: 16),
            _buildTextField(label: context.l10n.profileVehicleColor, controller: _colorController, hint: context.l10n.profileVehicleColorHint),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'رقم اللوحة',
              controller: _plateController,
              hint: '11 - 12345',
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                context.l10n.profileVehiclePhoto,
                style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF404943)),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE6E9E7)),
                ),
                child: _photoPath != null && _photoPath!.isNotEmpty
                    ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(_photoPath!), fit: BoxFit.cover))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_a_photo_rounded, color: Color(0xFF717973), size: 32),
                          const SizedBox(height: 8),
                          Text(context.l10n.profileTapToAddPhoto, style: GoogleFonts.cairo(color: const Color(0xFF717973), fontSize: 14)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06402B),
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

  Widget _buildTextField({
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
          style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF404943)),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: const Color(0xFFF2F4F2), borderRadius: BorderRadius.circular(12)),
          child: TextField(
            controller: controller,
            textDirection: textDirection,
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
