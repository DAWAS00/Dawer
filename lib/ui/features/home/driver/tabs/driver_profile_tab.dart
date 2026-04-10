import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../data/models/user.dart';
import '../../../../features/auth/views/login_view.dart';
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
        title: Text('تسجيل الخروج', textAlign: TextAlign.right, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text('هل أنت متأكد أنك تريد تسجيل الخروج؟', textAlign: TextAlign.right, style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء', style: GoogleFonts.cairo(color: const Color(0xFF717973))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginView()),
                (route) => false,
              );
            },
            child: Text('خروج', style: GoogleFonts.cairo(color: Colors.red, fontWeight: FontWeight.bold)),
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
        : 'أضف معلومات المركبة';

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, user),
              _buildStatsRow(vm),
              const SizedBox(height: 24),
              Row(
                children: [
                  const SizedBox(width: 24),
                  TextButton.icon(
                    onPressed: () => _showEditVehicleBottomSheet(context, vm),
                    icon: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFF06402B)),
                    label: Text('تعديل', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF06402B))),
                  ),
                  const Spacer(),
                  _buildSectionTitle('المعلومات الشخصية والمركبة'),
                ],
              ),
              DriverProfileTile(icon: Icons.phone_rounded, label: 'رقم الهاتف', value: user.phone, showArrow: true),
              DriverProfileTile(icon: Icons.directions_car_rounded, label: 'المركبة', value: vehicleString, showArrow: true),
              DriverProfileTile(icon: Icons.pin_rounded, label: 'رقم اللوحة', value: user.licensePlate ?? 'أضف رقم اللوحة'),
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
              _buildSectionTitle('إعدادات التطبيق'),
              const DriverProfileTile(icon: Icons.language_rounded, label: 'لغة التطبيق', value: 'العربية', showArrow: true),
              const DriverProfileTile(icon: Icons.dark_mode_rounded, label: 'المظهر', value: 'فاتح', showArrow: true),
              const DriverProfileTile(icon: Icons.notifications_active_rounded, label: 'الإشعارات', value: 'مفعلة', showArrow: true),

              const SizedBox(height: 24),
              _buildSectionTitle('المساعدة والدعم'),
              InkWell(
                onTap: _launchHelpCenter,
                child: const DriverProfileTile(icon: Icons.help_center_rounded, label: 'تواصل مع الدعم الفني', value: '', showArrow: true),
              ),

              const SizedBox(height: 32),
              _buildActionTile(context, 'تعديل الملف الشخصي', Icons.edit_rounded, const Color(0xFF002819), () {}),
              _buildActionTile(context, 'تسجيل الخروج', Icons.logout_rounded, Colors.red.shade700, () => _showLogoutDialog(context)),
              _buildActionTile(context, 'حذف الحساب', Icons.person_remove_rounded, Colors.red.shade700, () {}),
              
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

  Widget _buildStatsRow(DriverHomeViewModel vm) {
    return Transform.translate(
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
              Expanded(
                child: Column(
                  children: [
                    Text(
                      vm.totalCompletedRides.toString(),
                      style: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF002819)),
                    ),
                    const SizedBox(height: 4),
                    Text('إجمالي الرحلات', style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF717973))),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: const Color(0xFFE6E9E7)),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${vm.totalEarnings.toStringAsFixed(1)} د.أ',
                      textDirection: TextDirection.ltr,
                      style: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF002819)),
                    ),
                    const SizedBox(height: 4),
                    Text('إجمالي الأرباح', style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF717973))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        textAlign: TextAlign.right,
        style: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF002819),
        ),
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
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
                color: color,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_left_rounded, color: color.withValues(alpha: 0.5), size: 20),
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
              'تعديل معلومات المركبة',
              style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002819)),
            ),
            const SizedBox(height: 24),
            _buildTextField(label: 'نوع المركبة وموديلها', controller: _modelController, hint: 'مثال: تويوتا بريوس'),
            const SizedBox(height: 16),
            _buildTextField(label: 'لون المركبة', controller: _colorController, hint: 'مثال: أبيض'),
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
                'صورة المركبة',
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
                          Text('اضغط لإضافة صورة', style: GoogleFonts.cairo(color: const Color(0xFF717973), fontSize: 14)),
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
                child: Text('حفظ التغييرات', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
