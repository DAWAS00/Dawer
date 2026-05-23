import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../data/models/order.dart';
import '../../../../../../data/utils/eco_impact_calculator.dart';
import '../../../../../common/map/location_picker_screen.dart';
import '../../controllers/publish_form_controller.dart';

class Step3LocationAndReview extends StatelessWidget {
  final PublishFormController controller;

  const Step3LocationAndReview({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const _StepHeader(
            title: 'آخر خطوة!',
            subtitle: 'حدد موقع الاستلام وراجع الإعلان قبل النشر',
          ),
          const _FieldLabel(text: 'عنوان الاستلام *'),
          const SizedBox(height: 10),
          _LocationCard(
            hasLocation: controller.pickedLat != null,
            address: controller.pickedAddress,
            resolving: controller.resolvingAddress,
            controller: controller,
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
          const SizedBox(height: 24),
          const _FieldLabel(text: 'ملاحظات — اختياري'),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: TextField(
              controller: controller.notesCtrl,
              maxLines: 3,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF1A1A1A)),
              decoration: const InputDecoration(
                hintText: 'مثال: الكمية تقريباً ٣٠ كيس بلاستيك...',
                hintStyle: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _FieldLabel(text: 'ملخص الإعلان والتأثير البيئي'),
          const SizedBox(height: 10),
          _SummaryCard(controller: controller),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final bool hasLocation;
  final String? address;
  final bool resolving;
  final VoidCallback onTap;
  final PublishFormController controller;

  const _LocationCard({
    required this.hasLocation,
    this.address,
    required this.resolving,
    required this.onTap,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: hasLocation ? const Color(0xFFE8F5E9) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasLocation ? const Color(0xFF2E7D32) : const Color(0xFFE0E0E0),
                width: hasLocation ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDCEDDC),
                      image: DecorationImage(
                        image: AssetImage('assets/images/sample_wood.jpg'), // Placeholder for map look
                        fit: BoxFit.cover,
                        opacity: 0.1,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Map grid simulation
                        for (var i = 0; i < 6; i++)
                          Positioned(
                            left: i * 70.0,
                            top: 0,
                            bottom: 0,
                            child: Container(width: 0.5, color: const Color(0xFFA5C8A5)),
                          ),
                        for (var i = 0; i < 4; i++)
                          Positioned(
                            top: i * 40.0,
                            left: 0,
                            right: 0,
                            child: Container(height: 0.5, color: const Color(0xFFA5C8A5)),
                          ),
                        
                        Icon(
                          Icons.location_pin,
                          size: 48,
                          color: hasLocation ? const Color(0xFF2E7D32) : const Color(0xFFAAAAAA),
                        ),
                        if (resolving)
                          const CircularProgressIndicator(strokeWidth: 3, color: Color(0xFF2E7D32)),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E7D32),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'تغيير الموقع',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              resolving
                                  ? 'جاري تحديد العنوان...'
                                  : (hasLocation ? (address ?? 'موقع محدد') : 'تحديد الموقع على الخريطة'),
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: hasLocation ? const Color(0xFF1A1A1A) : const Color(0xFF6B6B6B),
                              ),
                              textAlign: TextAlign.right,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (hasLocation && !resolving)
                              Text(
                                'المنطقة المحددة للاستلام',
                                style: GoogleFonts.cairo(fontSize: 10, color: const Color(0xFF6B6B6B)),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _CurrentLocationButton(controller: controller),
      ],
    );
  }
}

class _CurrentLocationButton extends StatelessWidget {
  final PublishFormController controller;
  const _CurrentLocationButton({required this.controller});

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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'استخدام موقعي الحالي',
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.my_location_rounded, size: 18, color: Color(0xFF2E7D32)),
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
    final impact = EcoImpactCalculator.calculate(
      controller.selectedTypes.toList(),
      controller.weightCategory,
    );

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        children: [
          _SummaryRow(
            icon: Icons.recycling_outlined,
            label: 'نوع المواد',
            value: controller.selectedTypes.map((t) => t.label).join('، '),
            hasValue: controller.selectedTypes.isNotEmpty,
          ),
          _SummaryRow(
            icon: Icons.monitor_weight_outlined,
            label: 'الكمية',
            value: controller.weightCategory != null
                ? '${controller.weightCategory!.shortLabel} (${controller.weightCategory!.label})'
                : '—',
            hasValue: controller.weightCategory != null,
          ),
          _SummaryRow(
            icon: Icons.eco_rounded,
            label: 'توفير CO2',
            value: '${impact.co2SavedKg.toStringAsFixed(1)} كغ',
            hasValue: true,
            color: const Color(0xFF059669),
          ),
          _SummaryRow(
            icon: Icons.water_drop_rounded,
            label: 'توفير مياه',
            value: '${impact.waterSavedLiters.toStringAsFixed(0)} لتر',
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
            : const Border(bottom: BorderSide(color: Color(0xFFE0E0E0), width: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? const Color(0xFF6B6B6B)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF6B6B6B)),
          ),
          const Spacer(),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: hasValue ? (color ?? const Color(0xFF06402B)) : const Color(0xFFAAAAAA),
              ),
              textAlign: TextAlign.left,
              maxLines: 1,
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
              color: const Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.right,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF6B6B6B)),
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
          color: const Color(0xFF6B6B6B),
        ),
      ),
    );
  }
}
