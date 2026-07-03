import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../data/models/order/order.dart';
import '../../../../data/models/order_labels.dart';
import '../../../../data/models/user.dart';
import '../../../../l10n/l10n.dart';
import '../../../features/auth/viewmodels/login_viewmodel.dart';
import 'viewmodels/marketplace_viewmodel.dart';
import 'market_item_details/widgets/market_item_description_card.dart';
import 'market_item_details/widgets/market_item_delivery_address_sheet.dart';
import 'market_item_details/widgets/market_item_image_carousel.dart';
import 'market_item_details/widgets/market_item_info_card.dart';
import 'market_item_details/widgets/market_item_photo_gallery.dart';
import 'market_item_details/widgets/market_item_price_card.dart';
import 'market_item_details/widgets/market_item_purchase_choice_sheet.dart';
import 'market_item_details/widgets/market_item_rider_choice_sheet.dart';
import 'market_item_details/widgets/market_item_invoice_sheet.dart';
import 'market_item_details/widgets/market_item_reserve_sheet.dart';
import '../../../core/components/dwaar_snackbar.dart';

class MarketItemDetailsView extends StatelessWidget {
  final Order item;
  final UserRole role;
  final void Function(Order purchasedOrder)? onSupplierPurchaseConfirmed;

  const MarketItemDetailsView({
    super.key,
    required this.item,
    required this.role,
    this.onSupplierPurchaseConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context);
    return Scaffold(
      backgroundColor: context.dt.scaffold,
      body: CustomScrollView(
        slivers: [
          // ── App bar with image carousel ──
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: item.images.isNotEmpty
                  ? MarketItemImageCarousel(
                      images: item.images,
                      wasteTypes: item.wasteTypes,
                    )
                  : MarketItemGradientPlaceholder(
                      wasteType: item.wasteTypes.first,
                    ),
            ),
          ),

          // ── Body ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MarketItemPriceCard(item: item),
                  const SizedBox(height: 16),
                  MarketItemDescriptionCard(notes: item.supplierNotes),
                  if (item.images.length > 1) ...[
                    const SizedBox(height: 16),
                    MarketItemPhotoGallery(images: item.images),
                  ],
                  const SizedBox(height: 16),
                  MarketItemInfoCard(
                    icon: Icons.person_rounded,
                    title: l10n.marketItemSellerLabel,
                    value: item.supplierName ?? l10n.marketItemUnknownSeller,
                  ),
                  const SizedBox(height: 12),
                  MarketItemInfoCard(
                    icon: Icons.location_on_rounded,
                    title: l10n.marketItemPickupAddressLabel,
                    value: item.pickupAddress,
                  ),
                  const SizedBox(height: 12),
                  if (item.distanceKm != null) ...[
                    MarketItemInfoCard(
                      icon: Icons.straighten_rounded,
                      title: l10n.marketItemDistanceLabel,
                      value: l10n.marketItemDistanceValue(
                        item.distanceKm!.toStringAsFixed(1),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: MarketItemInfoCard(
                          icon: Icons.category_rounded,
                          title: l10n.marketItemConditionLabel,
                          value:
                              item.wasteForm?.labelFor(locale) ??
                              l10n.marketItemUnknown,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MarketItemInfoCard(
                          icon: Icons.fitness_center_rounded,
                          title: l10n.marketItemWeightLabel,
                          value:
                              item.weightCategory?.shortLabelFor(locale) ??
                              l10n.marketItemUnknown,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  MarketItemInfoCard(
                    icon: Icons.access_time_rounded,
                    title: l10n.marketItemPublishDateLabel,
                    value: _formatTime(context, item.createdAt),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildActionBar(context),
    );
  }

  void _showSupplierPurchaseChoiceSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => MarketItemPurchaseChoiceSheet(
        onSelfPickup: () => _handleSupplierSelfPickup(context),
        onAssignRider: () {
          Navigator.pop(sheetContext);
          _showDeliveryAddressSheet(context);
        },
      ),
    );
  }

  void _handleSupplierSelfPickup(BuildContext context) {
    final marketVm = context.read<MarketplaceViewModel>();
    final purchased = marketVm.purchaseItem(
      orderId: item.id,
      mode: SupplierPurchaseMode.selfPickup,
    );
    if (purchased == null) return;
    onSupplierPurchaseConfirmed?.call(purchased);
    Navigator.pop(context); // close choice sheet
    Navigator.pop(context); // close details
    context.showSuccessSnackBar(context.l10n.marketItemPurchasedPickup);
  }

  Widget _buildActionBar(BuildContext context) {
    final (label, icon, color, onTap) = switch (role) {
      UserRole.driver => (
        context.l10n.marketItemDriverReceive,
        Icons.local_shipping_rounded,
        const Color(0xFF06402B),
        () => _showRiderChoiceSheet(context),
      ),
      UserRole.supplier => (
        context.l10n.marketItemBuyNow,
        Icons.shopping_cart_rounded,
        const Color(0xFF06402B),
        () => _showSupplierPurchaseChoiceSheet(context),
      ),
      UserRole.recyclingCo => (
        context.l10n.marketItemCompanyReceive,
        Icons.business_rounded,
        const Color(0xFF1E40AF),
        () => _handleCompanyReceive(context),
      ),
    };

    // Show the Reserve button only when item is still available for reservation
    final canReserve =
        item.status == OrderStatus.pending &&
        item.reservationStatus == null &&
        item.itemPrice != null &&
        item.itemPrice! > 0;

    // Show reservation status badge when already reserved
    final isReservedByOther = item.reservationStatus != null;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      decoration: BoxDecoration(
        color: context.dt.surface,
        boxShadow: [
          BoxShadow(
            color: context.dt.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reservation status notice
            if (isReservedByOther) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFCD34D)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      item.reservationStatus!.label,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF92400E),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.lock_clock_rounded,
                      color: Color(0xFFD97706),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ],

            // Primary action
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isReservedByOther ? null : onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  disabledBackgroundColor: const Color(0xFFD1D5DB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(icon, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),

            // Reserve button (secondary)
            if (canReserve) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton(
                  onPressed: () => _showReserveSheet(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF06402B),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        context.l10n.marketItemReserveNowButton,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF06402B),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.bookmark_add_rounded,
                        color: Color(0xFF06402B),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showReserveSheet(BuildContext context) {
    // Use a mock wallet balance of 50 JD for demo; wire to real wallet later
    const mockWalletBalance = 50.0;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => MarketItemReserveSheet(
        item: item,
        walletBalance: mockWalletBalance,
        onConfirm: (pickupDate) {
          final vm = context.read<MarketplaceViewModel>();
          final err = vm.reserveItem(
            orderId: item.id,
            reserverName: 'المستخدم الحالي',
            reserverId: 'CURRENT-USER',
            pickupDate: pickupDate,
          );
          if (err != null) {
            context.showErrorSnackBar(err);
          } else {
            context.showSuccessSnackBar(context.l10n.marketItemReservationSent);
          }
          if (err == null) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  void _showRiderChoiceSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => MarketItemRiderChoiceSheet(
        onBuyForSelf: () {
          Navigator.pop(sheetContext);
          _showRiderInvoiceSheet(context);
        },
        onDeliver: () {
          Navigator.pop(sheetContext);
          _handleDriverClaim(context);
        },
      ),
    );
  }

  void _showRiderInvoiceSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => MarketItemInvoiceSheet(
        item: item,
        onConfirm: () => _handleRiderBuyForSelf(context),
      ),
    );
  }

  void _handleRiderBuyForSelf(BuildContext context) {
    final marketVm = context.read<MarketplaceViewModel>();
    final purchased = marketVm.purchaseItem(
      orderId: item.id,
      mode: SupplierPurchaseMode.selfPickup,
    );
    if (purchased == null) return;

    Navigator.pop(context); // close invoice sheet
    Navigator.pop(context); // close details

    context.showSuccessSnackBar(
      context.l10n.marketInvoicePickupSuccess,
      duration: const Duration(seconds: 5),
    );
  }

  void _handleDriverClaim(BuildContext context) {
    final vm = context.read<MarketplaceViewModel>();
    final claimed = vm.claimItem(
      item.id,
      const User(id: 'DRV-19842', name: 'سائق دوّر', role: 'سائق'),
    );
    if (claimed != null) {
      Navigator.pop(context);
      context.showSuccessSnackBar(context.l10n.marketItemReceived);
    }
  }

  void _showDeliveryAddressSheet(BuildContext context) {
    final marketVm = context.read<MarketplaceViewModel>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => MarketItemDeliveryAddressSheet(
        item: item,
        onConfirm: (address, fee) {
          final purchased = marketVm.purchaseItem(
            orderId: item.id,
            mode: SupplierPurchaseMode.assignRider,
            dropoffAddress: address,
            deliveryFee: fee,
          );
          if (purchased == null) return;
          onSupplierPurchaseConfirmed?.call(purchased);
          Navigator.pop(context); // close sheet
          Navigator.pop(context); // close details
          context.showSuccessSnackBar(context.l10n.marketItemPurchasedDriver);
        },
      ),
    );
  }

  void _handleCompanyReceive(BuildContext context) {
    final vm = context.read<MarketplaceViewModel>();
    final received = vm.receiveAtFacility(item.id, 'مقر الشركة');
    if (received != null) {
      Navigator.pop(context);
      context.showInfoSnackBar(context.l10n.marketItemFacilityReceived);
    }
  }

  String _formatTime(BuildContext context, DateTime dt) {
    final diff = DateTime.now().difference(dt);
    final l10n = context.l10n;
    if (diff.inDays > 0) return l10n.timeAgoDays(diff.inDays);
    if (diff.inHours > 0) return l10n.timeAgoHours(diff.inHours);
    return l10n.timeAgoMinutes(diff.inMinutes);
  }
}
