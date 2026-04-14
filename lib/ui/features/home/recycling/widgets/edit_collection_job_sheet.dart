import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/order.dart';
import 'post_job_form.dart';

typedef EditJobCallback = void Function({
  required List<WasteType> wasteTypes,
  required PaymentModel paymentModel,
  required double price,
  required String collectionArea,
  required String jobDescription,
  double? minQuantityKg,
  String? editNote,
});

/// Pre-filled edit sheet — reuses [PostJobFormBody] with existing job values.
class EditCollectionJobSheet extends StatefulWidget {
  final Order job;
  final EditJobCallback onUpdate;

  const EditCollectionJobSheet({
    super.key,
    required this.job,
    required this.onUpdate,
  });

  @override
  State<EditCollectionJobSheet> createState() =>
      _EditCollectionJobSheetState();
}

class _EditCollectionJobSheetState extends State<EditCollectionJobSheet> {
  late final Set<WasteType> _selected;
  late PaymentModel _paymentModel;

  late final TextEditingController _priceCtrl;
  late final TextEditingController _minQtyCtrl;
  late final TextEditingController _areaCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _editNoteCtrl;

  @override
  void initState() {
    super.initState();
    final job = widget.job;
    _selected = Set.from(job.wasteTypes);
    _paymentModel = job.paymentModel ?? PaymentModel.perKg;
    final price = job.pricePerKg ?? job.itemPrice;
    _priceCtrl =
        TextEditingController(text: price != null ? '$price' : '');
    _minQtyCtrl = TextEditingController(
        text: job.minQuantityKg != null
            ? job.minQuantityKg!.toStringAsFixed(0)
            : '');
    _areaCtrl = TextEditingController(text: job.pickupAddress);
    _descCtrl =
        TextEditingController(text: job.jobDescription ?? '');
    _editNoteCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _minQtyCtrl.dispose();
    _areaCtrl.dispose();
    _descCtrl.dispose();
    _editNoteCtrl.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _selected.isNotEmpty &&
      _priceCtrl.text.trim().isNotEmpty &&
      double.tryParse(_priceCtrl.text.trim()) != null &&
      double.parse(_priceCtrl.text.trim()) > 0 &&
      _areaCtrl.text.trim().isNotEmpty &&
      _descCtrl.text.trim().isNotEmpty;

  void _submit() {
    if (!_isValid) return;
    widget.onUpdate(
      wasteTypes: _selected.toList(),
      paymentModel: _paymentModel,
      price: double.parse(_priceCtrl.text.trim()),
      collectionArea: _areaCtrl.text.trim(),
      jobDescription: _descCtrl.text.trim(),
      minQuantityKg: _paymentModel == PaymentModel.perKg &&
              _minQtyCtrl.text.trim().isNotEmpty
          ? double.tryParse(_minQtyCtrl.text.trim())
          : null,
      editNote: _editNoteCtrl.text.trim().isEmpty
          ? null
          : _editNoteCtrl.text.trim(),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                    borderRadius: BorderRadius.circular(9999)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'تعديل',
                    style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFC8860A)),
                  ),
                ),
                const Spacer(),
                Text(
                  'تعديل وظيفة التجميع',
                  style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF002819)),
                ),
              ],
            ),
            const SizedBox(height: 20),
            PostJobFormBody(
              selectedTypes: _selected,
              onToggleType: (t) => setState(() => _selected.contains(t)
                  ? _selected.remove(t)
                  : _selected.add(t)),
              paymentModel: _paymentModel,
              onPaymentModelChanged: (m) =>
                  setState(() => _paymentModel = m),
              priceCtrl: _priceCtrl,
              minQtyCtrl: _minQtyCtrl,
              areaCtrl: _areaCtrl,
              descriptionCtrl: _descCtrl,
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'سبب التعديل (اختياري)',
                style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF404943)),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _editNoteCtrl,
                maxLines: 2,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.cairo(
                    fontSize: 13, color: const Color(0xFF191C1B)),
                decoration: InputDecoration(
                  hintText: 'مثال: تم تغيير التسعيرة بسبب ارتفاع الطلب...',
                  hintStyle: GoogleFonts.cairo(
                      fontSize: 12,
                      color: const Color(0xFFC8860A).withValues(alpha: 0.6)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
            const SizedBox(height: 28),
            ListenableBuilder(
              listenable:
                  Listenable.merge([_priceCtrl, _areaCtrl, _descCtrl]),
              builder: (context, _) => SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isValid ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14401F),
                    disabledBackgroundColor:
                        const Color(0xFF14401F).withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text('حفظ التعديلات',
                      style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
