import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/order.dart';
import 'post_job_form.dart';

typedef PostJobSubmitCallback = void Function({
  required List<WasteType> wasteTypes,
  required PaymentModel paymentModel,
  required double price,
  required String collectionArea,
  required String jobDescription,
  double? minQuantityKg,
});

class PostJobSheet extends StatefulWidget {
  final PostJobSubmitCallback onSubmit;

  const PostJobSheet({super.key, required this.onSubmit});

  @override
  State<PostJobSheet> createState() => _PostJobSheetState();
}

class _PostJobSheetState extends State<PostJobSheet> {
  final Set<WasteType> _selected = {};
  PaymentModel _paymentModel = PaymentModel.perKg;

  final _priceCtrl = TextEditingController();
  final _minQtyCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _priceCtrl.dispose();
    _minQtyCtrl.dispose();
    _areaCtrl.dispose();
    _descCtrl.dispose();
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
    widget.onSubmit(
      wasteTypes: _selected.toList(),
      paymentModel: _paymentModel,
      price: double.parse(_priceCtrl.text.trim()),
      collectionArea: _areaCtrl.text.trim(),
      jobDescription: _descCtrl.text.trim(),
      minQuantityKg: _paymentModel == PaymentModel.perKg &&
              _minQtyCtrl.text.trim().isNotEmpty
          ? double.tryParse(_minQtyCtrl.text.trim())
          : null,
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
            const SizedBox(height: 4),
            Text(
              'حدّد المواد والتسعيرة وسيظهر في السوق للجميع',
              style: GoogleFonts.cairo(
                  fontSize: 12, color: const Color(0xFF717973)),
            ),
            const SizedBox(height: 20),
            PostJobFormBody(
              selectedTypes: _selected,
              onToggleType: (t) =>
                  setState(() => _selected.contains(t)
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
            ),
          ],
        ),
      ),
    );
  }
}
