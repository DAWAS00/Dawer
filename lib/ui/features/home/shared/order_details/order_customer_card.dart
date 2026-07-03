import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order/order.dart';
import '../../../chat/views/chat_view.dart';
import '../../../../core/components/dwaar_detail_card.dart';

class OrderCustomerCard extends StatelessWidget {
  const OrderCustomerCard({super.key, required this.order});

  final Order order;

  Future<void> _call(BuildContext context) async {
    final phone = order.supplierPhone;
    if (phone == null) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _openChat(BuildContext context) {
    ChatView.push(context, orderId: order.id, order: order);
  }

  Future<void> _navigate(BuildContext context) async {
    final lat = order.pickupLat;
    final lng = order.pickupLng;
    final uri = lat != null && lng != null
        ? Uri.parse(
            'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
          )
        : Uri.parse(
            'https://maps.google.com/?q=${Uri.encodeComponent(order.pickupAddress)}',
          );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = order.supplierName;
    final hasPhone = order.supplierPhone != null;

    if (name == null && !hasPhone) return const SizedBox.shrink();

    return DwaarDetailCard(
      elevation: DwaarCardElevation.highlighted,
      accentColor: AppColors.primaryGreen,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // ── Header row ──
          Row(
            children: [
              // Contact action buttons
              if (hasPhone) ...[
                _ContactChip(
                  icon: LucideIcons.phone,
                  label: 'اتصال',
                  color: AppColors.primaryGreen,
                  onTap: () => _call(context),
                ),
                const SizedBox(width: 8),
              ],
              _ContactChip(
                icon: LucideIcons.messageSquare,
                label: 'دردشة',
                color: const Color(0xFF06402B),
                onTap: () => _openChat(context),
              ),
              const SizedBox(width: 8),
              _ContactChip(
                icon: LucideIcons.navigation,
                label: 'ملاحة',
                color: const Color(0xFF1565C0),
                onTap: () => _navigate(context),
              ),
              const Spacer(),
              // Customer name + avatar
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'العميل',
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: AppColors.mutedText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (name != null)
                    Text(
                      name,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF002819),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.user,
                  size: 20,
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),

          // ── Phone number ──
          if (hasPhone) ...[
            const DwaarDetailDivider(verticalPadding: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  order.supplierPhone!,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF404943),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  LucideIcons.phone,
                  size: 14,
                  color: AppColors.mutedText,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactChip extends StatelessWidget {
  const _ContactChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
