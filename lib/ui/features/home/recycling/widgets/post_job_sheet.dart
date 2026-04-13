import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/order.dart';

class PostJobSheet extends StatefulWidget {
  const PostJobSheet({super.key});

  @override
  State<PostJobSheet> createState() => _PostJobSheetState();
}

class _PostJobSheetState extends State<PostJobSheet> {
  final _areaCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final Set<WasteType> _selected = {};

  final List<(WasteType, IconData)> _categories = const [
    (WasteType.paper, Icons.newspaper_rounded),
    (WasteType.plastic, Icons.local_drink_rounded),
    (WasteType.metal, Icons.hardware_rounded),
    (WasteType.glass, Icons.wine_bar_rounded),
    (WasteType.electronics, Icons.devices_rounded),
    (WasteType.organic, Icons.eco_rounded),
  ];

  @override
  void dispose() {
    _areaCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'نشر وظيفة تجميع جديدة',
              style: GoogleFonts.cairo(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF002819),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'أنواع المخلفات المطلوبة *',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF404943),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.end,
              children: _categories.map((entry) {
                final (type, icon) = entry;
                final isSel = _selected.contains(type);
                return GestureDetector(
                  onTap: () => setState(
                      () => isSel ? _selected.remove(type) : _selected.add(type)),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFF14401F) : const Color(0xFFF2F4F2),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          type.label,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSel ? Colors.white : const Color(0xFF404943),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(icon,
                            size: 15,
                            color: isSel ? Colors.white : const Color(0xFF717973)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              'منطقة الجمع *',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF404943),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE6E9E7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _areaCtrl,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF191C1B)),
                decoration: InputDecoration(
                  hintText: 'مثال: الرابية، عمّان',
                  hintStyle: GoogleFonts.cairo(
                    fontSize: 13,
                    color: const Color(0xFF6B7280).withValues(alpha: 0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ملاحظات (اختياري)',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF404943),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE6E9E7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _notesCtrl,
                maxLines: 3,
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(fontSize: 14, color: const Color(0xFF191C1B)),
                decoration: InputDecoration(
                  hintText: 'كميّة تقريبية، وقت التسليم...',
                  hintStyle: GoogleFonts.cairo(
                    fontSize: 13,
                    color: const Color(0xFF6B7280).withValues(alpha: 0.5),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: (_selected.isNotEmpty && _areaCtrl.text.isNotEmpty)
                    ? () => Navigator.pop(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14401F),
                  disabledBackgroundColor: const Color(0xFF14401F).withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'نشر الوظيفة',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
