import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/order.dart';
import '../../supplier/widgets/image_picker_grid.dart';

class PostToMarketSheet extends StatefulWidget {
  final void Function({
    required List<WasteType> wasteTypes,
    required String pickupAddress,
    List<String> images,
    String? notes,
    WasteForm? wasteForm,
    WeightCategory? weightCategory,
    double? itemPrice,
  }) onSubmit;

  const PostToMarketSheet({super.key, required this.onSubmit});

  @override
  State<PostToMarketSheet> createState() => _PostToMarketSheetState();
}

class _PostToMarketSheetState extends State<PostToMarketSheet> {
  final Set<WasteType> _selected = {};
  WasteForm? _wasteForm;
  WeightCategory? _weightCategory;
  final _priceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final List<String> _images = [];

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
  void dispose() {
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selected.isEmpty) return;
    widget.onSubmit(
      wasteTypes: _selected.toList(),
      pickupAddress: 'عنواني الحالي',
      images: List.from(_images),
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
      wasteForm: _wasteForm,
      weightCategory: _weightCategory,
      itemPrice: double.tryParse(_priceCtrl.text.trim()),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
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
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Header ──
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF717973)),
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'نشر في السوق',
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF002819),
                        ),
                      ),
                      Text(
                        'أضف تفاصيل المواد التي تريد بيعها',
                        style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFF717973)),
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
              ),
              const SizedBox(height: 24),

              // ── 1. Waste type ──
              _buildSectionLabel('نوع المواد *'),
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
                        color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFFF2F4F2),
                        borderRadius: BorderRadius.circular(30),
                        border: isSelected ? null : Border.all(color: const Color(0xFFE6E9E7)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            type.label,
                            style: GoogleFonts.cairo(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : const Color(0xFF404943),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(icon, size: 15, color: isSelected ? Colors.white : const Color(0xFF717973)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // ── 2. Waste form ──
              _buildSectionLabel('حالة المواد'),
              const SizedBox(height: 10),
              Row(
                children: _wasteFormOptions.reversed.map((entry) {
                  final (form, icon) = entry;
                  final isSelected = _wasteForm == form;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _wasteForm = isSelected ? null : form),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: EdgeInsets.only(left: form != WasteForm.mixed ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFFF2F4F2),
                          borderRadius: BorderRadius.circular(14),
                          border: isSelected ? null : Border.all(color: const Color(0xFFE6E9E7)),
                        ),
                        child: Column(
                          children: [
                            Icon(icon, size: 22, color: isSelected ? Colors.white : const Color(0xFF717973)),
                            const SizedBox(height: 6),
                            Text(
                              form.label,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : const Color(0xFF404943),
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
              _buildSectionLabel('حجم الكمية *'),
              const SizedBox(height: 10),
              ...WeightCategory.values.map((cat) {
                final isSelected = _weightCategory == cat;
                final entry = _weightOptions.firstWhere((e) => e.$1 == cat);
                return GestureDetector(
                  onTap: () => setState(() => _weightCategory = isSelected ? null : cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1E40AF) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF1E40AF) : const Color(0xFFE6E9E7),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        isSelected
                            ? const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20)
                            : const Icon(Icons.radio_button_off_rounded, color: Color(0xFFBBBFBD), size: 20),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              cat.shortLabel,
                              style: GoogleFonts.cairo(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.white : const Color(0xFF002819),
                              ),
                            ),
                            Text(
                              cat.label,
                              style: GoogleFonts.cairo(
                                fontSize: 11,
                                color: isSelected ? Colors.white70 : const Color(0xFF717973),
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
                          child: Icon(entry.$2, size: 18,
                              color: isSelected ? Colors.white : const Color(0xFF717973)),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 24),

              // ── 4. Price ──
              _buildSectionLabel('السعر المطلوب (د.أ) — اختياري'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F2),
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
                    color: const Color(0xFF191C1B),
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: GoogleFonts.dmSans(
                      fontSize: 16,
                      color: const Color(0xFF6B7280).withValues(alpha: 0.4),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Text(
                        'د.أ',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF717973),
                        ),
                      ),
                    ),
                    suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                    prefixIcon: const Icon(Icons.sell_rounded, color: Color(0xFF717973), size: 20),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── 5. Images ──
              _buildSectionLabel('صور المواد — اختياري'),
              const SizedBox(height: 8),
              ImagePickerGrid(
                imagePaths: _images,
                onAdd: (path) => setState(() => _images.add(path)),
                onRemove: (index) => setState(() => _images.removeAt(index)),
              ),
              const SizedBox(height: 24),

              // ── 6. Location ──
              _buildSectionLabel('عنوان الاستلام'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('سيتم ربط خرائط جوجل قريباً', style: GoogleFonts.cairo()),
                    backgroundColor: const Color(0xFF1E40AF),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E40AF).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'تحديد',
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
                            'عنواني الحالي',
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF002819),
                            ),
                          ),
                          Text(
                            'اضغط لتحديد الموقع على الخريطة',
                            style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF717973)),
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
                        child: const Icon(Icons.location_on_rounded, size: 20, color: Color(0xFF1E40AF)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── 7. Notes ──
              _buildSectionLabel('ملاحظات — اختياري'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: TextField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF191C1B)),
                  decoration: InputDecoration(
                    hintText: 'مثال: الكميّة تقريباً ٢٠ كيس بلاستيك...',
                    hintStyle: GoogleFonts.cairo(
                      fontSize: 13,
                      color: const Color(0xFF6B7280).withValues(alpha: 0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(14),
                  ),
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
                    backgroundColor: const Color(0xFF1E40AF),
                    disabledBackgroundColor: const Color(0xFF1E40AF).withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'نشر الإعلان',
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF404943),
      ),
    );
  }
}
