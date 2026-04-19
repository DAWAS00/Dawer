import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/order.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/waste_type_icons.dart';
import '../../../../common/map/location_picker_map.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NewPickupRequestView — full-screen pickup order form
// ─────────────────────────────────────────────────────────────────────────────

class NewPickupRequestView extends StatefulWidget {
  final void Function({
    required List<WasteType> wasteTypes,
    required String pickupAddress,
    List<String>? images,
    String? notes,
    WasteForm? wasteForm,
    WeightCategory? weightCategory,
    PickupTarget? pickupTarget,
    double? itemPrice,
  }) onSubmit;

  const NewPickupRequestView({super.key, required this.onSubmit});

  @override
  State<NewPickupRequestView> createState() => _NewPickupRequestViewState();
}

class _NewPickupRequestViewState extends State<NewPickupRequestView> {
  final Set<WasteType> _selectedTypes = {};
  WasteForm? _wasteForm;
  WeightCategory? _weightCategory;
  PickupTarget _pickupTarget = PickupTarget.company;
  double? _pickedLat;
  double? _pickedLng;
  final _priceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _showTypeError = false;

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
  void dispose() {
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double get _deliveryFee {
    const baseFee = 2.0;
    return baseFee +
        switch (_weightCategory) {
          WeightCategory.light => 0.0,
          WeightCategory.medium => 1.5,
          WeightCategory.heavy => 4.0,
          WeightCategory.veryHeavy => 8.0,
          null => 0.0,
        };
  }

  String get _pickupAddressLabel {
    if (_pickedLat != null && _pickedLng != null) {
      return 'خط العرض: ${_pickedLat!.toStringAsFixed(4)} | خط الطول: ${_pickedLng!.toStringAsFixed(4)}';
    }
    return 'الموقع المحدد';
  }

  void _submit() {
    if (_selectedTypes.isEmpty) {
      setState(() => _showTypeError = true);
      return;
    }
    widget.onSubmit(
      wasteTypes: _selectedTypes.toList(),
      pickupAddress: _pickupAddressLabel,
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      wasteForm: _wasteForm,
      weightCategory: _weightCategory,
      pickupTarget: _pickupTarget,
      itemPrice: double.tryParse(_priceCtrl.text.trim()),
    );
    Navigator.pop(context);
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<(double, double)?>(
      context,
      MaterialPageRoute(
        builder: (_) => _LocationPickerScreen(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSection1WasteTypes(),
            _buildSection2WasteForm(),
            _buildSection3WeightCategory(),
            _buildSection4Location(),
            _buildSection5PickupTarget(),
            _buildSection6Price(),
            _buildSection7Notes(),
            _buildDeliveryFeeCard(),
          ],
        ),
      ),
      bottomNavigationBar: _buildSubmitBar(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Text(
        'طلب استلام جديد',
        style: GoogleFonts.cairo(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: const Color(0xFF002819),
        ),
      ),
      centerTitle: false,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF2F4F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward_rounded,
              size: 20,
              color: Color(0xFF717973),
            ),
          ),
        ),
      ),
    );
  }

  // ── Section 1: Waste types ─────────────────────────────────────────────────

  Widget _buildSection1WasteTypes() {
    return _SectionCard(
      title: 'نوع المخلفات *',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_selectedTypes.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'اختر نوعاً أو أكثر',
                style: GoogleFonts.cairo(
                    fontSize: 12, color: const Color(0xFF9CA3AF)),
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            children: WasteTypeIcons.all.map((entry) {
              final (type, icon) = entry;
              final isSelected = _selectedTypes.contains(type);
              return GestureDetector(
                onTap: () => setState(() {
                  if (isSelected) {
                    _selectedTypes.remove(type);
                  } else {
                    _selectedTypes.add(type);
                    if (_showTypeError) _showTypeError = false;
                  }
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF06402B)
                        : const Color(0xFFF2F4F2),
                    borderRadius: BorderRadius.circular(30),
                    border: isSelected
                        ? null
                        : Border.all(color: const Color(0xFFE6E9E7)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        type.label,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF404943),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(icon,
                          size: 15,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF717973)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (_showTypeError)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'يرجى اختيار نوع المخلفات',
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  // ── Section 2: Waste form ──────────────────────────────────────────────────

  Widget _buildSection2WasteForm() {
    return _SectionCard(
      title: 'حالة المخلفات',
      child: Row(
        children: _wasteFormOptions.reversed.map((entry) {
          final (form, icon) = entry;
          final isSelected = _wasteForm == form;
          return Expanded(
            child: GestureDetector(
              onTap: () =>
                  setState(() => _wasteForm = isSelected ? null : form),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin:
                    EdgeInsets.only(left: form != WasteForm.mixed ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF06402B)
                      : const Color(0xFFF2F4F2),
                  borderRadius: BorderRadius.circular(14),
                  border: isSelected
                      ? null
                      : Border.all(color: const Color(0xFFE6E9E7)),
                ),
                child: Column(
                  children: [
                    Icon(icon,
                        size: 22,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF717973)),
                    const SizedBox(height: 6),
                    Text(
                      form.label,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF404943),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Section 3: Weight category ─────────────────────────────────────────────

  Widget _buildSection3WeightCategory() {
    return _SectionCard(
      title: 'الكمية التقديرية',
      child: Column(
        children: _weightOptions.map((entry) {
          final (cat, icon) = entry;
          final isSelected = _weightCategory == cat;
          return GestureDetector(
            onTap: () => setState(
                () => _weightCategory = isSelected ? null : cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color:
                    isSelected ? const Color(0xFF06402B) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF06402B)
                      : const Color(0xFFE6E9E7),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded,
                        color: Colors.white, size: 20)
                  else
                    const Icon(Icons.radio_button_off_rounded,
                        color: Color(0xFFBBBFBD), size: 20),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        cat.shortLabel,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF002819),
                        ),
                      ),
                      Text(
                        cat.label,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: isSelected
                              ? Colors.white70
                              : const Color(0xFF717973),
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
                          : const Color(0xFFF2F4F2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon,
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF717973)),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Section 4: Location ────────────────────────────────────────────────────

  Widget _buildSection4Location() {
    final hasLocation = _pickedLat != null && _pickedLng != null;
    return _SectionCard(
      title: 'موقع الاستلام *',
      child: GestureDetector(
        onTap: _pickLocation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE6E9E7)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: hasLocation
                      ? const Color(0xFF06402B).withValues(alpha: 0.1)
                      : const Color(0xFFE6E9E7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  hasLocation
                      ? Icons.check_circle_rounded
                      : Icons.location_on_rounded,
                  size: 20,
                  color: hasLocation
                      ? const Color(0xFF06402B)
                      : const Color(0xFF717973),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      hasLocation
                          ? _pickupAddressLabel
                          : 'تحديد الموقع على الخريطة',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.cairo(
                        fontSize: hasLocation ? 11 : 14,
                        fontWeight: hasLocation
                            ? FontWeight.normal
                            : FontWeight.bold,
                        color: hasLocation
                            ? const Color(0xFF404943)
                            : const Color(0xFF002819),
                      ),
                    ),
                    if (!hasLocation)
                      Text(
                        'اضغط لفتح الخريطة',
                        textAlign: TextAlign.right,
                        style: GoogleFonts.cairo(
                            fontSize: 11,
                            color: const Color(0xFF717973)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section 5: Pickup target ───────────────────────────────────────────────

  Widget _buildSection5PickupTarget() {
    return _SectionCard(
      title: 'وجهة المخلفات *',
      child: Row(
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
                    left: target == PickupTarget.riderBuy ? 8 : 0),
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF06402B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF06402B)
                        : const Color(0xFFE6E9E7),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(icon,
                        size: 28,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF717973)),
                    const SizedBox(height: 8),
                    Text(
                      target.label,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF404943),
                      ),
                    ),
                    if (isSelected)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Icon(Icons.check_circle_rounded,
                            color: Colors.white.withValues(alpha: 0.8),
                            size: 18),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Section 6: Price ───────────────────────────────────────────────────────

  Widget _buildSection6Price() {
    return _SectionCard(
      title: 'سعر المواد',
      subtitle: _pickupTarget == PickupTarget.riderBuy
          ? 'السعر الذي تريده مقابل بيع المواد للسائق'
          : 'السعر الذي تريده مقابل بيع المواد للشركة',
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: _priceCtrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          style: GoogleFonts.dmSans(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF191C1B)),
          decoration: InputDecoration(
            hintText: '0.00',
            hintStyle: GoogleFonts.dmSans(
                fontSize: 16,
                color: const Color(0xFF6B7280).withValues(alpha: 0.4)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 14),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(left: 14),
              child: Text('د.أ',
                  style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF717973))),
            ),
            suffixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            prefixIcon: Icon(
              _pickupTarget == PickupTarget.riderBuy
                  ? Icons.sell_rounded
                  : Icons.storefront_rounded,
              color: const Color(0xFF717973),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  // ── Section 7: Notes ───────────────────────────────────────────────────────

  Widget _buildSection7Notes() {
    return _SectionCard(
      title: 'ملاحظات',
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: TextField(
          controller: _notesCtrl,
          maxLines: 3,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(
              fontSize: 14, color: const Color(0xFF191C1B)),
          decoration: InputDecoration(
            hintText: 'مثال: الكميّة تقريباً ٢٠ كيس بلاستيك...',
            hintStyle: GoogleFonts.cairo(
                fontSize: 13,
                color: const Color(0xFF6B7280).withValues(alpha: 0.5)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ),
    );
  }

  // ── Delivery fee card ──────────────────────────────────────────────────────

  Widget _buildDeliveryFeeCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.amberContainer,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        children: [
          Text(
            '${_deliveryFee.toStringAsFixed(1)} د.أ',
            style: GoogleFonts.dmSans(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.accentAmber),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('رسوم التوصيل',
                  style: GoogleFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF92400E))),
              Text('تُحسب تلقائياً حسب المسافة والحجم',
                  style: GoogleFonts.cairo(
                      fontSize: 11, color: const Color(0xFFB45309))),
            ],
          ),
          const SizedBox(width: 12),
          const Icon(Icons.local_shipping_rounded,
              color: AppColors.accentAmber, size: 22),
        ],
      ),
    );
  }

  // ── Submit bar ─────────────────────────────────────────────────────────────

  Widget _buildSubmitBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _selectedTypes.isEmpty ? 0.4 : 1.0,
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06402B),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'إرسال الطلب',
                    style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SectionCard — white card wrapper for each form section
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final String? subtitle;

  const _SectionCard(
      {required this.title, required this.child, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002819)),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!,
                style: GoogleFonts.cairo(
                    fontSize: 11, color: const Color(0xFF9CA3AF))),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _LocationPickerScreen — full-screen location selection page
// ─────────────────────────────────────────────────────────────────────────────

class _LocationPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const _LocationPickerScreen({this.initialLat, this.initialLng});

  @override
  State<_LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState
    extends State<_LocationPickerScreen> {
  double _lat = 31.9454;
  double _lng = 35.9284;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null) _lat = widget.initialLat!;
    if (widget.initialLng != null) _lng = widget.initialLng!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'تحديد الموقع',
          style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: const Color(0xFF002819)),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF2F4F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  size: 20, color: Color(0xFF717973)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, (_lat, _lng)),
            child: Text(
              'تأكيد الموقع',
              style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: const Color(0xFF06402B)),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (_, constraints) => LocationPickerMap(
          initialLat: widget.initialLat,
          initialLng: widget.initialLng,
          height: constraints.maxHeight,
          onLocationChanged: (lat, lng) {
            _lat = lat;
            _lng = lng;
          },
        ),
      ),
    );
  }
}
