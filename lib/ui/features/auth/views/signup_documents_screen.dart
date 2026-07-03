import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../data/models/user_role.dart';
import '../../../../domain/repositories/i_auth_repository.dart';
import '../../../../domain/services/i_ai_simulation_service.dart'
    show VerificationResult;
import '../../../../l10n/l10n.dart';
import '../../home/home_router.dart';
import '../controllers/signup_controller.dart';
import 'widgets/document_ai_scan_section.dart';
import 'widgets/onboarding_shared_widgets.dart';

/// Screen 5 of the signup flow: document / license verification.
///
/// Role-branches between an ID-document flow (driver, individual supplier)
/// and a business-license flow (store-business supplier, recycling
/// company), per `docs/design/partner-signup-verification-research-plan.md`
/// Section 3. Like Screen 4, this screen is non-blocking — skipping it (or
/// an AI rejection) never prevents entry to the app; only capability gates
/// downstream (e.g. accepting jobs) depend on `profiles.is_verified`.
class SignupDocumentsScreen extends StatelessWidget {
  final SignupController controller;
  final AuthSession session;

  const SignupDocumentsScreen({
    super.key,
    required this.controller,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      // .value = don't dispose; controller lifecycle is owned by Screen 3's provider.
      value: controller,
      child: _DocumentsBody(session: session),
    );
  }
}

class _DocumentsBody extends StatefulWidget {
  final AuthSession session;
  const _DocumentsBody({required this.session});

  @override
  State<_DocumentsBody> createState() => _DocumentsBodyState();
}

class _DocumentsBodyState extends State<_DocumentsBody> {
  bool _hasFile = false;

  SignupController get _ctrl => context.read<SignupController>();

  void _navigateHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => HomeRouter(
          role: widget.session.role,
          supplierType: widget.session.supplierType ?? SupplierType.individual,
          userName: widget.session.userName,
        ),
      ),
      (route) => false,
    );
  }

  Future<VerificationResult> _analyze(File document) async {
    final result = await _ctrl.runDocumentCheck(document);
    return result ??
        const VerificationResult(
          isVerified: false,
          statusMessage: 'signupDocsStatusPending',
        );
  }

  Future<void> _continue() async {
    if (_ctrl.requiresBusinessDocument) {
      if (_ctrl.businessLicenseDocument != null) {
        await _ctrl.submitBusinessLicense();
      }
    } else {
      if (_ctrl.identityDocument != null) {
        await _ctrl.submitDocuments();
      }
    }
    if (!mounted) return;
    _navigateHome();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = context.watch<SignupController>();
    final isBusiness = controller.requiresBusinessDocument;

    return PopScope(
      // Same as Screen 4 — the account already exists, so back just goes
      // home rather than un-completing the signup flow.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _navigateHome();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded),
            onPressed: _navigateHome,
            tooltip: l10n.navHome,
          ),
          title: Text(l10n.signupDocsTitle, style: GoogleFonts.cairo()),
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: context.dt.onSurface,
          actions: [
            TextButton(
              onPressed: _navigateHome,
              child: Text(
                l10n.signupSkip,
                style: GoogleFonts.cairo(
                  color: const Color(0xFF717973),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isBusiness
                      ? l10n.signupDocsBusinessHeading
                      : l10n.signupDocsIdHeading,
                  style: GoogleFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF191C1B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isBusiness
                      ? l10n.signupDocsBusinessSubtitle
                      : l10n.signupDocsIdSubtitle,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: const Color(0xFF717973),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),

                OnboardingSectionCard(
                  title: isBusiness
                      ? l10n.signupDocsBusinessSectionTitle
                      : l10n.signupDocsIdSectionTitle,
                  icon: isBusiness
                      ? Icons.business_center_rounded
                      : Icons.badge_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Trust microcopy (plan Section 3.4) — states why the
                      // document is needed before asking for it.
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.shield_outlined,
                              size: 16,
                              color: Color(0xFF166534),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isBusiness
                                    ? l10n.signupDocsTrustNoticeBusiness
                                    : l10n.signupDocsTrustNoticeId,
                                style: GoogleFonts.cairo(
                                  fontSize: 11,
                                  color: const Color(0xFF166534),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      DocumentAiScanSection(
                        idlePrompt: isBusiness
                            ? l10n.signupDocsBusinessScanPrompt
                            : l10n.signupDocsIdScanPrompt,
                        idleHint: isBusiness
                            ? l10n.signupDocsBusinessScanHint
                            : l10n.signupDocsIdScanHint,
                        analyzingPhrases: isBusiness
                            ? [
                                l10n.signupDocsAnalyzingBusinessStep1,
                                l10n.signupDocsAnalyzingBusinessStep2,
                                l10n.signupDocsAnalyzingBusinessStep3,
                              ]
                            : [
                                l10n.signupDocsAnalyzingIdStep1,
                                l10n.signupDocsAnalyzingIdStep2,
                                l10n.signupDocsAnalyzingIdStep3,
                              ],
                        pendingTitle: l10n.signupDocsPendingTitle,
                        pendingSubtitle: l10n.signupDocsPendingSubtitle,
                        rejectedTitle: l10n.signupDocsRejectedTitle,
                        rescanTooltip: l10n.vehicleScanRescanTooltip,
                        retryLabel: l10n.aiValidationRetryButton,
                        cameraLabel: l10n.imagePickerCamera,
                        galleryLabel: l10n.imagePickerGallery,
                        onAnalyze: _analyze,
                        onFileChanged: (file) {
                          if (isBusiness) {
                            controller.businessLicenseDocument = file;
                          } else {
                            controller.identityDocument = file;
                          }
                          setState(() => _hasFile = file != null);
                        },
                      ),
                    ],
                  ),
                ),

                if (controller.error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Text(
                      controller.error!,
                      style: GoogleFonts.cairo(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (_hasFile && !controller.isSubmitting)
                        ? _continue
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06402B),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE6E9E7),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: controller.isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            l10n.signupDocsContinue,
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: controller.isSubmitting ? null : _navigateHome,
                  child: Text(
                    l10n.signupSkipCompleteLater,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: const Color(0xFF717973),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
