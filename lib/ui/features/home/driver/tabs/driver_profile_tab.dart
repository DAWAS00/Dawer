import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../common/theme_mode_sheet.dart';
import '../../../../common/lang_picker_sheet.dart';
import '../../../../../core/services/app_theme_notifier.dart';
import '../../../../../core/services/app_lang_notifier.dart';
import '../../../../../l10n/l10n.dart';
import '../../../../../data/models/order/order.dart' show VehicleType, VehicleTypeLabel;
import '../../../../features/auth/viewmodels/vehicle_registration_viewmodel.dart';
import '../../../../features/auth/views/widgets/vehicle_registration_scan_section.dart';
import '../../shared/profile/profile_actions.dart';
import '../../shared/profile/widgets/profile_header.dart';
import '../../shared/profile/widgets/profile_stat_card.dart';
import '../../shared/profile/widgets/profile_section_header.dart';
import '../../shared/profile/widgets/profile_tile.dart';
import '../../shared/profile/widgets/profile_action_tile.dart';
import '../../shared/profile/widgets/payment_wallet_card.dart';
import '../viewmodels/driver_home_viewmodel.dart';

class DriverProfileTab extends StatelessWidget {
  const DriverProfileTab({super.key});

  Future<void> _launchHelpCenter() async {
    final Uri url = Uri.parse('mailto:support@dwaar.com?subject=مساعدة%20سائق');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
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
              ProfileHeader(
                name: user.name,
                badgeLabel: user.role,
                avatarInitial: user.name.isNotEmpty ? user.name[0] : 'س',
                isVerified: user.isVerified,
                rating: user.rating,
              ),
              ProfileStatCard(
                stats: [
                  ProfileStat(
                    value: vm.totalCompletedRides.toString(),
                    label: context.l10n.profileTotalTrips,
                  ),
                  ProfileStat(
                    value: '${vm.totalEarnings.toStringAsFixed(1)} د.أ',
                    label: context.l10n.profileTotalEarnings,
                  ),
                ],
              ),

              // ── Payment / Wallet ──
              PaymentWalletCard.driver(
                balance: vm.wallet.balance,
                heldAmount: vm.wallet.heldAmount,
                onWithdraw: () {},
              ),

              // ── Personal & vehicle ──
              ProfileSectionHeader(
                title: context.l10n.profilePersonalAndVehicle,
                onEdit: () => _showEditVehicleBottomSheet(context, vm),
              ),
              ProfileTile(icon: Icons.phone_rounded, label: context.l10n.profilePhone, value: user.phone, valueLtr: true, showArrow: true),
              ProfileTile(icon: Icons.directions_car_rounded, label: context.l10n.profileVehicle, value: vehicleString, showArrow: true),
              ProfileTile(icon: Icons.pin_rounded, label: context.l10n.profileLicensePlate, value: user.licensePlate ?? context.l10n.profileAddLicensePlate, valueLtr: true),
              if (user.vehiclePhotoPath != null && user.vehiclePhotoPath!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
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
              ProfileTile(icon: Icons.notifications_active_rounded, label: context.l10n.profileNotifications, value: context.l10n.profileNotificationsEnabled, showArrow: true),

              const SizedBox(height: 24),
              ProfileSectionHeader(title: context.l10n.profileHelpSupport),
              ProfileTile(
                icon: Icons.help_center_rounded,
                label: context.l10n.profileContactSupport,
                showArrow: true,
                onTap: _launchHelpCenter,
              ),

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
  VehicleType? _vehicleType;
  late final VehicleRegistrationViewModel _scanVm;

  @override
  void initState() {
    super.initState();
    final user = widget.viewModel.user;
    _modelController.text = user.vehicleModel ?? '';
    _colorController.text = user.vehicleColor ?? '';
    _plateController.text = user.licensePlate ?? '';
    _photoPath = user.vehiclePhotoPath;
    _vehicleType = user.vehicleType;
    _scanVm = VehicleRegistrationViewModel();
  }

  @override
  void dispose() {
    _modelController.dispose();
    _colorController.dispose();
    _plateController.dispose();
    _scanVm.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() { _photoPath = pickedFile.path; });
    }
  }

  Future<void> _pickRegistration(ImageSource source) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: source, imageQuality: 85, maxWidth: 1200);
    if (xFile != null) await _scanVm.analyzeDocument(File(xFile.path));
  }

  void _applyExtracted(data) {
    setState(() {
      if (data.plateNumber != null) _plateController.text = data.plateNumber!;
      if (data.make != null || data.model != null) {
        _modelController.text = '${data.make ?? ''} ${data.model ?? ''}'.trim();
      }
      if (data.color != null) _colorController.text = data.color!;
      _vehicleType = data.vehicleType;
    });
  }

  void _save() {
    widget.viewModel.updateVehicleInfo(
      vehicleModel: _modelController.text.trim().isNotEmpty ? _modelController.text.trim() : null,
      vehicleColor: _colorController.text.trim().isNotEmpty ? _colorController.text.trim() : null,
      licensePlate: _plateController.text.trim().isNotEmpty ? _plateController.text.trim() : null,
      vehiclePhotoPath: _photoPath,
      vehicleType: _vehicleType,
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
            ChangeNotifierProvider.value(
              value: _scanVm,
              child: VehicleRegistrationScanSection(
                onPick: _pickRegistration,
                onReset: () => setState(() { _scanVm.reset(); }),
                onConfirm: _applyExtracted,
              ),
            ),
            if (_vehicleType != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF86EFAC)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping_rounded, size: 16, color: Color(0xFF166534)),
                    const SizedBox(width: 8),
                    Text('نوع المركبة: ${_vehicleType!.label}',
                      style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF166534))),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('أو أدخل يدوياً',
                  style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF9099A2))),
              ),
              const Expanded(child: Divider()),
            ]),
            const SizedBox(height: 20),
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
