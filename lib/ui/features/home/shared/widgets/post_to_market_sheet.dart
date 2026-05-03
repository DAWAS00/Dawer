import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/waste_type_icons.dart';
import '../../../../../core/theme/app_tokens.dart';
import '../../../../../data/models/order.dart';
import '../../../../../l10n/l10n.dart';
import '../../../../common/map/location_picker_screen.dart';
import '../../supplier/widgets/image_picker_grid.dart';
import '../../../../../data/services/market_ai_service.dart';
import '../../../../../data/services/location_service.dart';
import '../controllers/post_market_controller.dart';

class PostToMarketSheet extends StatefulWidget {
  final void Function({
    required List<WasteType> wasteTypes,
    required String pickupAddress,
    List<String> images,
    String? notes,
    WasteForm? wasteForm,
    WeightCategory? weightCategory,
    double? itemPrice,
    double? pickupLat,
    double? pickupLng,
  }) onSubmit;

  const PostToMarketSheet({super.key, required this.onSubmit});

  @override
  State<PostToMarketSheet> createState() => _PostToMarketSheetState();
}

class _PostToMarketSheetState extends State<PostToMarketSheet> {
  // ── Form state ─────────────────────────────────────────────────────────────
  final Set<WasteType> _selected = {};
  WasteForm? _wasteForm;
  WeightCategory? _weightCategory;
  final _priceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final List<String> _images = [];
  double? _pickedLat;
  double? _pickedLng;

  // ── AI controller ──────────────────────────────────────────────────────────
  late final PostMarketController _ai;
  final _locationService = LocationService();

  // ── Static option lists ────────────────────────────────────────────────────

  static const List<(WasteForm, IconData)> _wasteFormOptions = [
    (WasteForm.solid, Icons.inventory_2_rounded),
    (WasteForm.liquid, Icons.water_drop_rounded),
    (WasteForm.gas, Icons.air_rounded),
    (WasteForm.mixed, Icons.layers_rounded),
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
    _ai = PostMarketController();
    _ai.addListener(_onAiStateChanged);
    _initLocation();
  }

  @override
  void dispose() {
    _ai.removeListener(_onAiStateChanged);
    _ai.dispose();
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onAiStateChanged() => setState(() {});

  // ── Location ───────────────────────────────────────────────────────────────

  Future<void> _initLocation() async {
    final loc = await _locationService.getCurrentLocation();
    if (!mounted) return;
    if (loc != null) {
      setState(() {
        _pickedLat = loc.lat;
        _pickedLng = loc.lng;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.postMarketLocationPermissionDenied)),
      );
      setState(() {
        _pickedLat = 31.9454;
        _pickedLng = 35.9284;
      });
    }
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
    if (result != null && mounted) {
      setState(() {
        _pickedLat = result.$1;
        _pickedLng = result.$2;
      });
    }
  }

  String get _locationLabel {
    if (_pickedLat != null && _pickedLng != null) {
      return 'خط العرض: ${_pickedLat!.toStringAsFixed(4)} | خط الطول: ${_pickedLng!.toStringAsFixed(4)}';
    }
    return context.l10n.newOrderCurrentAddress;
  }

  // ── AI orchestration ───────────────────────────────────────────────────────

  Future<void> _runAiAnalysis(String imagePath) async {
    try {
      final result = await _ai.analyze(File(imagePath), Localizations.localeOf(context));
      if (!mounted || result == null) return;
      _applyAiResult(result);
    } catch (e, st) {
      debugPrint('[PostToMarket] AI analysis failed: $e');
      debugPrintStack(stackTrace: st);
      if (!mounted) return;
      final raw = e.toString();
      final short = raw.length > 140 ? '${raw.substring(0, 140)}…' : raw;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          content: Text(
            '${context.l10n.postMarketAiFailed}\n$short',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _applyAiResult(MarketAiResult result) {
    final filled = <String>[];

    setState(() {
      if (result.wasteTypes.isNotEmpty) {
        _selected
          ..clear()
          ..addAll(result.wasteTypes);
        filled.add(context.l10n.postMarketWasteTypeLabel);
      }
      if (result.wasteForm != null) {
        _wasteForm = result.wasteForm;
        filled.add(context.l10n.postMarketWasteFormLabel);
      }
      if (result.weightCategory != null) {
        _weightCategory = result.weightCategory;
        filled.add(context.l10n.newOrderWeightCategoryLabel);
      }
      if (result.approxPriceJd != null) {
        _priceCtrl.text = result.approxPriceJd!.toStringAsFixed(2);
        filled.add(context.l10n.postMarketPriceLabel);
      }
      if (result.note != null && result.note!.isNotEmpty) {
        _notesCtrl.text = result.note!;
        filled.add(context.l10n.newOrderNotesLabel);
      }
    });

    _ai.reportFilledFields(filled);

    if (mounted) {
      final msg = _ai.hasLowConfidence
          ? '${context.l10n.postMarketAiFilled} — تحقق من الحقول'
          : context.l10n.postMarketAiFilled;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

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
    widget.onSubmit(
      wasteTypes: _selected.toList(),
      pickupAddress: _locationLabel,
      images: List.from(_images),
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      wasteForm: _wasteForm,
      weightCategory: _weightCategory,
      itemPrice: double.tryParse(_priceCtrl.text.trim()),
      pickupLat: _pickedLat,
      pickupLng: _pickedLng,
    );
    Navigator.pop(context);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dt = context.dt;
    return Container(
      decoration: BoxDecoration(
        color: dt.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildDragHandle(dt),
              const SizedBox(height: 16),
              _buildHeader(context, dt),
              const SizedBox(height: 24),

              // ── 0. Images ──
              _buildImagesSection(context, dt),
              const SizedBox(height: 16),

              // ── AI status banners ──
              if (_ai.isAnalyzing) _buildAnalyzingBanner(context),
              if (!_ai.isAnalyzing && _ai.filledFieldLabels.isNotEmpty) ...[
                _buildFilledSummary(context),
                if (_ai.hasLowConfidence) _buildLowConfidenceWarning(context),
              ],
              const SizedBox(height: 8),

              // ── 1. Waste type chips ──
              _buildSectionLabel(context.l10n.postMarketWasteTypeLabel, dt),
              const SizedBox(height: 10),
              _buildWasteTypeChips(dt),
              const SizedBox(height: 24),

              // ── 2. Material state ──
              _buildSectionLabel(context.l10n.postMarketWasteFormLabel, dt),
              const SizedBox(height: 10),
              _buildWasteFormToggle(dt),
              const SizedBox(height: 24),

              // ── 3. Weight category ──
              _buildSectionLabel(context.l10n.newOrderWeightCategoryLabel, dt),
              const SizedBox(height: 10),
              _buildWeightCategoryList(dt),

              // ── Estimated weight badge (AI-only display) ──
              if (_ai.estimatedWeightKg != null) ...[
                const SizedBox(height: 8),
                _buildWeightBadge(),
              ],
              const SizedBox(height: 24),

              // ── 4. Price ──
              _buildSectionLabel(context.l10n.postMarketPriceLabel, dt),
              const SizedBox(height: 8),
              _buildPriceField(context, dt),
              const SizedBox(height: 24),

              // ── 5. Location ──
              _buildSectionLabel(context.l10n.newOrderPickupAddressLabel, dt),
              const SizedBox(height: 8),
              _buildLocationPicker(context, dt),
              const SizedBox(height: 24),

              // ── 6. Notes ──
              _buildSectionLabel(context.l10n.newOrderNotesLabel, dt),
              const SizedBox(height: 8),
              _buildNotesField(context, dt),
              const SizedBox(height: 28),

              // ── Submit ──
              _buildSubmitButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section builders ───────────────────────────────────────────────────────

  Widget _buildDragHandle(AppTokens dt) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: dt.border,
          borderRadius: BorderRadius.circular(9999),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppTokens dt) {
    return Row(
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
              context.l10n.postMarketTitle,
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: dt.onSurface,
              ),
            ),
            Text(
              context.l10n.postMarketSubtitle,
              style: GoogleFonts.cairo(fontSize: 12, color: dt.onSurfaceMuted),
            ),
          ],
        ),
        const SizedBox(width: 4),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF1E40AF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.storefront_rounded, size: 20, color: Color(0xFF1E40AF)),
        ),
      ],
    );
  }

  Widget _buildImagesSection(BuildContext context, AppTokens dt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            if (_images.isNotEmpty)
              GestureDetector(
                onTap: () => _runAiAnalysis(_images.first),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E40AF).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 14, color: Color(0xFF1E40AF)),
                      const SizedBox(width: 4),
                      Text(
                        'إعادة التحليل',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E40AF),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const Spacer(),
            _buildSectionLabel(context.l10n.postMarketImagesLabel, dt),
          ],
        ),
        const SizedBox(height: 8),
        ImagePickerGrid(
          imagePaths: _images,
          onAdd: (path) {
            setState(() => _images.add(path));
            if (_images.length == 1) _runAiAnalysis(path);
          },
          onRemove: (index) {
            setState(() => _images.removeAt(index));
            if (_images.isEmpty) _ai.clearAnalysis();
          },
        ),
      ],
    );
  }

  Widget _buildWasteTypeChips(AppTokens dt) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: WasteTypeIcons.all.map((entry) {
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
              color: isSelected ? const Color(0xFF1E40AF) : dt.surfaceVariant,
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
    );
  }

  Widget _buildWasteFormToggle(AppTokens dt) {
    return Row(
      children: _wasteFormOptions.reversed.map((entry) {
        final (form, icon) = entry;
        final isSelected = _wasteForm == form;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _wasteForm = isSelected ? null : form),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(left: form != _wasteFormOptions.last.$1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E40AF) : dt.surfaceVariant,
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
    );
  }

  Widget _buildWeightCategoryList(AppTokens dt) {
    return Column(
      children: WeightCategory.values.map((cat) {
        final isSelected = _weightCategory == cat;
        final entry = _weightOptions.firstWhere((e) => e.$1 == cat);
        return GestureDetector(
          onTap: () => setState(() => _weightCategory = isSelected ? null : cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF1E40AF) : dt.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? const Color(0xFF1E40AF) : dt.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                isSelected
                    ? const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20)
                    : Icon(Icons.radio_button_off_rounded, color: dt.border, size: 20),
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
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.15)
                        : dt.surfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    entry.$2,
                    size: 18,
                    color: isSelected ? Colors.white : dt.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildWeightBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E40AF).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E40AF).withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.scale_rounded, size: 16, color: Color(0xFF1E40AF)),
          const SizedBox(width: 8),
          Text(
            '${_ai.estimatedWeightKg!.toStringAsFixed(1)} كغ',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E40AF),
            ),
          ),
          const Spacer(),
          Text(
            'الوزن التقديري (الذكاء الاصطناعي)',
            style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF1E40AF)),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceField(BuildContext context, AppTokens dt) {
    return Container(
      decoration: BoxDecoration(
        color: dt.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: _priceCtrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.left,
        style: GoogleFonts.dmSans(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: dt.onSurface,
        ),
        decoration: InputDecoration(
          hintText: '0.00',
          hintStyle: GoogleFonts.dmSans(
            fontSize: 16,
            color: dt.onSurfaceMuted.withValues(alpha: 0.4),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text(
              context.l10n.orderCurrencyJD,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: dt.onSurfaceMuted,
              ),
            ),
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          prefixIcon: Icon(Icons.sell_rounded, color: dt.onSurfaceMuted, size: 20),
        ),
      ),
    );
  }

  Widget _buildLocationPicker(BuildContext context, AppTokens dt) {
    return GestureDetector(
      onTap: _pickLocation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _pickedLat != null
              ? const Color(0xFF1E40AF).withValues(alpha: 0.06)
              : dt.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _pickedLat != null
                ? const Color(0xFF1E40AF).withValues(alpha: 0.4)
                : dt.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E40AF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                context.l10n.newOrderSelectButton,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E40AF),
                ),
              ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _pickedLat != null
                      ? '${_pickedLat!.toStringAsFixed(4)}, ${_pickedLng!.toStringAsFixed(4)}'
                      : context.l10n.newOrderCurrentAddress,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _pickedLat != null ? const Color(0xFF1E40AF) : dt.onSurface,
                  ),
                ),
                Text(
                  context.l10n.newOrderTapToSelectLocation,
                  style: GoogleFonts.cairo(fontSize: 11, color: dt.onSurfaceMuted),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF1E40AF).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _pickedLat != null
                    ? Icons.location_on_rounded
                    : Icons.add_location_alt_rounded,
                size: 20,
                color: const Color(0xFF1E40AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField(BuildContext context, AppTokens dt) {
    return Container(
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
          hintStyle: GoogleFonts.cairo(
            fontSize: 13,
            color: dt.onSurfaceMuted.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _selected.isNotEmpty ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E40AF),
          disabledBackgroundColor: const Color(0xFF1E40AF).withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.l10n.postMarketSubmitButton,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.storefront_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  // ── AI UI banners ──────────────────────────────────────────────────────────

  Widget _buildAnalyzingBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E40AF).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF1E40AF).withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1E40AF)),
            ),
            const SizedBox(width: 12),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  context.l10n.postMarketAiAnalyzing,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E40AF),
                  ),
                ),
                Text(
                  'يقوم الذكاء الاصطناعي بملء الحقول...',
                  style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF1E40AF)),
                ),
              ],
            ),
            const SizedBox(width: 10),
            const Icon(Icons.auto_awesome_rounded, size: 20, color: Color(0xFF1E40AF)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilledSummary(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF065F46).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF065F46).withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                alignment: WrapAlignment.end,
                children: _ai.filledFieldLabels.map((field) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF065F46).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    field,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: const Color(0xFF065F46),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.check_circle_rounded, size: 18, color: Color(0xFF065F46)),
          ],
        ),
      ),
    );
  }

  Widget _buildLowConfidenceWarning(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'الصورة غير واضحة — تحقق من الحقول قبل النشر',
                textAlign: TextAlign.end,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: const Color(0xFF92400E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFF59E0B)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text, AppTokens dt) {
    return Text(
      text,
      style: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: dt.onSurfaceVariant,
      ),
    );
  }
}
