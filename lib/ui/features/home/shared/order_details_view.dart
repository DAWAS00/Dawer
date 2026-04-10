import 'package:flutter/material.dart';
import '../../../../data/models/order.dart';
import 'order_details/order_details_app_bar.dart';
import 'order_details/order_map_section.dart';
import 'order_details/order_status_timeline.dart';
import 'order_details/order_driver_card.dart';
import 'order_details/order_info_section.dart';
import 'order_details/order_action_buttons.dart';
import 'order_details/order_completion_section.dart';
import 'order_details/order_proof_section.dart';

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
            child: OrderMapSection(hasDriver: order.driverName != null),
          ),
          SliverToBoxAdapter(
            child: OrderStatusTimeline(status: order.status),
          ),
          if (order.driverName != null)
            SliverToBoxAdapter(child: OrderDriverCard(order: order)),
          SliverToBoxAdapter(child: OrderInfoSection(order: order)),
          
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
            
          SliverToBoxAdapter(child: OrderActionButtons(order: order)),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
