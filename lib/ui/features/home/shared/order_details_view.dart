import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
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
import 'order_details/order_customer_card.dart';
import 'order_details/order_route_card.dart';
import 'order_details/order_contents_section.dart';
import 'order_details/order_eta_section.dart';
import '../../../../l10n/l10n.dart';

class OrderDetailsView extends StatelessWidget {
  final Order order;
  final void Function(Order)? onCompleteOrder;
  final Future<String?> Function(Order)? onMarkArrivedAtPickup;
  final Future<String?> Function(Order)? onMarkArrivedAtDropoff;
  final void Function(bool available)? onSupplierConfirmArrival;
  final bool hideStatus;
  final bool isDriverView;

  const OrderDetailsView({
    super.key,
    required this.order,
    this.onCompleteOrder,
    this.onMarkArrivedAtPickup,
    this.onMarkArrivedAtDropoff,
    this.onSupplierConfirmArrival,
    this.hideStatus = false,
    this.isDriverView = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _buildBottomBar(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          OrderDetailsAppBar(order: order, hideStatus: hideStatus),

          // ── Live ETA (top-of-screen; only while a driver is en route) ──
          SliverToBoxAdapter(
            child: OrderEtaSection(order: order, isDriverView: isDriverView),
          ),

          // ── Map ──
          SliverToBoxAdapter(
            child: OrderMapSection(
              order: order,
              hasDriver: order.driverName != null,
            ),
          ),

          // ── Status timeline (supplier view or when explicitly shown) ──
          if (!hideStatus && !isDriverView)
            SliverToBoxAdapter(child: OrderStatusTimeline(order: order)),

          // ════════════════════════════════════════
          // DRIVER VIEW — customer-first layout
          // ════════════════════════════════════════
          if (isDriverView) ...[
            // 4-step compact stepper
            SliverToBoxAdapter(child: _DriverStatusStepper(order: order)),
            // Customer contact card
            SliverToBoxAdapter(child: OrderCustomerCard(order: order)),
            // Visual route
            SliverToBoxAdapter(child: OrderRouteCard(order: order)),
            // Waste types + weight + notes
            SliverToBoxAdapter(child: OrderContentsSection(order: order)),
            // Earnings
            SliverToBoxAdapter(child: OrderEarningsSection(order: order)),
            // Proof photo (if completed)
            if (order.status == OrderStatus.completed &&
                order.proofImagePath != null)
              SliverToBoxAdapter(
                child: OrderProofSection(imagePath: order.proofImagePath!),
              ),
          ]
          // ════════════════════════════════════════
          // SUPPLIER / GENERAL VIEW — original layout
          // ════════════════════════════════════════
          else ...[
            if (order.driverName != null)
              SliverToBoxAdapter(child: OrderDriverCard(order: order)),
            SliverToBoxAdapter(child: OrderInfoSection(order: order)),
            SliverToBoxAdapter(child: OrderEarningsSection(order: order)),
            if (order.status == OrderStatus.completed &&
                order.proofImagePath != null)
              SliverToBoxAdapter(
                child: OrderProofSection(imagePath: order.proofImagePath!),
              ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget? _buildBottomBar(BuildContext context) {
    final List<Widget> bottomWidgets = [];

    if (isDriverView) {
      // ── Driver bottom bar: arrival + completion only ──
      final hasArrivalActions =
          onMarkArrivedAtPickup != null || onMarkArrivedAtDropoff != null;

      if (hasArrivalActions) {
        bottomWidgets.add(
          OrderArrivalSection(
            order: order,
            onMarkArrivedAtPickup: onMarkArrivedAtPickup,
            onMarkArrivedAtDropoff: onMarkArrivedAtDropoff,
          ),
        );
      }

      if (order.status == OrderStatus.arrivedAtDropoff &&
          onCompleteOrder != null) {
        bottomWidgets.add(
          OrderCompletionSection(
            order: order,
            onComplete: (updatedOrder) {
              onCompleteOrder?.call(updatedOrder);
              Navigator.of(context).pop();
            },
          ),
        );
      }
    } else {
      // ── Supplier / general bottom bar ──

      // Contact driver buttons (chat + WhatsApp)
      if (order.driverName != null &&
          order.status != OrderStatus.completed &&
          order.status != OrderStatus.cancelled) {
        bottomWidgets.add(OrderActionButtons(order: order));
      }

      // Arrival confirmation (supplier confirming driver arrived)
      if (onSupplierConfirmArrival != null) {
        bottomWidgets.add(
          OrderArrivalSection(
            order: order,
            onSupplierConfirmArrival: onSupplierConfirmArrival,
          ),
        );
      }

      // Completion
      if (order.status == OrderStatus.arrivedAtDropoff &&
          onCompleteOrder != null) {
        bottomWidgets.add(
          OrderCompletionSection(
            order: order,
            onComplete: (updatedOrder) {
              onCompleteOrder?.call(updatedOrder);
              Navigator.of(context).pop();
            },
          ),
        );
      }

      // Rate driver
      if (order.status == OrderStatus.completed && order.driverName != null) {
        bottomWidgets.add(
          _RateDriverButton(
            order: order,
            onRate: (r) =>
                context.read<AppOrderStore>().submitDriverRating(order.id, r),
          ),
        );
      }
    }

    if (bottomWidgets.isEmpty) return null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.97),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
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
    ).animate().slideY(
      begin: 1.0,
      end: 0.0,
      duration: 400.ms,
      curve: Curves.easeOutCubic,
    );
  }
}

// ── Compact 4-step driver status stepper ─────────────────────────────────────

class _DriverStatusStepper extends StatelessWidget {
  const _DriverStatusStepper({required this.order});
  final Order order;

  static const _steps = [
    (label: 'مقبول', icon: Icons.check_circle_rounded),
    (label: 'في الطريق', icon: Icons.local_shipping_rounded),
    (label: 'وصلت', icon: Icons.location_on_rounded),
    (label: 'مكتمل', icon: Icons.flag_rounded),
  ];

  int get _currentStep => switch (order.status) {
    OrderStatus.accepted => 0,
    OrderStatus.arrivedAtPickup => 1,
    OrderStatus.inTransit => 2,
    OrderStatus.arrivedAtDropoff || OrderStatus.completed => 3,
    _ => 0,
  };

  @override
  Widget build(BuildContext context) {
    final step = _currentStep;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final connectorIdx = i ~/ 2;
            final active = connectorIdx < step;
            return Expanded(
              child: Container(
                height: 2.5,
                decoration: BoxDecoration(
                  gradient: active
                      ? const LinearGradient(
                          colors: [
                            AppColors.ctaGradientStart,
                            AppColors.ctaGradientEnd,
                          ],
                        )
                      : null,
                  color: active ? null : const Color(0xFFE2E8E5),
                  borderRadius: BorderRadius.circular(1.25),
                ),
              ),
            );
          }
          final idx = i ~/ 2;
          final done = idx < step;
          final current = idx == step;
          return _StepDot(
            label: _steps[idx].label,
            icon: _steps[idx].icon,
            done: done,
            current: current,
          );
        }),
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(
      begin: 0.04,
      end: 0,
      duration: 400.ms,
      curve: Curves.easeOutCubic,
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.label,
    required this.icon,
    required this.done,
    required this.current,
  });
  final String label;
  final IconData icon;
  final bool done;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final Color bg = done || current
        ? AppColors.primaryGreen
        : const Color(0xFFEEF2EE);
    final Color fg = done || current ? Colors.white : const Color(0xFF9EA89E);

    Widget dot = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: current ? 34 : 28,
      height: current ? 34 : 28,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: current
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
        border: current
            ? Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.2),
                width: 3,
              )
            : null,
      ),
      child: Icon(
        done ? Icons.check_rounded : icon,
        size: current ? 16 : 13,
        color: fg,
      ),
    );

    if (current) {
      dot = dot
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scaleXY(end: 1.08, duration: 1200.ms, curve: Curves.easeInOut);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        dot,
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 9,
            fontWeight: current ? FontWeight.bold : FontWeight.w500,
            color: current
                ? AppColors.primaryGreen
                : done
                ? const Color(0xFF404943)
                : const Color(0xFF9EA89E),
          ),
        ),
      ],
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
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF1E40AF).withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: () =>
                RateDriverSheet.show(context, order: order, onSubmit: onRate),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.star_outline_rounded,
                    size: 20,
                    color: Color(0xFF1E40AF),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.rateDriver,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E40AF),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
