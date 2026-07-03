import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../l10n/l10n.dart';
import '../../../chat/views/chat_view.dart';
import '../../../../../ui/core/components/dwaar_detail_card.dart';

class OrderDriverCard extends StatelessWidget {
  final Order order;

  const OrderDriverCard({super.key, required this.order});

  Future<void> _makeCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri url = Uri.parse('tel:$cleanPhone');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
  }

  void _openChat(BuildContext context) {
    ChatView.push(context, orderId: order.id, order: order);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = order.driverName!;
    final initials = name
        .trim()
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join();
    final rating = order.driverRating ?? 5.0;

    final vehicleType = order.driverVehicle;
    final vehicleModel = order.driverVehicleModel;
    final vehicleColor = order.driverVehicleColor;
    final licensePlate = order.driverLicensePlate;

    final hasVehicleInfo =
        vehicleType != null || vehicleModel != null || licensePlate != null;

    // ETA trailing widget
    Widget? etaTrailing;
    if (order.eta != null &&
        (order.status == OrderStatus.accepted ||
            order.status == OrderStatus.inTransit)) {
      etaTrailing = DwaarDetailChip(
        label: l10n.orderDriverArrives(order.eta!),
        icon: Icons.access_time_rounded,
        color: AppColors.primaryGreen,
      );
    }

    return DwaarDetailCard(
      elevation: DwaarCardElevation.highlighted,
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      animationIndex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DwaarDetailHeader(
            icon: LucideIcons.userCheck,
            title: l10n.orderDriverSection,
            trailing: etaTrailing,
            iconColor: AppColors.primaryGreen,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Avatar with gradient ring
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.ctaGradientStart,
                      AppColors.headerGradientEnd,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: CircleAvatar(
                    radius: 33,
                    backgroundColor:
                        AppColors.primaryGreen.withValues(alpha: 0.08),
                    child: Text(
                      initials,
                      style: GoogleFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF002819),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 15,
                          color: AppColors.accentAmber,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          rating.toStringAsFixed(1),
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF002819),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (order.driverPhone != null) ...[
                _ActionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  onPressed: () => _openChat(context),
                ),
                const SizedBox(width: 8),
                _ActionButton(
                  icon: Icons.phone_rounded,
                  onPressed: () => _makeCall(order.driverPhone!),
                ),
              ],
            ],
          ),
          if (hasVehicleInfo) ...[
            const DwaarDetailDivider(verticalPadding: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.profileVehicle,
                        style: GoogleFonts.cairo(
                          fontSize: 11,
                          color: AppColors.mutedText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.directions_car_rounded,
                            size: 14,
                            color: Color(0xFF404943),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${vehicleModel ?? l10n.marketItemUnknown} ${vehicleColor != null ? '($vehicleColor)' : ''}',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF002819),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (licensePlate != null) ...[
                  Container(
                    width: 1,
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.borderSubtle.withValues(alpha: 0),
                          AppColors.borderSubtle,
                          AppColors.borderSubtle.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.profileLicensePlate,
                            style: GoogleFonts.cairo(
                              fontSize: 11,
                              color: AppColors.mutedText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            licensePlate,
                            textDirection: TextDirection.ltr,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF002819),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen.withValues(alpha: 0.08),
            AppColors.primaryGreen.withValues(alpha: 0.14),
          ],
        ),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.1),
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          color: AppColors.primaryGreen,
          size: 22,
        ),
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
      ),
    );
  }
}
