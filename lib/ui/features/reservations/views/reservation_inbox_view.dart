import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/reservation.dart';
import '../../../../domain/repositories/i_auth_repository.dart';
import '../../../../domain/repositories/i_reservation_repository.dart';
import '../../../../l10n/l10n.dart';
import '../reservation_viewmodel.dart';
import 'reservation_detail_view.dart';

/// Buyer-facing inbox of incoming reservation requests, plus a "mine" tab so
/// a seller can track/cancel the reservations they created.
class ReservationInboxView extends StatelessWidget {
  const ReservationInboxView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => ReservationViewModel(repository: ctx.read<IReservationRepository>())
        ..refresh()
        ..startCountdownTicker(),
      child: const _ReservationInboxBody(),
    );
  }
}

class _ReservationInboxBody extends StatelessWidget {
  const _ReservationInboxBody();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vm = context.watch<ReservationViewModel>();
    final userId = context.read<IAuthRepository>().currentSession?.userId ?? '';

    final incoming = vm.incomingFor(userId);
    final mine = vm.createdBy(userId);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            l10n.reservationInboxTitle,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.textMain),
          ),
          bottom: TabBar(
            labelColor: AppColors.primaryGreen,
            unselectedLabelColor: AppColors.mutedText,
            indicatorColor: AppColors.primaryGreen,
            labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: l10n.reservationBuyerTag),
              Tab(text: l10n.reservationSellerTag),
            ],
          ),
        ),
        body: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _ReservationList(items: incoming, userId: userId, emptyText: l10n.reservationEmptyInbox),
                  _ReservationList(items: mine, userId: userId, emptyText: l10n.reservationEmptyInbox),
                ],
              ),
      ),
    );
  }
}

class _ReservationList extends StatelessWidget {
  const _ReservationList({required this.items, required this.userId, required this.emptyText});

  final List<Reservation> items;
  final String userId;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          emptyText,
          style: GoogleFonts.cairo(color: AppColors.mutedText),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final r = items[i];
        return _ReservationCard(reservation: r);
      },
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({required this.reservation});

  final Reservation reservation;

  @override
  Widget build(BuildContext context) {
    final remaining = reservation.timeRemaining;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: context.read<ReservationViewModel>(),
            child: ReservationDetailView(reservationId: reservation.id),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reservation.itemTitle,
                    style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: AppColors.textMain),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${reservation.invoiceTotal.toStringAsFixed(2)} د.أ',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reservation.status.label,
                    style: GoogleFonts.cairo(fontSize: 12, color: AppColors.mutedText),
                  ),
                  if (remaining != null && reservation.status == ReservationStatus.reserved)
                    Text(
                      _formatDuration(remaining),
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: remaining.inMinutes < 5
                            ? AppColors.statusCancelledText
                            : AppColors.statusInTransitText,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.borderSubtle),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    return h > 0 ? '$h:$m' : '${d.inMinutes}:${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';
  }
}
