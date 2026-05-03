import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/license_validation_viewmodel.dart';
import '../../../../common/ai_shimmer_loader.dart';
import '../../../../common/animated_status_text.dart';
import '../../../../../l10n/l10n.dart';
import '../../../../../domain/services/i_ai_license_validation_service.dart';

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
                extractedData: vm.extractedData,
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
    final l10n = context.l10n;
    return Column(
      children: [
        Stack(
          children: [
            const AiShimmerLoader(height: 140),
            Positioned.fill(
              child: _ScanningOverlay(animation: _scanCtrl),
            ),
            const Positioned.fill(
              child: _DataPulseOverlay(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _AiSparkleIcon(),
            const SizedBox(width: 8),
            AnimatedStatusText(
              phrases: [
                l10n.aiValidationScanning,
                l10n.aiValidationVerifyingStamps,
                l10n.aiValidationMatchingData,
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

class _ScanningOverlay extends StatelessWidget {
  final Animation<double> animation;
  const _ScanningOverlay({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: 140 * animation.value,
              left: 0,
              right: 0,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4ADE80).withValues(alpha: 0.8),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFF4ADE80).withValues(alpha: 0.6),
                      const Color(0xFF4ADE80),
                      const Color(0xFF4ADE80).withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DataPulseOverlay extends StatefulWidget {
  const _DataPulseOverlay();

  @override
  State<_DataPulseOverlay> createState() => _DataPulseOverlayState();
}

class _DataPulseOverlayState extends State<_DataPulseOverlay> {
  final List<(String, Alignment, int)> _pulses = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startPulses();
  }

  void _startPulses() {
    _timer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!mounted) return;
      final l10n = context.l10n;
      final phrases = [
        l10n.aiPulseStampOk,
        l10n.aiPulseIdMatch,
        l10n.aiPulseExpiryValid,
        l10n.aiPulseSecurePaper,
      ];
      final phrase = phrases[timer.tick % phrases.length];
      final alignments = [
        Alignment.topLeft,
        Alignment.topRight,
        Alignment.bottomLeft,
        Alignment.bottomRight,
        Alignment.centerLeft,
        Alignment.centerRight,
      ];
      final align = alignments[timer.tick % alignments.length];

      setState(() {
        _pulses.add((phrase, align, timer.tick));
      });

      Future.delayed(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _pulses.removeWhere((p) => p.$3 == timer.tick);
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _pulses.map((p) {
        return Align(
          alignment: p.$2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 400),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value * (1.0 - (value > 0.8 ? (value - 0.8) * 5 : 0)),
                  child: Transform.scale(
                    scale: 0.8 + (value * 0.2),
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  p.$1,
                  style: GoogleFonts.dmSans(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4ADE80),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Valid ─────────────────────────────────────────────────────────────────────

class _ValidZone extends StatelessWidget {
  final File? licenseFile;
  final List<String> categories;
  final ExtractedDocData? extractedData;
  final VoidCallback onReset;

  const _ValidZone({
    super.key,
    required this.licenseFile,
    required this.categories,
    required this.extractedData,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                      l10n.aiValidationSuccessTitle,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF166534),
                      ),
                    ),
                    Text(
                      l10n.aiValidationStatusSuccess,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: const Color(0xFF4ADE80),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon:
                    const Icon(Icons.refresh_rounded, color: Color(0xFF166534)),
                onPressed: onReset,
                tooltip: l10n.aiValidationRetryButton,
              ),
            ],
          ),
        ),
        if (extractedData != null) ...[
          const SizedBox(height: 12),
          _ExtractedDataCard(data: extractedData!),
        ],
        if (categories.isNotEmpty) ...[
          const SizedBox(height: 12),
          _CategoryPreviewChips(categories: categories),
        ],
      ],
    );
  }
}

class _ExtractedDataCard extends StatelessWidget {
  final ExtractedDocData data;
  const _ExtractedDataCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined,
                  size: 18, color: Color(0xFF06402B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.aiValidationExtractedData,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF191C1B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _TrustScoreBadge(score: data.confidenceScore),
            ],
          ),
          const SizedBox(height: 16),
          _DataRow(label: l10n.aiValidationDocId, value: data.docId),
          _DataRow(label: l10n.aiValidationOrg, value: data.organization),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.auto_awesome_outlined,
                  size: 14, color: Color(0xFF059669)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  l10n.aiValidationFutureVision,
                  style: GoogleFonts.cairo(
                    fontSize: 10,
                    color: const Color(0xFF059669),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrustScoreBadge extends StatelessWidget {
  final double score;
  const _TrustScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
          Text(
            l10n.aiValidationAuthenticity,
            style: GoogleFonts.cairo(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF065F46),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${(score * 100).toStringAsFixed(1)}%',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF059669),
            ),
          ),
        ],
      ),
    );
  }
}

class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  const _DataRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 11,
              color: const Color(0xFF717973),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF191C1B),
              ),
            ),
          ),
        ],
      ),
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
