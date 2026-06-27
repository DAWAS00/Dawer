import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/layout/app_layout.dart';
import '../../../../../data/mock/order_mock_data.dart';
import '../../../../../data/models/order/order.dart';
import '../../shared/order_card.dart';
import '../../shared/order_tracking_card.dart';
import '../../shared/viewmodels/marketplace_viewmodel.dart';
import '../../shared/widgets/market_listing_card.dart';
import '../viewmodels/recycling_home_viewmodel.dart';
import '../widgets/post_job_sheet.dart';
import '../../../../core/components/dwaar_elevated_card.dart';
import '../../../../core/components/dwaar_skeleton.dart';
import '../../../../../l10n/l10n.dart';

class RecyclingHomeTab extends StatefulWidget {
  final String userName;
  final bool isOpen;
  final ValueChanged<bool> onToggleOpen;
  final List<Order> incoming;
  final List<Order> jobs;

  const RecyclingHomeTab({
    super.key,
    required this.userName,
    required this.isOpen,
    required this.onToggleOpen,
    required this.incoming,
    required this.jobs,
  });

  @override
  State<RecyclingHomeTab> createState() => _RecyclingHomeTabState();
}

class _RecyclingHomeTabState extends State<RecyclingHomeTab> {
  int _viewMode = 0; // 0 = Incoming, 1 = Active Jobs
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final vm = context.watch<RecyclingHomeViewModel>();
    final marketVm = context.watch<MarketplaceViewModel>();
    final myListings = marketVm.myListings(vm.companyName);

    final Order? tracked = widget.incoming
        .where((o) => o.status == OrderStatus.inTransit && o.driverName != null)
        .firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(context)),
          
          if (tracked != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 8),
                child: OrderTrackingCard(order: tracked).animate().slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart),
              ),
            ),
            
          SliverToBoxAdapter(child: _buildStatsRow(context)),
          SliverToBoxAdapter(child: _buildActionCards(context)),
          SliverToBoxAdapter(child: _buildOpsSection(context, vm)),

          if (myListings.isNotEmpty) ..._buildMyListingsSection(context, myListings, marketVm),
          
          // Segmented Control for Lists
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
              child: AnimatedToggleSwitch<int>.size(
                current: _viewMode,
                values: const [0, 1],
                indicatorSize: const Size.fromWidth(200),
                customIconBuilder: (context, local, global) {
                  final text = local.value == 0 ? l10n.recyclingIncomingShipmentsCount(widget.incoming.length) : l10n.recyclingActiveJobsCount(widget.jobs.length);
                  final color = Color.lerp(AppColors.mutedText, AppColors.surface, local.animationValue);
                  return Text(
                    text,
                    style: GoogleFonts.cairo(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  );
                },
                borderWidth: 4.0,
                style: ToggleStyle(
                  indicatorColor: AppColors.primaryGreen,
                  backgroundColor: AppColors.surface,
                  borderColor: AppColors.borderSubtle,
                  borderRadius: BorderRadius.circular(100),
                ),
                onChanged: (val) => setState(() => _viewMode = val),
              ).animate().fadeIn(duration: 300.ms),
            ),
          ),
          
          // Dynamic List Content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
            sliver: SliverToBoxAdapter(
              child: Builder(
                builder: (context) {
                  final recyclingVm = context.watch<RecyclingHomeViewModel>();
                  final loading = recyclingVm.isLoading;
                  final skeletons = OrderMockData.skeletonOrders();
                  final displayList = loading
                      ? skeletons
                      : (_viewMode == 0 ? widget.incoming : widget.jobs);

                  return DwaarSkeleton(
                    enabled: loading,
                    child: Column(
                      children: [
                        for (int i = 0; i < displayList.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: loading
                                ? OrderCard(order: displayList[i], mode: OrderCardMode.companyIncoming)
                                : _viewMode == 0
                                    ? OrderCard(order: displayList[i], mode: OrderCardMode.companyIncoming)
                                        .animate().fadeIn(delay: (i * 50).ms).slideX(begin: 0.05, end: 0)
                                    : Column(
                                        children: [
                                          OrderCard(order: displayList[i], mode: OrderCardMode.companyJob),
                                          if (vm.salesForJob(displayList[i].id).isNotEmpty)
                                            _buildAcceptorRow(context, vm.salesForJob(displayList[i].id)),
                                        ],
                                      ).animate().fadeIn(delay: (i * 50).ms).slideX(begin: -0.05, end: 0),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMyListingsSection(
    BuildContext context,
    List<Order> listings,
    MarketplaceViewModel marketVm,
  ) {
    final l10n = context.l10n;
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Text(
                l10n.recyclingMyListings,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.statusInTransitBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${listings.length}',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.statusInTransitText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: MarketListingCard(
                order: listings[i],
                onDelete: listings[i].status == OrderStatus.pending
                    ? () => _confirmDelete(context, listings[i].id, marketVm)
                    : null,
              ).animate().fadeIn(delay: (i * 100).ms),
            ),
            childCount: listings.length,
          ),
        ),
      ),
    ];
  }

  void _confirmDelete(BuildContext context, String orderId, MarketplaceViewModel marketVm) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(l10n.recyclingWithdrawAdTitle, textAlign: TextAlign.right, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        content: Text(l10n.recyclingWithdrawAdBody, textAlign: TextAlign.right, style: GoogleFonts.cairo()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.no, style: GoogleFonts.cairo(color: AppColors.mutedText)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              marketVm.removeListing(orderId);
            },
            child: Text(l10n.recyclingWithdrawAdConfirm, style: GoogleFonts.cairo(color: AppColors.statusCancelledText, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showPostJobSheet(BuildContext context) {
    final vm = context.read<RecyclingHomeViewModel>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Let the sheet provide its own styling
      builder: (_) => PostJobSheet(
        onSubmit: ({
          required List<WasteType> wasteTypes,
          required PaymentModel paymentModel,
          required double price,
          required String collectionArea,
          required String jobDescription,
          double? minQuantityKg,
        }) {
          vm.postCollectionJob(
            wasteTypes: wasteTypes,
            collectionArea: collectionArea,
            jobDescription: jobDescription,
            paymentModel: paymentModel,
            price: price,
            minQuantityKg: minQuantityKg,
          );
        },
      ),
    );
  }

  Widget _buildAcceptorRow(BuildContext context, List<Order> sales) {
    final l10n = context.l10n;
    Color chipBg(OrderStatus s) => switch (s) {
          OrderStatus.pending => AppColors.statusPendingBg,
          OrderStatus.accepted || OrderStatus.arrivedAtPickup => AppColors.statusActiveBg,
          OrderStatus.inTransit || OrderStatus.arrivedAtDropoff => AppColors.statusInTransitBg,
          OrderStatus.completed => AppColors.statusCompletedBg,
          OrderStatus.cancelled => AppColors.statusCancelledBg,
        };
    Color chipText(OrderStatus s) => switch (s) {
          OrderStatus.pending => AppColors.statusPendingText,
          OrderStatus.accepted || OrderStatus.arrivedAtPickup => AppColors.statusActiveText,
          OrderStatus.inTransit || OrderStatus.arrivedAtDropoff => AppColors.statusInTransitText,
          OrderStatus.completed => AppColors.statusCompletedText,
          OrderStatus.cancelled => AppColors.statusCancelledText,
        };

    const maxChips = 3;
    final shown = sales.length <= maxChips ? sales : sales.sublist(0, maxChips);
    final overflow = sales.length - maxChips;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.end,
              children: [
                if (overflow > 0)
                  Container(
                    height: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.borderSubtle,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      l10n.recyclingAndOthers(overflow),
                      style: GoogleFonts.cairo(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.mutedText),
                    ),
                  ),
                ...shown.map((s) => Container(
                      height: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: chipBg(s.status),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        s.status.label,
                        style: GoogleFonts.cairo(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: chipText(s.status)),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.recyclingResponses,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(LucideIcons.users, size: 16, color: AppColors.mutedText),
        ],
      ),
    );
  }

  // ── Ops Map (عمليات اليوم) ───────────────────────────────────────────────

  Widget _buildOpsSection(BuildContext context, RecyclingHomeViewModel vm) {
    final l10n = context.l10n;
    final positions = vm.driverPositions;

    final markers = positions.entries.map((e) {
      return Marker(
        markerId: MarkerId(e.key),
        position: e.value,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(title: '${l10n.orderDriverSection} ${e.key.substring(0, 6)}'),
      );
    }).toSet();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Text(
                l10n.recyclingTodayOperations,
                style: GoogleFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.statusInTransitBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${positions.length}',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.statusInTransitText,
                  ),
                ),
              ),
            ],
          ),
          if (vm.driverStreamError) ...[
            const SizedBox(height: 8),
            _buildReconnectingBanner(context),
          ],
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 240,
              child: positions.isEmpty
                  ? _buildOpsEmptyState(context)
                  : GoogleMap(
                      initialCameraPosition: const CameraPosition(
                        target: LatLng(31.9554, 35.9454), // Amman
                        zoom: 11,
                      ),
                      markers: markers,
                      onMapCreated: (c) => _mapController = c,
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                    ),
            ),
          ),
          if (positions.isNotEmpty) ...[
            const SizedBox(height: 10),
            _buildDriverChips(context, positions),
          ],
        ],
      ),
    );
  }

  Widget _buildOpsEmptyState(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withValues(alpha: 0.04),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.mapPin, size: 36, color: AppColors.mutedText),
            const SizedBox(height: 10),
            Text(
              l10n.recyclingNoActiveDrivers,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReconnectingBanner(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.amberContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.statusPendingText),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.recyclingReconnecting,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.statusPendingText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverChips(BuildContext context, Map<String, LatLng> positions) {
    final l10n = context.l10n;
    final ids = positions.keys.toList();
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: ids.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final id = ids[i];
          return GestureDetector(
            onTap: () {
              final pos = positions[id];
              if (pos != null) {
                _mapController?.animateCamera(
                  CameraUpdate.newCameraPosition(
                    CameraPosition(target: pos, zoom: 15),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.statusInTransitBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.statusInTransitText.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.navigation,
                      size: 13, color: AppColors.statusInTransitText),
                  const SizedBox(width: 5),
                  Text(
                    '${l10n.orderDriverSection} ${id.length > 6 ? id.substring(0, 6) : id}',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.statusInTransitText,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 24,
        left: context.layout.hPad,
        right: context.layout.hPad,
        bottom: 32,
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.surface.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: const Icon(LucideIcons.factory, color: AppColors.surface, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                Text(
                  widget.userName,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.surface,
                  ),
                ),
                Text(
                  l10n.recyclingFacility,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: AppColors.surface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => widget.onToggleOpen(!widget.isOpen),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.isOpen ? AppColors.shamrock600 : Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isOpen ? AppColors.primaryDark : Colors.white54,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.isOpen ? l10n.recyclingReadyForReceipt : l10n.recyclingClosedTemp,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: widget.isOpen ? AppColors.primaryDark : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final l10n = context.l10n;
    final inTransitCount = widget.incoming.where((o) => o.status == OrderStatus.inTransit).length;
    final totalWeight = widget.incoming.fold<double>(0, (sum, o) => sum + (o.weightKg ?? 0));

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(child: _StatCard(value: '${widget.incoming.length}', label: l10n.recyclingTodayShipments, icon: LucideIcons.truck, color: AppColors.statusInTransitText)),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(value: totalWeight.toStringAsFixed(0), label: l10n.recyclingTotalWeightKg, icon: LucideIcons.scale, color: AppColors.accentAmber)),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(value: '${widget.jobs.length}', label: l10n.recyclingActiveJobsLabel, icon: LucideIcons.briefcase, color: AppColors.primaryGreen)),
          const SizedBox(width: 8),
          Expanded(child: _StatCard(value: '$inTransitCount', label: l10n.recyclingDriversEnRoute, icon: LucideIcons.navigation, color: const Color(0xFF7C3AED))),
        ],
      ).animate().slideY(begin: 0.1, end: 0, duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildActionCards(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: DwaarElevatedCard(
        onTap: () => _showPostJobSheet(context),
        padding: const EdgeInsets.all(24),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(LucideIcons.circlePlus, color: AppColors.primaryGreen, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    l10n.recyclingPostJob,
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain,
                    ),
                  ),
                  Text(
                    l10n.recyclingPostJobSubtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().slideY(begin: 0.1, end: 0, delay: 100.ms, duration: 400.ms, curve: Curves.easeOutBack),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return DwaarElevatedCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textMain,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}
