import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../domain/repositories/i_reservation_repository.dart';
import '../../../../l10n/l10n.dart';
import '../../../common/green_button.dart';
import '../reservation_viewmodel.dart';

/// Seller-side entry point: "Book/Reserve" — collects the buyer's phone,
/// an item description, the invoice amount and a duration, previews the
/// invoice + 10% guarantee disclaimer, then creates the reservation.
class CreateReservationView extends StatelessWidget {
  const CreateReservationView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ReservationViewModel(repository: ctx.read<IReservationRepository>()),
      child: const _CreateReservationBody(),
    );
  }
}

class _CreateReservationBody extends StatefulWidget {
  const _CreateReservationBody();

  @override
  State<_CreateReservationBody> createState() => _CreateReservationBodyState();
}

class _CreateReservationBodyState extends State<_CreateReservationBody> {
  static const _durations = [15, 30, 60, 120];

  final _itemTitleCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  int _durationMinutes = 30;
  bool _isSubmitting = false;
  String? _error;

  double get _amount => double.tryParse(_amountCtrl.text) ?? 0;
  double get _penaltyPreview => double.parse((_amount * 0.10).toStringAsFixed(2));

  @override
  void dispose() {
    _itemTitleCtrl.dispose();
    _phoneCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (_itemTitleCtrl.text.trim().isEmpty ||
        _phoneCtrl.text.trim().isEmpty ||
        _amount <= 0) {
      setState(() => _error = l10n.reservationBuyerNotFound);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final vm = context.read<ReservationViewModel>();
    final failure = await vm.createReservation(
      buyerPhone: _phoneCtrl.text,
      itemTitle: _itemTitleCtrl.text.trim(),
      invoiceTotal: _amount,
      durationMinutes: _durationMinutes,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (failure != null) {
      setState(() => _error = failure);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.reservationCreateSuccess)),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          l10n.reservationFormTitle,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.textMain),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _label(l10n.reservationItemTitleLabel),
            const SizedBox(height: 8),
            _field(controller: _itemTitleCtrl, hint: l10n.reservationItemTitleHint),
            const SizedBox(height: 20),

            _label(l10n.reservationBuyerPhoneLabel),
            const SizedBox(height: 8),
            _field(
              controller: _phoneCtrl,
              hint: l10n.reservationBuyerPhoneHint,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            _label(l10n.reservationInvoiceAmountLabel),
            const SizedBox(height: 8),
            _field(
              controller: _amountCtrl,
              hint: '0.00',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),

            _label(l10n.reservationDurationLabel),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: _durations.map((minutes) {
                final selected = _durationMinutes == minutes;
                return ChoiceChip(
                  label: Text(
                    l10n.reservationDurationMinutes(minutes),
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.white : AppColors.textMain,
                    ),
                  ),
                  selected: selected,
                  selectedColor: AppColors.primaryGreen,
                  backgroundColor: AppColors.surface,
                  onSelected: (_) => setState(() => _durationMinutes = minutes),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            if (_amount > 0) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Column(
                  children: [
                    _invoiceRow(
                      _itemTitleCtrl.text.trim().isEmpty
                          ? l10n.reservationItemTitleLabel
                          : _itemTitleCtrl.text.trim(),
                      '${_amount.toStringAsFixed(2)} د.أ',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1),
                    ),
                    _invoiceRow(
                      l10n.reservationDurationLabel,
                      l10n.reservationDurationMinutes(_durationMinutes),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1),
                    ),
                    _invoiceRow(
                      l10n.reservationInvoiceTotalLabel,
                      '${_amount.toStringAsFixed(2)} د.أ',
                      bold: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_amount > 0)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.statusCancelledBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.statusCancelledText.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.statusCancelledText, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.reservationPenaltyBanner(_penaltyPreview.toStringAsFixed(2)),
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.statusCancelledText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: GoogleFonts.cairo(color: AppColors.statusCancelledText, fontSize: 13),
                textAlign: TextAlign.center,
              ),
            ],

            const SizedBox(height: 28),
            GreenButton(
              text: l10n.reservationSubmitButton,
              isLoading: _isSubmitting,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _invoiceRow(String label, String value, {bool bold = false}) {
    return Row(
      children: [
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 15,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: bold ? AppColors.primaryGreen : AppColors.textMain,
          ),
        ),
        const Spacer(),
        Text(
          label,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: AppColors.mutedText,
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(
        text,
        style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.textMain),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderSubtle),
        ),
      ),
    );
  }
}
