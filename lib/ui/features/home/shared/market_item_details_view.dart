import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/order.dart';
import '../../../../data/models/user.dart';
import '../../../features/auth/viewmodels/login_viewmodel.dart';
import 'viewmodels/marketplace_viewmodel.dart';
import 'market_item_details/widgets/market_item_description_card.dart';
import 'market_item_details/widgets/market_item_delivery_address_sheet.dart';
import 'market_item_details/widgets/market_item_image_carousel.dart';
import 'market_item_details/widgets/market_item_info_card.dart';
import 'market_item_details/widgets/market_item_photo_gallery.dart';
import 'market_item_details/widgets/market_item_price_card.dart';
import 'market_item_details/widgets/market_item_purchase_choice_sheet.dart';

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
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: CustomScrollView(
        slivers: [
          // ── App bar with image carousel ──
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF14401F),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
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
                  MarketItemInfoCard(icon: Icons.person_rounded, title: 'البائع', value: item.supplierName ?? 'بائع مجهول'),
                  const SizedBox(height: 12),
                  MarketItemInfoCard(icon: Icons.location_on_rounded, title: 'عنوان الاستلام', value: item.pickupAddress),
                  const SizedBox(height: 12),
                  if (item.distanceKm != null) ...[
                    MarketItemInfoCard(icon: Icons.straighten_rounded, title: 'المسافة التقديرية', value: '${item.distanceKm!.toStringAsFixed(1)} كم من موقعك'),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(child: MarketItemInfoCard(icon: Icons.category_rounded, title: 'الحالة', value: item.wasteForm?.label ?? 'غير محدد')),
                      const SizedBox(width: 12),
                      Expanded(child: MarketItemInfoCard(icon: Icons.fitness_center_rounded, title: 'الوزن', value: item.weightCategory?.shortLabel ?? 'غير محدد')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  MarketItemInfoCard(icon: Icons.access_time_rounded, title: 'تاريخ النشر', value: _formatTime(item.createdAt)),
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
      backgroundColor: Colors.white,
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم الشراء! يمكنك الاستلام من السوق.', style: GoogleFonts.cairo()),
        backgroundColor: const Color(0xFF1E5C35),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildActionBar(BuildContext context) {
    final (label, icon, color, onTap) = switch (role) {
      UserRole.driver => (
          'استلام العنصر',
          Icons.local_shipping_rounded,
          const Color(0xFF06402B),
          () => _handleDriverClaim(context),
        ),
      UserRole.supplier => (
          'شراء الآن',
          Icons.shopping_cart_rounded,
          const Color(0xFF06402B),
          () => _showSupplierPurchaseChoiceSheet(context),
        ),
      UserRole.recyclingCo => (
          'استلام في المنشأة',
          Icons.business_rounded,
          const Color(0xFF1E40AF),
          () => _handleCompanyReceive(context),
        ),
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleDriverClaim(BuildContext context) {
    final vm = context.read<MarketplaceViewModel>();
    final claimed = vm.claimItem(item.id, const User(id: 'DRV-19842', name: 'سائق دوّر', role: 'سائق'));
    if (claimed != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم استلام العنصر بنجاح!', style: GoogleFonts.cairo()),
          backgroundColor: const Color(0xFF1E5C35),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showDeliveryAddressSheet(BuildContext context) {
    final marketVm = context.read<MarketplaceViewModel>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('تم الشراء! سيتم إرسال سائق للاستلام.', style: GoogleFonts.cairo()),
              backgroundColor: const Color(0xFF1E5C35),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
      ),
    );
  }

  void _handleCompanyReceive(BuildContext context) {
    final vm = context.read<MarketplaceViewModel>();
    final received = vm.receiveAtFacility(item.id, 'مقر الشركة');
    if (received != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تسجيل الاستلام في المنشأة!', style: GoogleFonts.cairo()),
          backgroundColor: const Color(0xFF1E40AF),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return 'منذ ${diff.inDays} يوم';
    if (diff.inHours > 0) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inMinutes} دقيقة';
  }
}
