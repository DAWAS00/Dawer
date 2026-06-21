import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/vehicle_registration_viewmodel.dart';
import '../../../../common/ai_shimmer_loader.dart';
import '../../../../common/animated_status_text.dart';
import '../../../../../data/models/order/order.dart' show VehicleTypeLabel;
import '../../../../../domain/services/i_ai_vehicle_registration_service.dart';

/// Reuses the same scanning UX as [LicenseScanSection] but targets vehicle
/// registration documents. On confirmation, calls [onConfirm] with the
/// extracted data so the parent can auto-fill its form fields.
///
/// Requires [VehicleRegistrationViewModel] in the widget tree via Provider.
class VehicleRegistrationScanSection extends StatelessWidget {
  final Future<void> Function(ImageSource source) onPick;
  final VoidCallback onReset;
  final void Function(ExtractedVehicleData data) onConfirm;

  const VehicleRegistrationScanSection({
    super.key,
    required this.onPick,
    required this.onReset,
    required this.onConfirm,
  });

  void _showSourceSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              const SizedBox(height: 16),
              _SheetTile(
                icon: Icons.camera_alt_rounded,
                label: 'الكاميرا',
                onTap: () { Navigator.pop(context); onPick(ImageSource.camera); },
              ),
              _SheetTile(
                icon: Icons.photo_library_rounded,
                label: 'معرض الصور',
                onTap: () { Navigator.pop(context); onPick(ImageSource.gallery); },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VehicleRegistrationViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.directions_car_rounded, size: 16, color: Color(0xFF06402B)),
            const SizedBox(width: 6),
            Text(
              'مسح استمارة المركبة',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF404943),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Text(
                'اختياري',
                style: GoogleFonts.cairo(fontSize: 10, color: const Color(0xFF166534)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: switch (vm.state) {
            LicenseValidationState.idle => _IdleZone(
                key: const ValueKey('idle'),
                onTap: () => _showSourceSheet(context),
              ),
            LicenseValidationState.analyzing => const _AnalyzingZone(
                key: ValueKey('analyzing'),
              ),
            LicenseValidationState.valid => _ValidZone(
                key: const ValueKey('valid'),
                file: vm.registrationFile,
                data: vm.extractedData!,
                onReset: onReset,
                onConfirm: () => onConfirm(vm.extractedData!),
              ),
            LicenseValidationState.invalid => _InvalidZone(
                key: const ValueKey('invalid'),
                reason: vm.failReason,
                onRetry: () => _showSourceSheet(context),
              ),
          },
        ),
      ],
    );
  }
}

// ── Idle ──────────────────────────────────────────────────────────────────────

class _IdleZone extends StatelessWidget {
  final VoidCallback onTap;
  const _IdleZone({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF06402B).withValues(alpha: 0.25),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF06402B).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.document_scanner_rounded, size: 22, color: Color(0xFF06402B)),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'امسح الاستمارة لملء البيانات تلقائياً',
                  style: GoogleFonts.cairo(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: const Color(0xFF404943),
                  ),
                ),
                Text(
                  'يُحدَّد نوع المركبة من الوثيقة',
                  style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF717973)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Analyzing ─────────────────────────────────────────────────────────────────

class _AnalyzingZone extends StatefulWidget {
  const _AnalyzingZone({super.key});
  @override
  State<_AnalyzingZone> createState() => _AnalyzingZoneState();
}

class _AnalyzingZoneState extends State<_AnalyzingZone>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanCtrl;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            const AiShimmerLoader(height: 140),
            Positioned.fill(child: _VehicleScanOverlay(animation: _scanCtrl)),
            const Positioned.fill(child: _VehiclePulseOverlay()),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _sparkle(),
            const SizedBox(width: 8),
            AnimatedStatusText(
              phrases: const [
                'فحص نوع المركبة...',
                'قراءة رقم اللوحة...',
                'تحليل موديل السيارة...',
                'التحقق من تاريخ الانتهاء...',
              ],
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: const Color(0xFF06402B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VehicleScanOverlay extends StatelessWidget {
  final Animation<double> animation;
  const _VehicleScanOverlay({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Stack(children: [
        Positioned(
          top: 140 * animation.value,
          left: 0, right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF60A5FA).withValues(alpha: 0.8),
                  blurRadius: 12, spreadRadius: 2,
                ),
              ],
              gradient: LinearGradient(colors: [
                Colors.transparent,
                const Color(0xFF60A5FA).withValues(alpha: 0.6),
                const Color(0xFF60A5FA),
                const Color(0xFF60A5FA).withValues(alpha: 0.6),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _VehiclePulseOverlay extends StatefulWidget {
  const _VehiclePulseOverlay();
  @override
  State<_VehiclePulseOverlay> createState() => _VehiclePulseOverlayState();
}

class _VehiclePulseOverlayState extends State<_VehiclePulseOverlay> {
  final List<(String, Alignment, int)> _pulses = [];
  Timer? _timer;

  static const _phrases = [
    'نوع المركبة ✓',
    'رقم اللوحة...',
    'الموديل ✓',
    'تاريخ الانتهاء...',
    'اللون ✓',
    'الاستمارة سارية',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 700), (t) {
      if (!mounted) return;
      final phrase = _phrases[t.tick % _phrases.length];
      final aligns = [
        Alignment.topLeft, Alignment.topRight,
        Alignment.bottomLeft, Alignment.bottomRight,
        Alignment.centerLeft, Alignment.centerRight,
      ];
      final align = aligns[t.tick % aligns.length];
      setState(() => _pulses.add((phrase, align, t.tick)));
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) setState(() => _pulses.removeWhere((p) => p.$3 == t.tick));
      });
    });
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _pulses.map((p) => Align(
        alignment: p.$2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 400),
            builder: (_, v, child) => Opacity(
              opacity: v * (1.0 - (v > 0.8 ? (v - 0.8) * 5 : 0)),
              child: Transform.scale(scale: 0.8 + v * 0.2, child: child),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(p.$1,
                style: GoogleFonts.dmSans(
                  fontSize: 9, fontWeight: FontWeight.bold,
                  color: const Color(0xFF60A5FA),
                ),
              ),
            ),
          ),
        ),
      )).toList(),
    );
  }
}

// ── Valid ─────────────────────────────────────────────────────────────────────

class _ValidZone extends StatelessWidget {
  final File? file;
  final ExtractedVehicleData data;
  final VoidCallback onReset;
  final VoidCallback onConfirm;

  const _ValidZone({
    super.key,
    required this.file,
    required this.data,
    required this.onReset,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF86EFAC)),
          ),
          child: Row(
            children: [
              if (file != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(file!, width: 56, height: 56, fit: BoxFit.cover),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تم قراءة الوثيقة بنجاح',
                      style: GoogleFonts.cairo(
                        fontSize: 15, fontWeight: FontWeight.bold,
                        color: const Color(0xFF166534),
                      )),
                    Text('راجع البيانات وأكّد',
                      style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF4ADE80))),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFF166534)),
                onPressed: onReset,
                tooltip: 'إعادة المسح',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _ExtractedVehicleCard(data: data),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: onConfirm,
            icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
            label: Text('تأكيد وملء البيانات تلقائياً',
              style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF06402B),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}

class _ExtractedVehicleCard extends StatelessWidget {
  final ExtractedVehicleData data;
  const _ExtractedVehicleCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final expiry = data.registrationExpiry;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, size: 18, color: Color(0xFF06402B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text('البيانات المستخرجة',
                  style: GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF191C1B))),
              ),
              _ConfidenceBadge(score: data.confidenceScore),
            ],
          ),
          const SizedBox(height: 12),
          // Vehicle type chip — the most important field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF06402B).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFF06402B).withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_shipping_rounded, size: 14, color: Color(0xFF06402B)),
                const SizedBox(width: 6),
                Text(
                  '${data.vehicleClass}  ·  ${data.vehicleType.label}',
                  style: GoogleFonts.cairo(
                    fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF06402B)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (data.make != null || data.model != null)
            _Row('الموديل', '${data.make ?? ''} ${data.model ?? ''}'.trim()),
          if (data.color != null)
            _Row('اللون', data.color!),
          if (data.plateNumber != null)
            _Row('رقم اللوحة', data.plateNumber!),
          if (expiry != null)
            _Row('تاريخ انتهاء الاستمارة',
              '${expiry.day}/${expiry.month}/${expiry.year}'),
          if (data.hasChemicalPermit) ...[
            const Divider(height: 20),
            Row(
              children: [
                const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF059669)),
                const SizedBox(width: 6),
                Text('تصريح نقل مواد كيميائية',
                  style: GoogleFonts.cairo(
                    fontSize: 11, color: const Color(0xFF059669), fontWeight: FontWeight.w600)),
              ],
            ),
          ],
          const Divider(height: 20),
          Row(
            children: [
              const Icon(Icons.auto_awesome_outlined, size: 14, color: Color(0xFF059669)),
              const SizedBox(width: 6),
              Expanded(
                child: Text('سيتم تصفية الطلبات تلقائياً بناءً على نوع مركبتك',
                  style: GoogleFonts.cairo(
                    fontSize: 10, color: const Color(0xFF059669), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
            style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF717973), fontWeight: FontWeight.w500)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF191C1B))),
          ),
        ],
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final double score;
  const _ConfidenceBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('دقة', style: GoogleFonts.cairo(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF065F46))),
          const SizedBox(width: 4),
          Text('${(score * 100).toStringAsFixed(1)}%',
            style: GoogleFonts.dmSans(fontSize: 10, fontWeight: FontWeight.w900, color: const Color(0xFF059669))),
        ],
      ),
    );
  }
}

// ── Invalid ───────────────────────────────────────────────────────────────────

class _InvalidZone extends StatelessWidget {
  final String? reason;
  final VoidCallback onRetry;
  const _InvalidZone({super.key, required this.reason, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.red.shade300),
          ),
          child: Row(
            children: [
              Icon(Icons.error_rounded, color: Colors.red.shade600, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('تعذّر قراءة الوثيقة',
                      style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red.shade800)),
                    if (reason != null)
                      Text(reason!,
                        style: GoogleFonts.cairo(fontSize: 12, color: Colors.red.shade700)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.upload_file_rounded),
          label: Text('حاول مرة أخرى', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

Widget _sparkle() => Container(
  width: 20, height: 20,
  decoration: BoxDecoration(
    color: const Color(0xFF06402B).withValues(alpha: 0.1),
    shape: BoxShape.circle,
  ),
  child: const Center(child: Text('✨', style: TextStyle(fontSize: 10))),
);

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SheetTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF191C1B)),
      title: Text(label,
        style: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF191C1B))),
      onTap: onTap,
    );
  }
}
