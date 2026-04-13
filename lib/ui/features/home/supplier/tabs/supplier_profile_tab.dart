import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/user.dart';
import '../../../../features/auth/views/login_view.dart';
import '../../../../features/auth/viewmodels/login_viewmodel.dart';

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
        title: Text('تسجيل الخروج', textAlign: TextAlign.right, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text('هل أنت متأكد أنك تريد تسجيل الخروج؟', textAlign: TextAlign.right, style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء', style: GoogleFonts.cairo(color: const Color(0xFF717973))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
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
                        Text(
                          user.id,
                          style: GoogleFonts.dmSans(fontSize: 14, color: Colors.white70, letterSpacing: 1.2),
                        ),
                        const SizedBox(width: 12),
                        Container(width: 4, height: 4, decoration: const BoxDecoration(color: Colors.white54, shape: BoxShape.circle)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isStore ? 'مورد متجر' : 'مورد فردي',
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Row(
                      children: [
                        _buildStatItem(totalPoints.toString(), 'نقاط التدوير'),
                        Container(width: 1, height: 40, color: const Color(0xFFE6E9E7)),
                        _buildStatItem(totalOrders.toString(), 'إجمالي الطلبات'),
                      ],
                    ),
                  ),
                ),
              ),

              // Personal info section
              Row(
                children: [
                  const SizedBox(width: 24),
                  TextButton.icon(
                    onPressed: () => _showEditProfileSheet(context),
                    icon: const Icon(Icons.edit_rounded, size: 16, color: Color(0xFF1E5C35)),
                    label: Text('تعديل', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF1E5C35))),
                  ),
                  const Spacer(),
                  _buildSectionTitle('المعلومات الشخصية'),
                ],
              ),
              _buildProfileTile(Icons.phone_rounded, 'رقم الهاتف', user.phone),
              _buildProfileTile(Icons.location_on_rounded, 'العنوان', user.address ?? 'أضف العنوان'),
              _buildProfileTile(
                Icons.badge_rounded,
                'الهوية',
                user.isVerified ? 'تم التحقق' : 'لم يتم التحقق',
                valueColor: user.isVerified ? const Color(0xFF166534) : const Color(0xFFC8860A),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('إعدادات التطبيق'),
              _buildProfileTile(Icons.language_rounded, 'لغة التطبيق', 'العربية'),
              _buildProfileTile(Icons.dark_mode_rounded, 'المظهر', 'فاتح'),
              _buildProfileTile(Icons.notifications_active_rounded, 'الإشعارات', 'مفعلة'),

              const SizedBox(height: 32),
              _buildActionTile(context, 'تعديل الملف الشخصي', Icons.edit_rounded, const Color(0xFF002819), () => _showEditProfileSheet(context)),
              _buildActionTile(context, 'تسجيل الخروج', Icons.logout_rounded, Colors.red.shade700, () => _showLogoutDialog(context)),
              _buildActionTile(context, 'حذف الحساب', Icons.person_remove_rounded, Colors.red.shade700, () {}),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF002819))),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF717973))),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: Text(
          title,
          style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF002819)),
        ),
      ),
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
          Text(
            value,
            style: GoogleFonts.cairo(fontSize: 14, color: valueColor ?? const Color(0xFF404943), fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Text(label, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF002819))),
          const SizedBox(width: 10),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1E5C35).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF1E5C35)),
          ),
        ],
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
            Icon(Icons.chevron_left_rounded, color: color.withValues(alpha: 0.5), size: 20),
            const Spacer(),
            Text(title, style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(width: 16),
            Icon(icon, color: color, size: 22),
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
            Text('تعديل الملف الشخصي', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF002819))),
            const SizedBox(height: 24),
            _buildField(label: 'الاسم', controller: _nameCtrl, hint: 'أدخل اسمك'),
            const SizedBox(height: 16),
            _buildField(label: 'رقم الهاتف', controller: _phoneCtrl, hint: '+962 7X XXX XXXX', textDirection: TextDirection.ltr),
            const SizedBox(height: 16),
            _buildField(label: 'العنوان', controller: _addressCtrl, hint: 'أدخل عنوانك'),
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
                child: Text('حفظ التغييرات', style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
