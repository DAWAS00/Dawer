import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../data/models/order/order.dart';
import '../../shared/viewmodels/marketplace_viewmodel.dart';

/// Popup shown to a supplier on app launch when they have marketplace items
/// with pending reservation requests awaiting their Accept / Reject decision.
class PendingReservationsDialog extends StatelessWidget {
  final String sellerName;

  const PendingReservationsDialog({super.key, required this.sellerName});

  /// Show the dialog only if there are pending reservations.
  static void showIfNeeded(BuildContext context, String sellerName) {
    final vm = context.read<MarketplaceViewModel>();
    if (vm.pendingReservationsForSeller(sellerName).isEmpty) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PendingReservationsDialog(sellerName: sellerName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Consumer<MarketplaceViewModel>(
        builder: (ctx, vm, _) {
          final reservations = vm.pendingReservationsForSeller(sellerName);

          if (reservations.isEmpty) {
            // All handled — auto-close
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (ctx.mounted) Navigator.pop(ctx);
            });
            return const SizedBox.shrink();
          }

          return ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  color: const Color(0xFF06402B),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'طلبات حجز جديدة',
                            style: GoogleFonts.cairo(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.bookmark_added_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'هناك ${reservations.length} طلب حجز على منتجاتك بانتظار ردّك.',
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),

                // Reservation cards
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: reservations.length,
                    separatorBuilder: (_, __) => const Divider(height: 24),
                    itemBuilder: (ctx2, i) => _ReservationCard(
                      item: reservations[i],
                      sellerName: sellerName,
                    ),
                  ),
                ),

                // Close button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'تأجيل',
                      style: GoogleFonts.cairo(
                        color: const Color(0xFF6B7280),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final Order item;
  final String sellerName;

  const _ReservationCard({required this.item, required this.sellerName});

  String _formatDate(DateTime? dt) {
    if (dt == null) return '—';
    const months = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<MarketplaceViewModel>();
    final deposit = item.buyerDepositAmount ?? 0;
    final price = item.itemPrice ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Item name & type
        Text(
          item.wasteTypes.map((t) => t.label).join('، '),
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF002819),
          ),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 6),

        // Buyer name
        _DetailRow(
          icon: Icons.person_rounded,
          label: 'من: ${item.reservedByName ?? "—"}',
        ),

        // Pickup date
        _DetailRow(
          icon: Icons.calendar_today_rounded,
          label: 'موعد الاستلام: ${_formatDate(item.reservationPickupDate)}',
        ),

        // Prices
        _DetailRow(
          icon: Icons.attach_money_rounded,
          label: 'قيمة العنصر: ${price.toStringAsFixed(2)} د.أ',
        ),

        // Buyer deposit
        Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'دفع المشتري تأميناً بقيمة ${deposit.toStringAsFixed(2)} د.أ',
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF065F46),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.verified_rounded,
                color: Color(0xFF059669),
                size: 14,
              ),
            ],
          ),
        ),

        // Seller commitment note
        Container(
          margin: const EdgeInsets.only(top: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  'بالقبول ستُدفع منك أيضاً نسبة ١٠٪ (${deposit.toStringAsFixed(2)} د.أ) كتأمين. إلغاؤك لاحقاً يُصادَر لصالح المشتري.',
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: const Color(0xFF92400E),
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.info_outline_rounded,
                color: Color(0xFFD97706),
                size: 14,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Accept / Reject buttons
        Row(
          children: [
            // Reject
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  vm.respondToReservation(
                    orderId: item.id,
                    sellerName: sellerName,
                    accept: false,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'تم رفض طلب الحجز',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: const Color(0xFF374151),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFDC2626)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'رفض',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFDC2626),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Accept
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  vm.respondToReservation(
                    orderId: item.id,
                    sellerName: sellerName,
                    accept: true,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'قبلت طلب الحجز ✓',
                        style: GoogleFonts.cairo(),
                      ),
                      backgroundColor: const Color(0xFF1E5C35),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF06402B),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'قبول',
                  style: GoogleFonts.cairo(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, size: 14, color: const Color(0xFF9CA3AF)),
        ],
      ),
    );
  }
}
