import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/order.dart';
import '../../../../data/services/app_order_store.dart';
import 'widgets/rate_driver_sheet.dart';
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

  const OrderDetailsView({super.key, required this.order, this.onCompleteOrder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: CustomScrollView(
        slivers: [
          OrderDetailsAppBar(order: order),
          SliverToBoxAdapter(
            child: OrderMapSection(order: order, hasDriver: order.driverName != null),
          ),
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
          
          if ((order.status == OrderStatus.accepted || order.status == OrderStatus.inTransit) && onCompleteOrder != null)
            SliverToBoxAdapter(
              child: OrderCompletionSection(
                order: order,
                onComplete: (updatedOrder) {
                  onCompleteOrder?.call(updatedOrder);
                  Navigator.of(context).pop(); // Go back after completion
                },
              ),
            ),
            
          if (order.status == OrderStatus.completed &&
              order.driverName != null)
            SliverToBoxAdapter(
              child: _RateDriverButton(
                order: order,
                onRate: (r) =>
                    context.read<AppOrderStore>().submitDriverRating(order.id, r),
              ),
            ),
          SliverToBoxAdapter(child: OrderActionButtons(order: order)),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
        ),
        icon: const Icon(Icons.star_outline_rounded, size: 20),
        label: Text(context.l10n.rateDriver),
      ),
    );
  }
}
