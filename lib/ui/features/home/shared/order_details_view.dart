import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../data/models/order/order.dart';
import '../../../../data/services/app_order_store.dart';
import 'widgets/rate_driver_sheet.dart';
import 'order_details/order_arrival_section.dart';
import 'order_details/order_details_app_bar.dart';
import 'order_details/order_map_section.dart';
import 'order_details/order_status_timeline.dart';
import 'order_details/order_driver_card.dart';
import 'order_details/order_info_section.dart';
import 'order_details/order_earnings_section.dart';
import 'order_details/order_action_buttons.dart';
import 'order_details/order_completion_section.dart';
import 'order_details/order_proof_section.dart';
import '../../../../l10n/l10n.dart';

class OrderDetailsView extends StatelessWidget {
  final Order order;
  final void Function(Order)? onCompleteOrder;
  final Future<String?> Function(Order)? onMarkArrivedAtPickup;
  final Future<String?> Function(Order)? onMarkArrivedAtDropoff;
  final void Function(bool available)? onSupplierConfirmArrival;
  final bool hideStatus;

  const OrderDetailsView({
    super.key,
    required this.order,
    this.onCompleteOrder,
    this.onMarkArrivedAtPickup,
    this.onMarkArrivedAtDropoff,
    this.onSupplierConfirmArrival,
    this.hideStatus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      bottomNavigationBar: _buildBottomBar(context),
      body: CustomScrollView(
        slivers: [
          OrderDetailsAppBar(order: order, hideStatus: hideStatus),
          SliverToBoxAdapter(
            child: OrderMapSection(order: order, hasDriver: order.driverName != null),
          ),
          if (!hideStatus)
            SliverToBoxAdapter(
              child: OrderStatusTimeline(order: order),
            ),
          if (order.driverName != null)
            SliverToBoxAdapter(child: OrderDriverCard(order: order)),
          SliverToBoxAdapter(child: OrderInfoSection(order: order)),
          SliverToBoxAdapter(child: OrderEarningsSection(order: order)),
          
          if (order.status == OrderStatus.completed && order.proofImagePath != null)
            SliverToBoxAdapter(
              child: OrderProofSection(imagePath: order.proofImagePath!),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget? _buildBottomBar(BuildContext context) {
    final List<Widget> bottomWidgets = [];

    // 1. Chat & WhatsApp Actions
    if (order.driverName != null && order.status != OrderStatus.completed && order.status != OrderStatus.cancelled) {
       bottomWidgets.add(OrderActionButtons(order: order));
    }

    // 2. Arrival Actions
    final hasArrivalActions = onMarkArrivedAtPickup != null ||
        onMarkArrivedAtDropoff != null ||
        onSupplierConfirmArrival != null;
    
    if (hasArrivalActions) {
      bottomWidgets.add(OrderArrivalSection(
        order: order,
        onMarkArrivedAtPickup: onMarkArrivedAtPickup,
        onMarkArrivedAtDropoff: onMarkArrivedAtDropoff,
        onSupplierConfirmArrival: onSupplierConfirmArrival,
      ));
    }

    // 3. Completion Action
    if (order.status == OrderStatus.arrivedAtDropoff && onCompleteOrder != null) {
      bottomWidgets.add(OrderCompletionSection(
        order: order,
        onComplete: (updatedOrder) {
          onCompleteOrder?.call(updatedOrder);
          Navigator.of(context).pop();
        },
      ));
    }

    // 4. Rate Driver
    if (order.status == OrderStatus.completed && order.driverName != null) {
      bottomWidgets.add(_RateDriverButton(
        order: order,
        onRate: (r) => context.read<AppOrderStore>().submitDriverRating(order.id, r),
      ));
    }

    if (bottomWidgets.isEmpty) return null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06402B).withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: bottomWidgets,
          ),
        ),
      ),
    ).animate().slideY(begin: 1.0, end: 0.0, duration: 400.ms, curve: Curves.easeOutCubic);
  }
}

// ── Rate Driver Button ────────────────────────────────────────────────────────

class _RateDriverButton extends StatelessWidget {
  final Order order;
  final ValueChanged<double> onRate;

  const _RateDriverButton({required this.order, required this.onRate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: OutlinedButton.icon(
        onPressed: () => RateDriverSheet.show(
          context,
          order: order,
          onSubmit: onRate,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1E40AF),
          side: const BorderSide(color: Color(0xFFBFD3F5)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          minimumSize: const Size(double.infinity, 56),
        ),
        icon: const Icon(Icons.star_outline_rounded, size: 20),
        label: Text(context.l10n.rateDriver, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
