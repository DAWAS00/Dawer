import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:dwaar/core/constants/app_colors.dart';
import 'package:dwaar/data/models/order/order.dart';
import 'package:dwaar/l10n/l10n.dart';

class DriverActiveOrderCard extends StatefulWidget {
  const DriverActiveOrderCard({
    super.key,
    required this.order,
    required this.onConfirmArrival,
  });

  final Order order;
  final VoidCallback onConfirmArrival;

  @override
  State<DriverActiveOrderCard> createState() => _DriverActiveOrderCardState();
}

class _DriverActiveOrderCardState extends State<DriverActiveOrderCard> {
  bool get _hasCoords =>
      widget.order.pickupLat != null &&
      widget.order.pickupLng != null &&
      widget.order.dropoffLat != null &&
      widget.order.dropoffLng != null;

  LatLng get _midpoint => LatLng(
    ((widget.order.pickupLat ?? 0) + (widget.order.dropoffLat ?? 0)) / 2,
    ((widget.order.pickupLng ?? 0) + (widget.order.dropoffLng ?? 0)) / 2,
  );

  Set<Marker> get _markers => {
    Marker(
      markerId: const MarkerId('pickup'),
      position: LatLng(widget.order.pickupLat!, widget.order.pickupLng!),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ),
    Marker(
      markerId: const MarkerId('dropoff'),
      position: LatLng(widget.order.dropoffLat!, widget.order.dropoffLng!),
    ),
  };

  int get _currentStep => switch (widget.order.status) {
    OrderStatus.accepted => 0,
    OrderStatus.arrivedAtPickup => 1,
    OrderStatus.inTransit => 2,
    OrderStatus.arrivedAtDropoff || OrderStatus.completed => 3,
    _ => 0,
  };

  bool get _isHeadingToPickup => widget.order.status == OrderStatus.accepted;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.12),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Gradient header ──
          _buildHeader(context),

          // ── Progress stepper ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _OrderProgressStepper(currentStep: _currentStep),
          ),

          // ── Mini map OR route line ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _hasCoords ? _buildMiniMap() : _buildRouteLine(),
          ),

          // ── Address rows ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _buildAddressRows(),
          ),

          // ── Metrics ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _buildMetricsRow(),
          ),

          // ── Action button ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: _buildActionButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.ctaGradientStart, AppColors.ctaGradientEnd],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
                _isHeadingToPickup
                    ? l10n.driverHeadingToPickup
                    : l10n.driverHeadingToDelivery,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.shamrock200,
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .fade(duration: 1.seconds, begin: 0.5, end: 1.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              children: [
                const Icon(LucideIcons.radio, size: 13, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  l10n.driverActiveMission,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMap() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 180,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(target: _midpoint, zoom: 12.5),
          markers: _markers,
          zoomGesturesEnabled: false,
          scrollGesturesEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          myLocationButtonEnabled: false,
          mapToolbarEnabled: false,
          zoomControlsEnabled: false,
          onMapCreated: (_) {},
        ),
      ),
    );
  }

  Widget _buildRouteLine() {
    final l10n = context.l10n;
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        _buildRouteNode(
          active: _isHeadingToPickup,
          icon: LucideIcons.packageOpen,
          title: l10n.driverPickupLabel,
        ),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            color: _isHeadingToPickup
                ? AppColors.borderSubtle
                : AppColors.primaryGreen,
          ),
        ),
        _buildRouteNode(
          active: !_isHeadingToPickup,
          icon: LucideIcons.building2,
          title: l10n.driverDeliveryLabel,
        ),
      ],
    );
  }

  Widget _buildRouteNode({
    required bool active,
    required IconData icon,
    required String title,
  }) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: active ? AppColors.primaryGreen : AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? AppColors.primaryGreen : AppColors.borderSubtle,
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: active ? Colors.white : AppColors.mutedText,
            size: 20,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressRows() {
    final l10n = context.l10n;
    return Column(
      children: [
        _AddressRow(
          color: AppColors.primaryGreen,
          label: l10n.driverPickupLabel,
          address: widget.order.pickupAddress,
        ),
        const SizedBox(height: 8),
        _AddressRow(
          color: const Color(0xFFD32F2F),
          label: l10n.driverDeliveryLabel,
          address: widget.order.dropoffAddress,
        ),
      ],
    );
  }

  Widget _buildMetricsRow() {
    final l10n = context.l10n;
    final distanceText = widget.order.distanceKm != null
        ? l10n.orderDistKm(widget.order.distanceKm!.toStringAsFixed(1))
        : '--';
    final etaText = widget.order.etaMinutes != null
        ? l10n.driverActiveOrderEtaMinutes('${widget.order.etaMinutes}')
        : '--';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MetricItem(
            icon: LucideIcons.coins,
            label: l10n.driverRewardLabel,
            value: l10n.orderRewardJD(widget.order.reward.toStringAsFixed(1)),
            valueColor: AppColors.primaryGreen,
          ),
          Container(width: 1, height: 28, color: AppColors.borderSubtle),
          _MetricItem(
            icon: LucideIcons.clock,
            label: l10n.driverTimeLabel,
            value: etaText,
          ),
          Container(width: 1, height: 28, color: AppColors.borderSubtle),
          _MetricItem(
            icon: LucideIcons.map,
            label: l10n.driverDistanceLabel,
            value: distanceText,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    final l10n = context.l10n;
    return SizedBox(
      width: double.infinity,
      height: 66,
      child: ElevatedButton(
        onPressed: widget.onConfirmArrival,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.mapPin, size: 20),
            const SizedBox(width: 8),
            Text(
              _isHeadingToPickup
                  ? l10n.driverActiveOrderViewPickupDetails
                  : l10n.driverActiveOrderViewDeliveryDetails,
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ──

class _OrderProgressStepper extends StatelessWidget {
  const _OrderProgressStepper({required this.currentStep});
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final steps = [
      l10n.driverActiveOrderStepAccepted,
      l10n.driverActiveOrderStepArrivedPickup,
      l10n.driverActiveOrderStepInTransit,
      l10n.driverActiveOrderStepDelivered,
    ];
    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final connectorStep = i ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              color: connectorStep < currentStep
                  ? AppColors.primaryGreen
                  : AppColors.borderSubtle,
            ),
          );
        }
        final step = i ~/ 2;
        final done = step <= currentStep;
        return Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: done ? AppColors.primaryGreen : AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: done ? AppColors.primaryGreen : AppColors.borderSubtle,
                  width: 1.5,
                ),
              ),
              child: done
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 4),
            Text(
              steps[step],
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 9,
                fontWeight: done ? FontWeight.bold : FontWeight.normal,
                color: done ? AppColors.primaryGreen : AppColors.mutedText,
                height: 1.2,
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _AddressRow extends StatelessWidget {
  const _AddressRow({
    required this.color,
    required this.label,
    required this.address,
  });
  final Color color;
  final String label;
  final String address;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 4, left: 10),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: AppColors.mutedText,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                address,
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: AppColors.textMain,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.mutedText),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 10,
                color: AppColors.mutedText,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textMain,
          ),
        ),
      ],
    );
  }
}
