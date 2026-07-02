import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dwaar/data/models/order/order.dart';
import 'package:dwaar/data/utils/eco_impact_calculator.dart';
import 'package:dwaar/l10n/l10n.dart';
import 'package:dwaar/ui/common/map/location_picker_screen.dart';
import 'package:dwaar/ui/features/home/supplier/controllers/publish_form_controller.dart';
import 'wizard_style_tokens.dart';

class Step3LocationAndReview extends StatelessWidget {
  final PublishFormController controller;

  const Step3LocationAndReview({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _StepHeader(
            title: l10n.wizardStep3Title,
            subtitle: l10n.wizardStep3Subtitle,
          ),

          _FieldLabel(text: l10n.wizardPickupAddress),
          const SizedBox(height: 10),
          _LocationCard(
            hasLocation: controller.pickedLat != null,
            address: controller.pickedAddress ?? l10n.wizardTapToSetLocation,
            changeLabel: l10n.wizardChangeLocation,
            onTap: () async {
              final result = await Navigator.push<(double, double)?>(
                context,
                MaterialPageRoute(
                  builder: (_) => LocationPickerScreen(
                    initialLat: controller.pickedLat,
                    initialLng: controller.pickedLng,
                  ),
                ),
              );
              if (result != null) {
                controller.updateLocation(result.$1, result.$2);
              }
            },
          ),
          const SizedBox(height: 12),
          _CurrentLocationButton(controller: controller, label: l10n.wizardUseCurrentLocation),
          const SizedBox(height: 20),

          _FieldLabel(text: l10n.wizardNotesOptional),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: WizardColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: WizardColors.border),
            ),
            child: TextField(
              controller: controller.notesCtrl,
              maxLines: 3,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.cairo(fontSize: 13, color: WizardColors.textPrimary),
              decoration: InputDecoration(
                hintText: l10n.wizardNotesHint,
                hintStyle: const TextStyle(fontSize: 13, color: WizardColors.textHint),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 20),

          _FieldLabel(text: l10n.wizardListingSummary),
          const SizedBox(height: 10),
          _SummaryCard(controller: controller),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final bool hasLocation;
  final String address;
  final String changeLabel;
  final VoidCallback onTap;

  const _LocationCard({
    required this.hasLocation,
    required this.address,
    required this.changeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: hasLocation ? WizardColors.primaryLight : WizardColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasLocation ? WizardColors.borderSelected : WizardColors.border,
            width: hasLocation ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              child: Container(
                height: 90,
                color: const Color(0xFFDCEDDC),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ...List.generate(5, (i) => Positioned(
                      left: i * 60.0,
                      top: 0,
                      bottom: 0,
                      child: Container(width: 0.5, color: const Color(0xFFA5C8A5)),
                    )),
                    ...List.generate(4, (i) => Positioned(
                      top: i * 22.5,
                      left: 0,
                      right: 0,
                      child: Container(height: 0.5, color: const Color(0xFFA5C8A5)),
                    )),
                    Icon(
                      Icons.location_pin,
                      size: 36,
                      color: hasLocation ? WizardColors.primaryMid : WizardColors.textHint,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: WizardColors.primaryMid,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      changeLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Expanded(
                    child: Text(
                      address,
                      style: hasLocation
                          ? GoogleFonts.robotoMono(
                              fontSize: 11,
                              color: WizardColors.primaryMid,
                            )
                          : GoogleFonts.cairo(
                              fontSize: 11,
                              color: WizardColors.textSecondary,
                            ),
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
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

class _CurrentLocationButton extends StatelessWidget {
  final PublishFormController controller;
  final String label;
  const _CurrentLocationButton({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final loc = await controller.locationService.getCurrentLocation();
        if (loc != null) {
          controller.updateLocation(loc.lat, loc.lng);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        decoration: BoxDecoration(
          color: WizardColors.scaffold,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: WizardColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: WizardColors.primaryMid,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.my_location_rounded, size: 16, color: WizardColors.primaryMid),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final PublishFormController controller;
  const _SummaryCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Locale-aware separator for joining multiple waste-type labels.
    final isAr = Localizations.localeOf(context).languageCode == 'ar';
    final impact = EcoImpactCalculator.calculate(
      controller.selectedTypes.toList(),
      controller.weightCategory,
    );

    return Container(
      decoration: BoxDecoration(
        color: WizardColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: WizardColors.border),
      ),
      child: Column(
        children: [
          _SummaryRow(
            icon: Icons.recycling_outlined,
            label: l10n.wizardSummaryMaterialType,
            value: controller.selectedTypes.isNotEmpty
                ? controller.selectedTypes.map((t) => t.label).join(isAr ? '، ' : ', ')
                : '—',
            hasValue: controller.selectedTypes.isNotEmpty,
          ),
          _SummaryRow(
            icon: Icons.category_outlined,
            label: l10n.wizardSummaryCondition,
            value: controller.wasteForm?.label ?? '—',
            hasValue: controller.wasteForm != null,
          ),
          _SummaryRow(
            icon: Icons.monitor_weight_outlined,
            label: l10n.wizardSummaryQuantity,
            value: controller.weightCategory != null
                ? '${controller.weightCategory!.shortLabel} (${controller.weightCategory!.label})'
                : '—',
            hasValue: controller.weightCategory != null,
          ),
          _SummaryRow(
            icon: Icons.sell_outlined,
            label: l10n.wizardSummaryPrice,
            value: controller.priceCtrl.text.isNotEmpty
                ? l10n.marketListingPrice(controller.priceCtrl.text)
                : l10n.wizardPriceUndefined,
            hasValue: controller.priceCtrl.text.isNotEmpty,
          ),
          _SummaryRow(
            icon: Icons.eco_rounded,
            label: l10n.wizardCo2Savings,
            value: l10n.orderWeightKgLabel(impact.co2SavedKg.toStringAsFixed(1)),
            hasValue: true,
            color: const Color(0xFF059669),
          ),
          _SummaryRow(
            icon: Icons.water_drop_rounded,
            label: l10n.wizardWaterSavings,
            value: l10n.wizardWaterLiters(impact.waterSavedLiters.toStringAsFixed(0)),
            hasValue: true,
            color: const Color(0xFF1E40AF),
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool hasValue;
  final bool isLast;
  final Color? color;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.hasValue,
    this.isLast = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(bottom: BorderSide(color: WizardColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? WizardColors.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.cairo(fontSize: 12, color: WizardColors.textSecondary),
          ),
          const Spacer(),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: hasValue ? (color ?? WizardColors.primaryMid) : WizardColors.textHint,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _StepHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: WizardColors.textPrimary,
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.cairo(fontSize: 13, color: WizardColors.textSecondary),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: WizardColors.textSecondary,
        ),
      ),
    );
  }
}