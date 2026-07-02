import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../../core/config/maps_config.dart';
import '../../../../../core/theme/app_tokens.dart';
import '../../../../../data/models/order/order_enums.dart';
import '../../../../../data/services/directions_service.dart';
import '../../../../../l10n/l10n.dart';
import '../../../../common/map/location_picker_screen.dart';
import 'image_picker_grid.dart';

class NewOrderSheet extends StatefulWidget {
  final Set<WasteType> preselected;
  final void Function({
    required List<WasteType> wasteTypes,
    required String pickupAddress,
    List<String> images,
    String? notes,
    double? estimatedWeightKg,
    WasteForm? wasteForm,
    WeightCategory? weightCategory,
    PickupTarget? pickupTarget,
    double? itemPrice,
    double? pickupLat,
    double? pickupLng,
  }) onSubmit;

  const NewOrderSheet({
    super.key,
    required this.preselected,
    required this.onSubmit,
  });

  @override
  State<NewOrderSheet> createState() => _NewOrderSheetState();
}

class _NewOrderSheetState extends State<NewOrderSheet> {
  late Set<WasteType> _selected;
  final _notesCtrl = TextEditingController();
  final List<String> _images = [];
  WasteForm? _wasteForm;
  WeightCategory? _weightCategory;
  PickupTarget _pickupTarget = PickupTarget.company;
  final _priceCtrl = TextEditingController();
  double? _pickedLat;
  double? _pickedLng;
  String? _pickedAddress;
  bool _isGeocoding = false;

  static const List<(WasteType, IconData)> _wasteCategories = [
    (WasteType.paper, Icons.newspaper_rounded),
    (WasteType.plastic, Icons.local_drink_rounded),
    (WasteType.metal, Icons.hardware_rounded),
    (WasteType.glass, Icons.wine_bar_rounded),
    (WasteType.electronics, Icons.devices_rounded),
    (WasteType.organic, Icons.eco_rounded),
    (WasteType.textile, Icons.checkroom_rounded),
    (WasteType.wood, Icons.park_rounded),
    (WasteType.rubber, Icons.circle_rounded),
    (WasteType.oil, Icons.water_drop_rounded),
    (WasteType.chemicals, Icons.science_rounded),
    (WasteType.batteries, Icons.battery_alert_rounded),
    (WasteType.furniture, Icons.chair_rounded),
    (WasteType.tires, Icons.tire_repair_rounded),
    (WasteType.construction, Icons.construction_rounded),
  ];

  static const List<(WasteForm, IconData)> _wasteFormOptions = [
    (WasteForm.solid, Icons.inventory_2_rounded),
    (WasteForm.liquid, Icons.water_drop_rounded),
    (WasteForm.mixed, Icons.blender_rounded),
  ];

  static const List<(WeightCategory, IconData)> _weightOptions = [
    (WeightCategory.light, Icons.spa_rounded),
    (WeightCategory.medium, Icons.fitness_center_rounded),
    (WeightCategory.heavy, Icons.luggage_rounded),
    (WeightCategory.veryHeavy, Icons.local_shipping_rounded),
  ];

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.preselected);
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  double get _deliveryFee {
    const baseFee = 2.0;
    final surcharge = switch (_weightCategory) {
      WeightCategory.light => 0.0,
      WeightCategory.medium => 1.5,
      WeightCategory.heavy => 4.0,
      WeightCategory.veryHeavy => 8.0,
      null => 0.0,
    };
    return baseFee + surcharge;
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<(double, double)?>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLat: _pickedLat,
          initialLng: _pickedLng,
        ),
      ),
    );
    if (result == null || !mounted) return;

    setState(() {
      _pickedLat = result.$1;
      _pickedLng = result.$2;
      _pickedAddress = null;
      _isGeocoding = MapsConfig.hasDirectionsKey;
    });

    if (MapsConfig.hasDirectionsKey) {
      final address = await DirectionsService.reverseGeocode(
        point: LatLng(result.$1, result.$2),
        apiKey: MapsConfig.directionsKey,
      );
      if (mounted) {
        setState(() {
          _pickedAddress = address;
          _isGeocoding = false;
        });
      }
    }
  }

  String get _locationLabel {
    if (_pickedAddress != null) return _pickedAddress!;
    if (_pickedLat != null && _pickedLng != null) {
      return '${_pickedLat!.toStringAsFixed(5)}, ${_pickedLng!.toStringAsFixed(5)}';
    }
    return context.l10n.newOrderCurrentAddress;
  }

  void _submit() {
    if (_selected.isEmpty) return;
    if (_pickedLat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى تحديد موقع الاستلام', style: GoogleFonts.cairo()),
          backgroundColor: const Color(0xFFB91C1C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    if (_isGeocoding) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('جارٍ تحديد العنوان، يرجى الانتظار...', style: GoogleFonts.cairo()),
          backgroundColor: const Color(0xFFC8860A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    final price = double.tryParse(_priceCtrl.text.trim());
    widget.onSubmit(
      wasteTypes: _selected.toList(),
      pickupAddress: _locationLabel,
      images: List.from(_images),
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      wasteForm: _wasteForm,
      weightCategory: _weightCategory,
      pickupTarget: _pickupTarget,
      itemPrice: price,
      pickupLat: _pickedLat,
      pickupLng: _pickedLng,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dt = context.dt;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: dt.border,
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: dt.surfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.close_rounded, size: 20, color: dt.onSurfaceMuted),
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      context.l10n.newOrderTitle,
                      style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: dt.onSurface),
                    ),
                    Text(
                      context.l10n.newOrderSubtitle,
                      style: GoogleFonts.cairo(fontSize: 12, color: dt.onSurfaceMuted),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── 1. Waste type selection ──
            _buildSectionLabel(context.l10n.newOrderWasteTypeLabel, dt),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: _wasteCategories.map((entry) {
                final (type, icon) = entry;
                final isSelected = _selected.contains(type);
                return GestureDetector(
                  onTap: () => setState(() {
                    isSelected ? _selected.remove(type) : _selected.add(type);
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF06402B) : dt.surfaceVariant,
                      borderRadius: BorderRadius.circular(30),
                      border: isSelected ? null : Border.all(color: dt.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          type.label,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : dt.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(icon, size: 15, color: isSelected ? Colors.white : dt.onSurfaceMuted),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── 2. Waste form ──
            _buildSectionLabel(context.l10n.newOrderWasteFormLabel, dt),
            const SizedBox(height: 10),
            Row(
              children: _wasteFormOptions.reversed.map((entry) {
                final (form, icon) = entry;
                final isSelected = _wasteForm == form;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _wasteForm = isSelected ? null : form;
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: EdgeInsets.only(left: form != WasteForm.mixed ? 8 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF06402B) : dt.surfaceVariant,
                        borderRadius: BorderRadius.circular(14),
                        border: isSelected ? null : Border.all(color: dt.border),
                      ),
                      child: Column(
                        children: [
                          Icon(icon, size: 22, color: isSelected ? Colors.white : dt.onSurfaceMuted),
                          const SizedBox(height: 6),
                          Text(
                            form.label,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : dt.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── 3. Weight category ──
            _buildSectionLabel(context.l10n.newOrderWeightCategoryLabel, dt),
            const SizedBox(height: 10),
            ...WeightCategory.values.map((cat) {
              final isSelected = _weightCategory == cat;
              final entry = _weightOptions.firstWhere((e) => e.$1 == cat);
              return GestureDetector(
                onTap: () => setState(() {
                  _weightCategory = isSelected ? null : cat;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF06402B) : dt.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF06402B) : dt.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20)
                      else
                        Icon(Icons.radio_button_off_rounded, color: dt.border, size: 20),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            cat.shortLabel,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : dt.onSurface,
                            ),
                          ),
                          Text(
                            cat.label,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: isSelected ? Colors.white70 : dt.onSurfaceMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white.withValues(alpha: 0.15) : dt.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(entry.$2, size: 18, color: isSelected ? Colors.white : dt.onSurfaceMuted),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),

            // ── 4. Pickup address ──
            _buildSectionLabel(context.l10n.newOrderPickupAddressLabel, dt),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickLocation,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _pickedLat != null
                      ? const Color(0xFF06402B).withValues(alpha: 0.06)
                      : dt.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _pickedLat != null
                        ? const Color(0xFF06402B).withValues(alpha: 0.4)
                        : dt.border,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF06402B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        context.l10n.newOrderSelectButton,
                        style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF06402B)),
                      ),
                    ),
                    const Spacer(),
                    if (_isGeocoding)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF06402B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'جارٍ تحديد العنوان...',
                            style: GoogleFonts.cairo(fontSize: 12, color: dt.onSurfaceMuted),
                          ),
                        ],
                      )
                    else
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _locationLabel,
                              textAlign: TextAlign.right,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _pickedLat != null
                                    ? const Color(0xFF06402B)
                                    : dt.onSurface,
                              ),
                            ),
                            Text(
                              context.l10n.newOrderTapToSelectLocation,
                              style: GoogleFonts.cairo(fontSize: 11, color: dt.onSurfaceMuted),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(width: 12),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFF06402B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _pickedLat != null
                            ? Icons.location_on_rounded
                            : Icons.add_location_alt_rounded,
                        size: 20,
                        color: const Color(0xFF06402B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── 5. Images ──
            _buildSectionLabel(context.l10n.newOrderImagesLabel, dt),
            const SizedBox(height: 8),
            ImagePickerGrid(
              imagePaths: _images,
              onAdd: (path) => setState(() => _images.add(path)),
              onRemove: (index) => setState(() => _images.removeAt(index)),
            ),
            const SizedBox(height: 24),

            // ── 6. Pickup target (company vs rider buy) ──
            _buildSectionLabel(context.l10n.newOrderPickupTargetLabel, dt),
            const SizedBox(height: 10),
            Row(
              children: PickupTarget.values.reversed.map((target) {
                final isSelected = _pickupTarget == target;
                final icon = target == PickupTarget.company
                    ? Icons.business_rounded
                    : Icons.delivery_dining_rounded;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _pickupTarget = target),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: EdgeInsets.only(
                        left: target == PickupTarget.riderBuy ? 8 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF06402B) : dt.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF06402B) : dt.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(icon, size: 28, color: isSelected ? Colors.white : dt.onSurfaceMuted),
                          const SizedBox(height: 8),
                          Text(
                            target.label,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : dt.onSurfaceVariant,
                            ),
                          ),
                          if (isSelected)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Icon(Icons.check_circle_rounded, color: Colors.white.withValues(alpha: 0.8), size: 18),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ── 7. Item price ──
            _buildSectionLabel(context.l10n.newOrderPriceLabel, dt),
            const SizedBox(height: 4),
            Text(
              _pickupTarget == PickupTarget.riderBuy
                  ? context.l10n.newOrderPriceHintDriver
                  : context.l10n.newOrderPriceHintCompany,
              style: GoogleFonts.cairo(fontSize: 11, color: dt.onSurfaceMuted),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: dt.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
                style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.bold, color: dt.onSurface),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: GoogleFonts.dmSans(fontSize: 16, color: dt.onSurfaceMuted.withValues(alpha: 0.6)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14),
                    child: Text(context.l10n.orderCurrencyJD, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: dt.onSurfaceMuted)),
                  ),
                  suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  prefixIcon: Icon(
                    _pickupTarget == PickupTarget.riderBuy ? Icons.sell_rounded : Icons.storefront_rounded,
                    color: dt.onSurfaceMuted,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── 8. Notes ──
            _buildSectionLabel(context.l10n.newOrderNotesLabel, dt),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: dt.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _notesCtrl,
                maxLines: 3,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(fontSize: 14, color: dt.onSurface),
                decoration: InputDecoration(
                  hintText: context.l10n.newOrderNotesHint,
                  hintStyle: GoogleFonts.cairo(fontSize: 13, color: dt.onSurfaceMuted.withValues(alpha: 0.7)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Delivery fee (auto-calculated) ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  Text(
                    '${_deliveryFee.toStringAsFixed(1)} ${context.l10n.orderCurrencyJD}',
                    style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFFC8860A)),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        context.l10n.newOrderDeliveryFeeLabel,
                        style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF92400E)),
                      ),
                      Text(
                        context.l10n.newOrderDeliveryFeeSubtitle,
                        style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFFB45309)),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.local_shipping_rounded, color: Color(0xFFC8860A), size: 22),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Submit ──
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _selected.isNotEmpty ? _submit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06402B),
                  disabledBackgroundColor: const Color(0xFF06402B).withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.l10n.newOrderSubmitButton,
                      style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text, AppTokens dt) {
    return Text(
      text,
      style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: dt.onSurfaceVariant),
    );
  }
}
