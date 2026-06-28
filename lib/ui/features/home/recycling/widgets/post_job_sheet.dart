import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../data/models/order/order.dart';
import 'post_job_form.dart';

typedef PostJobSubmitCallback = void Function({
  required List<WasteType> wasteTypes,
  required PaymentModel paymentModel,
  required double price,
  required String collectionArea,
  required String jobDescription,
  double? minQuantityKg,
});

class PostJobSheet extends HookWidget {
  final PostJobSubmitCallback onSubmit;

  const PostJobSheet({super.key, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final selected = useState<Set<WasteType>>({});
    final paymentModel = useState<PaymentModel>(PaymentModel.perKg);

    final priceCtrl = useTextEditingController();
    final minQtyCtrl = useTextEditingController();
    final areaCtrl = useTextEditingController();
    final descCtrl = useTextEditingController();

    bool isValid() =>
        selected.value.isNotEmpty &&
        priceCtrl.text.trim().isNotEmpty &&
        double.tryParse(priceCtrl.text.trim()) != null &&
        double.parse(priceCtrl.text.trim()) > 0 &&
        areaCtrl.text.trim().isNotEmpty &&
        descCtrl.text.trim().isNotEmpty;

    void submit() {
      if (!isValid()) return;
      onSubmit(
        wasteTypes: selected.value.toList(),
        paymentModel: paymentModel.value,
        price: double.parse(priceCtrl.text.trim()),
        collectionArea: areaCtrl.text.trim(),
        jobDescription: descCtrl.text.trim(),
        minQuantityKg: paymentModel.value == PaymentModel.perKg &&
                minQtyCtrl.text.trim().isNotEmpty
            ? double.tryParse(minQtyCtrl.text.trim())
            : null,
      );
      Navigator.pop(context);
    }

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
              selectedTypes: selected.value,
              onToggleType: (t) {
                final newSet = Set<WasteType>.from(selected.value);
                if (newSet.contains(t)) {
                  newSet.remove(t);
                } else {
                  newSet.add(t);
                }
                selected.value = newSet;
              },
              paymentModel: paymentModel.value,
              onPaymentModelChanged: (m) => paymentModel.value = m,
              priceCtrl: priceCtrl,
              minQtyCtrl: minQtyCtrl,
              areaCtrl: areaCtrl,
              descriptionCtrl: descCtrl,
            ),
            const SizedBox(height: 28),
            ListenableBuilder(
              listenable:
                  Listenable.merge([priceCtrl, areaCtrl, descCtrl, selected, paymentModel]),
              builder: (context, _) => SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isValid() ? submit : null,
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
