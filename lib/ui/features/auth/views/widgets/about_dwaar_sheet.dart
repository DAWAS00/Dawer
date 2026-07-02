import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/state/view_state.dart';
import '../../../../../data/services/app_order_store.dart';
import '../../../../../data/utils/platform_impact_stats.dart';
import '../../../../../domain/failures/app_failure.dart';
import '../../../../../domain/repositories/i_partner_data_request_repository.dart';
import '../../../../../domain/services/co2_certificate_pdf_service.dart';
import '../../../../../l10n/l10n.dart';
import '../../viewmodels/about_dwaar_viewmodel.dart';

/// Opens the "About Dwaar" info sheet from the login screen: who we are,
/// our services per role, how an order works, the reward system, recycling
/// hubs, and a lead-capture form for partners who want to buy our data.
void showAboutDwaarSheet(BuildContext context) {
  final repository = context.read<IPartnerDataRequestRepository>();
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ChangeNotifierProvider<AboutDwaarViewModel>(
      create: (_) => AboutDwaarViewModel(repository: repository),
      child: const _AboutDwaarSheet(),
    ),
  );
}

class _AboutDwaarSheet extends StatelessWidget {
  const _AboutDwaarSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  children: const [
                    _SheetHeader(),
                    SizedBox(height: 20),
                    _IntroSection(),
                    SizedBox(height: 28),
                    _OurImpactSection(),
                    SizedBox(height: 28),
                    _ServicesSection(),
                    SizedBox(height: 28),
                    _HowItWorksSection(),
                    SizedBox(height: 28),
                    _RewardsSection(),
                    SizedBox(height: 28),
                    _HubsSection(),
                    SizedBox(height: 28),
                    _DataRequestSection(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.aboutDwaarSheetTitle,
            style: GoogleFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded, color: AppColors.mutedText),
          tooltip: l10n.aboutDwaarCloseButton,
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textMain,
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  const _BodyText(this.text, {this.color = AppColors.mutedText});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.cairo(fontSize: 14, height: 1.7, color: color),
    );
  }
}

class _IntroSection extends StatelessWidget {
  const _IntroSection();

  @override
  Widget build(BuildContext context) {
    return _BodyText(
      context.l10n.aboutDwaarIntroBody,
      color: AppColors.textMain,
    );
  }
}

/// Live platform-wide impact snapshot + on-demand CO₂ certificate download.
/// No account required — pulls from the same [AppOrderStore] instance that's
/// already provided app-wide (populated before login via the unscoped
/// order stream).
class _OurImpactSection extends StatefulWidget {
  const _OurImpactSection();

  @override
  State<_OurImpactSection> createState() => _OurImpactSectionState();
}

class _OurImpactSectionState extends State<_OurImpactSection> {
  final _pdfService = Co2CertificatePdfService();
  bool _isGenerating = false;
  bool _hasError = false;

  Future<void> _downloadCertificate(PlatformImpactStats stats) async {
    setState(() {
      _isGenerating = true;
      _hasError = false;
    });
    try {
      await _pdfService.generateAndShareCertificate(stats);
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final orders = context.watch<AppOrderStore>().orders;
    final stats = PlatformImpactStats.fromOrders(orders);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(l10n.aboutDwaarImpactTitle),
          const SizedBox(height: 4),
          _BodyText(l10n.aboutDwaarImpactSubtitle),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ImpactStat(
                  value: '${stats.totalOrders}',
                  label: l10n.aboutDwaarImpactOrders,
                  icon: Icons.receipt_long_rounded,
                ),
              ),
              Expanded(
                child: _ImpactStat(
                  value: '${stats.totalWeightKg.toStringAsFixed(0)} كغ',
                  label: l10n.aboutDwaarImpactWeight,
                  icon: Icons.scale_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ImpactStat(
                  value: '${stats.co2SavedKg.toStringAsFixed(0)} كغ',
                  label: l10n.aboutDwaarImpactCo2,
                  icon: Icons.eco_rounded,
                ),
              ),
              Expanded(
                child: _ImpactStat(
                  value: '${stats.waterSavedLiters.toStringAsFixed(0)} ل',
                  label: l10n.aboutDwaarImpactWater,
                  icon: Icons.water_drop_rounded,
                ),
              ),
              Expanded(
                child: _ImpactStat(
                  value: '${stats.energySavedKwh.toStringAsFixed(0)} kWh',
                  label: l10n.aboutDwaarImpactEnergy,
                  icon: Icons.bolt_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_hasError)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                l10n.aboutDwaarImpactDownloadError,
                style: GoogleFonts.cairo(
                  fontSize: 12.5,
                  color: Colors.red.shade700,
                ),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isGenerating
                  ? null
                  : () => _downloadCertificate(stats),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: const BorderSide(color: AppColors.primaryGreen),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: _isGenerating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_rounded, size: 18),
              label: Text(
                _isGenerating
                    ? l10n.aboutDwaarImpactDownloadGenerating
                    : l10n.aboutDwaarImpactDownloadButton,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactStat extends StatelessWidget {
  const _ImpactStat({
    required this.value,
    required this.label,
    required this.icon,
  });
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(fontSize: 10, color: AppColors.mutedText),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primaryGreen, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    height: 1.6,
                    color: AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesSection extends StatelessWidget {
  const _ServicesSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l10n.aboutDwaarServicesTitle),
        const SizedBox(height: 12),
        _ServiceCard(
          icon: Icons.recycling_rounded,
          title: l10n.aboutDwaarServiceSupplierTitle,
          body: l10n.aboutDwaarServiceSupplierBody,
        ),
        const SizedBox(height: 10),
        _ServiceCard(
          icon: Icons.local_shipping_rounded,
          title: l10n.aboutDwaarServiceDriverTitle,
          body: l10n.aboutDwaarServiceDriverBody,
        ),
        const SizedBox(height: 10),
        _ServiceCard(
          icon: Icons.factory_rounded,
          title: l10n.aboutDwaarServiceRecyclingTitle,
          body: l10n.aboutDwaarServiceRecyclingBody,
        ),
      ],
    );
  }
}

class _HowItWorksSection extends StatelessWidget {
  const _HowItWorksSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final steps = [
      l10n.aboutDwaarHowItWorksStep1,
      l10n.aboutDwaarHowItWorksStep2,
      l10n.aboutDwaarHowItWorksStep3,
      l10n.aboutDwaarHowItWorksStep4,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l10n.aboutDwaarHowItWorksTitle),
        const SizedBox(height: 12),
        for (final step in steps) ...[
          _BodyText(step, color: AppColors.textMain),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _RewardsSection extends StatelessWidget {
  const _RewardsSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l10n.aboutDwaarRewardsTitle),
        const SizedBox(height: 10),
        _BodyText(l10n.aboutDwaarRewardsBody),
      ],
    );
  }
}

class _HubsSection extends StatelessWidget {
  const _HubsSection();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(l10n.aboutDwaarHubsTitle),
        const SizedBox(height: 10),
        _BodyText(l10n.aboutDwaarHubsBody),
      ],
    );
  }
}

class _DataRequestSection extends StatefulWidget {
  const _DataRequestSection();

  @override
  State<_DataRequestSection> createState() => _DataRequestSectionState();
}

class _DataRequestSectionState extends State<_DataRequestSection> {
  final _companyController = TextEditingController();
  final _contactController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _companyController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vm = context.watch<AboutDwaarViewModel>();
    final state = vm.state;

    final isLoading = switch (state) {
      Loading() => true,
      _ => false,
    };
    final isSuccess = switch (state) {
      Loaded() => true,
      _ => false,
    };
    final hasGeneralError = switch (state) {
      Failed(:final failure) => failure is! ValidationFailure,
      _ => false,
    };
    final fieldErrors = switch (state) {
      Failed(failure: ValidationFailure(:final fieldErrors)) => fieldErrors,
      _ => const <String, String>{},
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceAltBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(l10n.aboutDwaarDataTitle),
          const SizedBox(height: 8),
          _BodyText(l10n.aboutDwaarDataBody),
          const SizedBox(height: 16),
          if (isSuccess)
            _SuccessBanner(message: l10n.aboutDwaarDataFormSuccess)
          else ...[
            _FormField(
              controller: _companyController,
              label: l10n.aboutDwaarDataFormCompanyLabel,
              errorText: _errorFor('companyName', fieldErrors, l10n),
            ),
            const SizedBox(height: 10),
            _FormField(
              controller: _contactController,
              label: l10n.aboutDwaarDataFormContactNameLabel,
              errorText: _errorFor('contactName', fieldErrors, l10n),
            ),
            const SizedBox(height: 10),
            _FormField(
              controller: _emailController,
              label: l10n.aboutDwaarDataFormEmailLabel,
              keyboardType: TextInputType.emailAddress,
              errorText: _errorFor('email', fieldErrors, l10n),
            ),
            const SizedBox(height: 10),
            _FormField(
              controller: _phoneController,
              label: l10n.aboutDwaarDataFormPhoneLabel,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            _FormField(
              controller: _messageController,
              label: l10n.aboutDwaarDataFormMessageLabel,
              hint: l10n.aboutDwaarDataFormMessageHint,
              maxLines: 3,
            ),
            const SizedBox(height: 8),
            if (hasGeneralError)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  l10n.aboutDwaarDataFormError,
                  style: GoogleFonts.cairo(
                    fontSize: 12.5,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _submit(vm),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isLoading
                      ? l10n.aboutDwaarDataFormSubmitting
                      : l10n.aboutDwaarDataFormSubmit,
                  style: GoogleFonts.cairo(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _errorFor(
    String field,
    Map<String, String> fieldErrors,
    AppLocalizations l10n,
  ) {
    final code = fieldErrors[field];
    if (code == null) return null;
    return code == 'invalid'
        ? l10n.aboutDwaarDataFormEmailInvalid
        : l10n.aboutDwaarDataFormRequired;
  }

  void _submit(AboutDwaarViewModel vm) {
    vm.submit(
      companyName: _companyController.text,
      contactName: _contactController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      message: _messageController.text,
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    this.hint,
    this.errorText,
    this.keyboardType,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final String? errorText;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: GoogleFonts.cairo(fontSize: 14, color: AppColors.textMain),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        filled: true,
        fillColor: AppColors.surface,
        labelStyle: GoogleFonts.cairo(fontSize: 13, color: AppColors.mutedText),
        hintStyle: GoogleFonts.cairo(
          fontSize: 12.5,
          color: AppColors.mutedText,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.statusActiveBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.statusActiveText,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.cairo(
                fontSize: 13.5,
                height: 1.5,
                color: AppColors.statusActiveText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
