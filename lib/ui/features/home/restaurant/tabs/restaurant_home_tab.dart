import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../data/services/app_order_store.dart';
import '../../shared/order_card.dart';
import '../../shared/order_details_view.dart';
import '../../shared/viewmodels/base_supplier_viewmodel.dart';
import '../../../../core/components/dwaar_elevated_card.dart';

class RestaurantHomeTab extends StatelessWidget {
  final String userName;

  const RestaurantHomeTab({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BaseSupplierViewModel>();
    final tracked = vm.trackedOrder;
    final active = vm.activeOrders;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context, vm),
          ),

          if (tracked != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 12),
                child: _buildTrackingTimeline(context, tracked),
              ),
            ),

          if (active.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    Text(
                      'طلباتي الحالية',
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
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${active.length}',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: OrderCard(
                      order: active[i],
                      mode: OrderCardMode.supplierActive,
                      onAction: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OrderDetailsView(
                            order: active[i],
                            onSupplierConfirmArrival: (available) {
                              final store = context.read<AppOrderStore>();
                              if (available) {
                                store.handleSupplierAvailable(active[i].id);
                              } else {
                                store.handleSupplierUnavailable(active[i].id);
                              }
                            },
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: (i * 100).ms).slideY(begin: 0.1, end: 0),
                  ),
                  childCount: active.length,
                ),
              ),
            ),
          ] else
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.store, size: 48, color: AppColors.primaryGreen),
                    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 24),
                    Text(
                      'لا توجد طلبات نشطة',
                      style: GoogleFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'أضف أول عرض للسوق الآن!',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: AppColors.mutedText,
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BaseSupplierViewModel vm) {
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
        left: 24,
        right: 24,
        bottom: 32,
      ),
      child: Column(
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surface.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(LucideIcons.store, color: AppColors.surface, size: 24),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Text(
                    'مرحباً، ${userName.split(' ').first}',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: AppColors.surface.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    'مورد تجاري',
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.surface,
                    ),
                  ),
                ],
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 32),
          DwaarElevatedCard(
            padding: const EdgeInsets.all(24),
            child: Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildImpactMetric(
                  icon: LucideIcons.medal,
                  label: 'نقاطي',
                  value: vm.totalPoints.toString(),
                  color: AppColors.accentAmber,
                ),
                Container(width: 1, height: 40, color: AppColors.borderSubtle),
                _buildImpactMetric(
                  icon: LucideIcons.scale,
                  label: 'إجمالي الوزن',
                  value: '0 كغ',
                  color: AppColors.primaryGreen,
                ),
                Container(width: 1, height: 40, color: AppColors.borderSubtle),
                _buildImpactMetric(
                  icon: LucideIcons.trees,
                  label: 'أشجار أُنقذت',
                  value: '0',
                  color: const Color(0xFF059669),
                ),
              ],
            ),
          ).animate().slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOutBack),
        ],
      ),
    );
  }

  Widget _buildImpactMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
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
          style: GoogleFonts.cairo(
            fontSize: 12,
            color: AppColors.mutedText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingTimeline(BuildContext context, Order order) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: DwaarElevatedCard(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OrderDetailsView(
              order: order,
              onSupplierConfirmArrival: (available) {
                final store = context.read<AppOrderStore>();
                if (available) {
                  store.handleSupplierAvailable(order.id);
                } else {
                  store.handleSupplierUnavailable(order.id);
                }
              },
            ),
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.statusInTransitBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(LucideIcons.truck, color: AppColors.statusInTransitText),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        'السائق في الطريق إليك',
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (order.eta != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.statusInTransitBg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            order.eta!,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.statusInTransitText,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.driverName} • ${order.driverVehicleModel ?? "مركبة"}',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.borderSubtle, size: 16),
          ],
        ),
      ),
    ).animate().slideX(begin: 0.1, end: 0, curve: Curves.easeOutQuart);
  }
}
