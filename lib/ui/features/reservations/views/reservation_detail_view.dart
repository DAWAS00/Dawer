import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/reservation.dart';
import '../../../../domain/repositories/i_auth_repository.dart';
import '../../../../l10n/l10n.dart';
import '../../../common/green_button.dart';
import '../reservation_viewmodel.dart';

/// Invoice + countdown + role-aware actions (approve / complete / cancel)
/// for a single reservation.
class ReservationDetailView extends StatefulWidget {
  const ReservationDetailView({super.key, required this.reservationId});

  final String reservationId;

  @override
  State<ReservationDetailView> createState() => _ReservationDetailViewState();
}

class _ReservationDetailViewState extends State<ReservationDetailView> {
  bool _isActing = false;
  String? _error;

  Future<void> _run(Future<String?> Function() action, {String? successMessage}) async {
    setState(() {
      _isActing = true;
      _error = null;
    });
    final failure = await action();
    if (!mounted) return;
    setState(() {
      _isActing = false;
      _error = failure;
    });
    if (failure == null && successMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(successMessage)));
    }
  }

  Future<void> _confirmCancel(Reservation r) async {
    final l10n = context.l10n;
    var reason = 'other';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => AlertDialog(
          title: Text(l10n.reservationCancelReasonTitle, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          content: RadioGroup<String>(
            groupValue: reason,
            onChanged: (v) => setDialogState(() => reason = v!),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RadioListTile<String>(
                  value: 'sold_elsewhere',
                  title: Text(l10n.reservationCancelReasonSoldElsewhere, style: GoogleFonts.cairo(fontSize: 13)),
                ),
                RadioListTile<String>(
                  value: 'other',
                  title: Text(l10n.reservationCancelReasonOther, style: GoogleFonts.cairo(fontSize: 13)),
                ),
                if (reason == 'sold_elsewhere' && r.status == ReservationStatus.reserved)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l10n.reservationCancelFraudWarning,
                      style: GoogleFonts.cairo(color: AppColors.statusCancelledText, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogCtx, false), child: const Text('إلغاء')),
            TextButton(onPressed: () => Navigator.pop(dialogCtx, true), child: Text(l10n.reservationCancelButton)),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      await _run(() => context.read<ReservationViewModel>().cancel(r.id, reason));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vm = context.watch<ReservationViewModel>();
    final userId = context.read<IAuthRepository>().currentSession?.userId ?? '';

    final reservation = vm.reservations.where((r) => r.id == widget.reservationId).firstOrNull;

    if (reservation == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(backgroundColor: AppColors.background, elevation: 0),
        body: Center(child: Text(l10n.reservationEmptyInbox)),
      );
    }

    final isBuyer = reservation.buyerId == userId;
    final isSeller = reservation.sellerId == userId;
    final remaining = reservation.timeRemaining;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          reservation.itemTitle,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.textMain),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  _row(l10n.reservationInvoiceTotalLabel, '${reservation.invoiceTotal.toStringAsFixed(2)} د.أ', bold: true),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                  _row(l10n.reservationDurationLabel, l10n.reservationDurationMinutes(reservation.durationMinutes)),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                  _row('الحالة', reservation.status.label),
                  if (remaining != null && reservation.status == ReservationStatus.reserved) ...[
                    const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                    _row(l10n.reservationTimeRemainingLabel, _formatDuration(remaining)),
                  ],
                  if (reservation.penaltyAmount != null) ...[
                    const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
                    _row('الغرامة', '${reservation.penaltyAmount!.toStringAsFixed(2)} د.أ'),
                  ],
                ],
              ),
            ),

            if (reservation.status == ReservationStatus.pendingApproval)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.statusCancelledBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.reservationPenaltyBanner(reservation.penaltyPreview.toStringAsFixed(2)),
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.statusCancelledText,
                    ),
                  ),
                ),
              ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: GoogleFonts.cairo(color: AppColors.statusCancelledText), textAlign: TextAlign.center),
            ],

            const SizedBox(height: 24),

            if (isBuyer && reservation.status == ReservationStatus.pendingApproval)
              GreenButton(
                text: l10n.reservationApproveButton,
                isLoading: _isActing,
                onPressed: () => _run(
                  () => context.read<ReservationViewModel>().approve(reservation.id),
                  successMessage: l10n.reservationApproveSuccess,
                ),
              ),

            if ((isBuyer || isSeller) &&
                reservation.status == ReservationStatus.reserved &&
                !reservation.isExpired) ...[
              GreenButton(
                text: l10n.reservationCompleteButton,
                isLoading: _isActing,
                onPressed: () => _run(() => context.read<ReservationViewModel>().complete(reservation.id)),
              ),
              const SizedBox(height: 12),
            ],

            if (isSeller && reservation.status.isOpen)
              TextButton(
                onPressed: _isActing ? null : () => _confirmCancel(reservation),
                child: Text(
                  l10n.reservationCancelButton,
                  style: GoogleFonts.cairo(color: AppColors.statusCancelledText, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
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
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: AppColors.mutedText,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}
