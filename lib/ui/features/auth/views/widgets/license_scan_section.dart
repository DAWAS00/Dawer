import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/license_validation_viewmodel.dart';
import '../../../../common/ai_shimmer_loader.dart';
import '../../../../common/animated_status_text.dart';

/// Drop-in replacement for [IdentityUploadCard] that runs AI validation
/// on the picked document and surfaces suggested marketplace categories.
///
/// Requires [LicenseValidationViewModel] in the widget tree via Provider.
/// Calls [onPick] to trigger the actual file pick + analysis.
/// Calls [onReset] to clear the document and restart the flow.
class LicenseScanSection extends StatelessWidget {
  final Future<void> Function(ImageSource source) onPick;
  final VoidCallback onReset;
  final String label;

  const LicenseScanSection({
    super.key,
    required this.onPick,
    required this.onReset,
    required this.label,
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              const SizedBox(height: 16),
              _SheetTile(
                icon: Icons.camera_alt_rounded,
                label: 'الكاميرا', // TODO: localize
                onTap: () {
                  Navigator.pop(context);
                  onPick(ImageSource.camera);
                },
              ),
              _SheetTile(
                icon: Icons.photo_library_rounded,
                label: 'معرض الصور', // TODO: localize
                onTap: () {
                  Navigator.pop(context);
                  onPick(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LicenseValidationViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                licenseFile: vm.licenseFile,
                categories: vm.suggestedCategories,
                onReset: onReset,
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

// ── Idle ─────────────────────────────────────────────────────────────────────

class _IdleZone extends StatelessWidget {
  final VoidCallback onTap;
  const _IdleZone({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF06402B).withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF06402B).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.upload_file_rounded,
                size: 24,
                color: Color(0xFF06402B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'انقر لرفع الوثيقة', // TODO: localize
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF404943),
              ),
            ),
            Text(
              'كاميرا أو معرض الصور', // TODO: localize
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: const Color(0xFF717973),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Analyzing ─────────────────────────────────────────────────────────────────

class _AnalyzingZone extends StatelessWidget {
  const _AnalyzingZone({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AiShimmerLoader(height: 110),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _AiSparkleIcon(),
            const SizedBox(width: 8),
            AnimatedStatusText(
              phrases: const [
                'جاري تحليل الوثيقة...', // TODO: localize
                'التحقق من صحة المستند...', // TODO: localize
                'استخراج البيانات...', // TODO: localize
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

// ── Valid ─────────────────────────────────────────────────────────────────────

class _ValidZone extends StatelessWidget {
  final File? licenseFile;
  final List<String> categories;
  final VoidCallback onReset;

  const _ValidZone({
    super.key,
    required this.licenseFile,
    required this.categories,
    required this.onReset,
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
              if (licenseFile != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    licenseFile!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تم التحقق ✓', // TODO: localize
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF166534),
                      ),
                    ),
                    Text(
                      'الوثيقة صالحة', // TODO: localize
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: const Color(0xFF4ADE80),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFF166534)),
                onPressed: onReset,
                tooltip: 'إعادة الرفع', // TODO: localize
              ),
            ],
          ),
        ),
        if (categories.isNotEmpty) ...[
          const SizedBox(height: 12),
          _CategoryPreviewChips(categories: categories),
        ],
      ],
    );
  }
}

// ── Invalid ────────────────────────────────────────────────────────────────────

class _InvalidZone extends StatelessWidget {
  final String? reason;
  final VoidCallback onRetry;

  const _InvalidZone({
    super.key,
    required this.reason,
    required this.onRetry,
  });

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
                    Text(
                      'فشل التحقق', // TODO: localize
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade800,
                      ),
                    ),
                    if (reason != null)
                      Text(
                        reason!,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.red.shade700,
                        ),
                      ),
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
          label: Text(
            'حاول مرة أخرى', // TODO: localize
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}

// ── Category preview chips ─────────────────────────────────────────────────────

class _CategoryPreviewChips extends StatelessWidget {
  final List<String> categories;
  const _CategoryPreviewChips({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _AiSparkleIcon(),
              const SizedBox(width: 6),
              Text(
                'فئات مقترحة في السوق', // TODO: localize
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF166534),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: categories
                .map((cat) => _CategoryChip(label: cat))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  const _CategoryChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF06402B).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF06402B).withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF06402B),
        ),
      ),
    );
  }
}

// ── AI sparkle icon ───────────────────────────────────────────────────────────

class _AiSparkleIcon extends StatelessWidget {
  const _AiSparkleIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: const Color(0xFF06402B).withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text('✨', style: TextStyle(fontSize: 10)),
      ),
    );
  }
}

// ── Sheet tile ────────────────────────────────────────────────────────────────

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF191C1B)),
      title: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF191C1B),
        ),
      ),
      onTap: onTap,
    );
  }
}
