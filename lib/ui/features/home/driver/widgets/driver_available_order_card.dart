import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order/order.dart';

class DriverAvailableOrderCard extends StatefulWidget {
  const DriverAvailableOrderCard({
    super.key,
    required this.order,
    required this.onAccept,
    this.onTap,
  });

  final Order order;
  final VoidCallback onAccept;
  final VoidCallback? onTap;

  @override
  State<DriverAvailableOrderCard> createState() => _DriverAvailableOrderCardState();
}

class _DriverAvailableOrderCardState extends State<DriverAvailableOrderCard> {
  bool _isAccepting = false;

  void _handleAccept() {
    setState(() => _isAccepting = true);
    // Give time for the animation to play before triggering the actual logic
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) widget.onAccept();
    });
  }

  @override
  Widget build(BuildContext context) {
    final (badgeLabel, badgeBg, badgeFg) = _resolveBadge(widget.order.status);
    final dateString = '${widget.order.createdAt.day}/${widget.order.createdAt.month}/${widget.order.createdAt.year}';

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: ID, Date, and Status Badge
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.package, size: 16, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${widget.order.id}',
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF191C1B),
                        ),
                      ),
                      Text(
                        dateString,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: const Color(0xFF717973),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      badgeLabel,
                      style: GoogleFonts.cairo(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: badgeFg,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Divider(height: 1, color: const Color(0xFFE6E9E7), thickness: 1),
            
            // Body: Route & Metrics
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildRouteLine(),
                  const SizedBox(height: 24),
                  
                  // Metrics Row
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAF8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetric(
                          icon: LucideIcons.coins,
                          label: 'العائد',
                          value: '${widget.order.reward.toStringAsFixed(1)} د.أ',
                          highlight: true,
                        ),
                        Container(width: 1, height: 24, color: const Color(0xFFDDE3DD)),
                        _buildMetric(
                          icon: LucideIcons.map,
                          label: 'المسافة',
                          value: widget.order.distanceKm != null ? '${widget.order.distanceKm!.toStringAsFixed(1)} كم' : '--',
                        ),
                        Container(width: 1, height: 24, color: const Color(0xFFDDE3DD)),
                        _buildMetric(
                          icon: LucideIcons.recycle,
                          label: 'النوع',
                          value: widget.order.wasteTypes.first.label,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Accept Action
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isAccepting ? null : _handleAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isAccepting ? const Color(0xFF4CAF50) : AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isAccepting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(LucideIcons.checkCircle2, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  'تم قبول الطلب',
                                  style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'اقبل الطلب',
                                  style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                const Icon(LucideIcons.arrowLeft, size: 20),
                              ],
                            ),
                    ).animate(target: _isAccepting ? 1 : 0)
                     .shimmer(duration: 400.ms, color: Colors.white24)
                     .scale(duration: 200.ms, begin: const Offset(1, 1), end: const Offset(1.02, 1.02), curve: Curves.easeOutBack)
                     .then()
                     .scale(duration: 200.ms, end: const Offset(1, 1)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate(target: _isAccepting ? 1 : 0)
       .fadeOut(duration: 300.ms, delay: 400.ms)
       .scale(end: const Offset(0.9, 0.9), duration: 300.ms, delay: 400.ms),
    );
  }

  Widget _buildRouteLine() {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        _buildNode(
          icon: LucideIcons.packageOpen,
          title: 'الاستلام',
          subtitle: widget.order.pickupAddress,
          color: AppColors.primaryGreen,
        ),
        Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            color: const Color(0xFFE6E9E7),
          ),
        ),
        _buildNode(
          icon: LucideIcons.building2,
          title: 'التسليم',
          subtitle: widget.order.dropoffAddress,
          color: const Color(0xFFD32F2F),
        ),
      ],
    );
  }

  Widget _buildNode({required IconData icon, required String title, required String subtitle, required Color color}) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF404943),
          ),
        ),
      ],
    );
  }

  Widget _buildMetric({required IconData icon, required String label, required String value, bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: const Color(0xFF717973)),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 11,
                color: const Color(0xFF717973),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: highlight 
            ? GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryGreen)
            : GoogleFonts.cairo(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF191C1B)),
        ),
      ],
    );
  }

  (String, Color, Color) _resolveBadge(OrderStatus status) =>
      switch (status) {
        OrderStatus.pending => ('طلب جديد', const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
        _ => (status.label, const Color(0xFFE8F5E9), AppColors.primaryGreen),
      };
}
