import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../domain/services/i_ai_simulation_service.dart'
    show VerificationResult;
import '../../../../common/ai_shimmer_loader.dart';
import '../../../../common/animated_status_text.dart';
import 'photo_source_picker.dart';

/// Generalized version of VehicleRegistrationScanSection's four-state scan
/// UX (idle → analyzing → result → needs-retake), parameterized so the same
/// widget backs ID cards, driving licenses, and business licenses on Screen 5
/// instead of duplicating that ~600-line vehicle-only component (plan
/// Section 3.3, `docs/design/partner-signup-verification-research-plan.md`).
///
/// Unlike the vehicle scan (which extracts named fields like plate/model),
/// Screen 5 documents only produce a pass/fail [VerificationResult] from
/// [onAnalyze] — so the result state shows a status badge, not a
/// field-by-field extraction card. Per the plan, even an AI "approved"
/// result still shows as pending: human review is a separate, later step
/// (Section 6.4), so this widget never claims final approval.
///
/// All copy is passed in already-localized by the caller (same convention as
/// [showPhotoSourceSheet]) so the widget stays reusable across document
/// types and locales without hardcoded text.
class DocumentAiScanSection extends StatefulWidget {
  final String idlePrompt;
  final String idleHint;
  final List<String> analyzingPhrases;
  final String pendingTitle;
  final String pendingSubtitle;
  final String rejectedTitle;
  final String rescanTooltip;
  final String retryLabel;
  final String cameraLabel;
  final String galleryLabel;

  /// Runs the AI verification check for [document]. Must not throw — callers
  /// (Screen 5's controller wiring) are expected to catch and resolve to a
  /// "pending" [VerificationResult] on any error, matching the orchestrator's
  /// documented never-blocking contract.
  final Future<VerificationResult> Function(File document) onAnalyze;

  /// Notified whenever a new photo is picked (before the AI result comes
  /// back), so the parent can enable "Continue" as soon as *a* photo exists —
  /// Screen 5 never blocks on the AI result itself.
  final ValueChanged<File?>? onFileChanged;

  const DocumentAiScanSection({
    super.key,
    required this.idlePrompt,
    required this.idleHint,
    required this.analyzingPhrases,
    required this.pendingTitle,
    required this.pendingSubtitle,
    required this.rejectedTitle,
    required this.rescanTooltip,
    required this.retryLabel,
    required this.cameraLabel,
    required this.galleryLabel,
    required this.onAnalyze,
    this.onFileChanged,
  });

  @override
  State<DocumentAiScanSection> createState() => DocumentAiScanSectionState();
}

enum _ScanZone { idle, analyzing, result }

class DocumentAiScanSectionState extends State<DocumentAiScanSection> {
  _ScanZone _zone = _ScanZone.idle;
  File? _file;
  VerificationResult? _result;

  File? get file => _file;
  VerificationResult? get result => _result;

  bool get _rejected => _result?.statusMessage == 'signupDocsStatusRejected';

  Future<void> _pick() async {
    final source = await showPhotoSourceSheet(
      context: context,
      cameraLabel: widget.cameraLabel,
      galleryLabel: widget.galleryLabel,
    );
    if (source == null) return;

    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: source, imageQuality: 90);
    if (xfile == null) return;
    if (!mounted) return;

    await _runAnalysis(File(xfile.path));
  }

  /// Test-only entry point that runs the same capture→analyze pipeline as
  /// [_pick], without going through the platform image_picker channel
  /// (which isn't available in widget tests).
  @visibleForTesting
  Future<void> debugAnalyze(File file) => _runAnalysis(file);

  Future<void> _runAnalysis(File file) async {
    setState(() {
      _file = file;
      _zone = _ScanZone.analyzing;
    });
    widget.onFileChanged?.call(file);

    final result = await widget.onAnalyze(file);
    if (!mounted) return;
    setState(() {
      _result = result;
      _zone = _ScanZone.result;
    });
  }

  void reset() {
    setState(() {
      _file = null;
      _result = null;
      _zone = _ScanZone.idle;
    });
    widget.onFileChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: switch (_zone) {
        _ScanZone.idle => _IdleTile(
          key: const ValueKey('idle'),
          prompt: widget.idlePrompt,
          hint: widget.idleHint,
          onTap: _pick,
        ),
        _ScanZone.analyzing => _AnalyzingTile(
          key: const ValueKey('analyzing'),
          phrases: widget.analyzingPhrases,
        ),
        _ScanZone.result =>
          _rejected
              ? _RejectedTile(
                  key: const ValueKey('rejected'),
                  title: widget.rejectedTitle,
                  reason: _result?.statusMessage,
                  retryLabel: widget.retryLabel,
                  onRetry: _pick,
                )
              : _PendingTile(
                  key: const ValueKey('pending'),
                  file: _file,
                  title: widget.pendingTitle,
                  subtitle: widget.pendingSubtitle,
                  rescanTooltip: widget.rescanTooltip,
                  onReset: reset,
                ),
      },
    );
  }
}

// ── Idle ──────────────────────────────────────────────────────────────────────

class _IdleTile extends StatelessWidget {
  final String prompt;
  final String hint;
  final VoidCallback onTap;

  const _IdleTile({
    super.key,
    required this.prompt,
    required this.hint,
    required this.onTap,
  });

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
            color: AppColors.primaryDark.withValues(alpha: 0.25),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignOutside,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.document_scanner_rounded,
                size: 22,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prompt,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF404943),
                    ),
                  ),
                  Text(
                    hint,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: const Color(0xFF717973),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Analyzing ─────────────────────────────────────────────────────────────────

class _AnalyzingTile extends StatelessWidget {
  final List<String> phrases;
  const _AnalyzingTile({super.key, required this.phrases});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [const AiShimmerLoader(height: 140), _ScanLineOverlay()],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🔍', style: TextStyle(fontSize: 10)),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedStatusText(
              phrases: phrases,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ScanLineOverlay extends StatefulWidget {
  @override
  State<_ScanLineOverlay> createState() => _ScanLineOverlayState();
}

class _ScanLineOverlayState extends State<_ScanLineOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Positioned(
        top: 140 * _ctrl.value,
        left: 0,
        right: 0,
        child: Container(
          height: 2,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.aiScanLine.withValues(alpha: 0.8),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.aiScanLine.withValues(alpha: 0.6),
                AppColors.aiScanLine,
                AppColors.aiScanLine.withValues(alpha: 0.6),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Pending (photo captured, AI ran, still awaiting human review) ─────────────

class _PendingTile extends StatelessWidget {
  final File? file;
  final String title;
  final String subtitle;
  final String rescanTooltip;
  final VoidCallback onReset;

  const _PendingTile({
    super.key,
    required this.file,
    required this.title,
    required this.subtitle,
    required this.rescanTooltip,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.verificationPendingBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.verificationPendingText.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          if (file != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                file!,
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
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.verificationPendingText,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: AppColors.verificationPendingText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: AppColors.verificationPendingText,
            ),
            onPressed: onReset,
            tooltip: rescanTooltip,
          ),
        ],
      ),
    );
  }
}

// ── Rejected (AI flagged the document — needs retake, never blocks) ──────────

class _RejectedTile extends StatelessWidget {
  final String title;
  final String? reason;
  final String retryLabel;
  final VoidCallback onRetry;

  const _RejectedTile({
    super.key,
    required this.title,
    required this.reason,
    required this.retryLabel,
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
            color: AppColors.verificationRejectedBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.verificationRejectedText.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_rounded,
                color: AppColors.verificationRejectedText,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.verificationRejectedText,
                  ),
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
            retryLabel,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
