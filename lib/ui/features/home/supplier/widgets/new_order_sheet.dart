import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_tokens.dart';
import '../../../../../data/models/order.dart';
import '../../../../../l10n/l10n.dart';
import '../../../../common/map/location_picker_screen.dart';
import 'image_picker_grid.dart';
import '../../../../../data/services/market_ai_service.dart';
import '../../../../../data/services/location_service.dart';
import '../../shared/controllers/post_market_controller.dart';

part 'new_order_sheet/sections.dart';
part 'new_order_sheet/ai_logic.dart';
part 'new_order_sheet/location_logic.dart';

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
  // ── Form State ─────────────────────────────────────────────────────────────
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

  // ── AI & Location Services ────────────────────────────────────────────────
  late final PostMarketController _ai;
  final _locationService = LocationService();
  double? _aiPriceHint;
  bool _attempted = false;

  // ── Options ───────────────────────────────────────────────────────────────
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

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.preselected);
    _ai = PostMarketController();
    _ai.addListener(_onAiStateChanged);
    initLocation();
  }

  @override
  void dispose() {
    _ai.removeListener(_onAiStateChanged);
    _ai.dispose();
    _notesCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _onAiStateChanged() => setState(() {});

  void _updateState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  // ── Logic ──────────────────────────────────────────────────────────────────

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

  void _submit() {
    _updateState(() => _attempted = true);
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
    final price = double.tryParse(_priceCtrl.text.trim());
    widget.onSubmit(
      wasteTypes: _selected.toList(),
      pickupAddress: locationLabel,
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
          children: buildSections(context, dt),
        ),
      ),
    );
  }
}
