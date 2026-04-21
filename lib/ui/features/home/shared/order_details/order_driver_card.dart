import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order.dart';
import '../../../../../l10n/l10n.dart';

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

  Future<void> _openWhatsApp(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri url = Uri.parse('https://wa.me/$cleanPhone');
    if (!await launchUrl(url)) {
      debugPrint('Could not launch $url');
    }
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
    
    final vehicleModel = order.driverVehicleModel;
    final vehicleColor = order.driverVehicleColor;
    final licensePlate = order.driverLicensePlate;
    
    final hasVehicleInfo = vehicleModel != null || licensePlate != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.orderDriverSection,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF002819),
                ),
              ),
              if (order.eta != null && (order.status == OrderStatus.accepted || order.status == OrderStatus.inTransit))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06402B).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF06402B)),
                      const SizedBox(width: 4),
                      Text(
                        l10n.orderDriverArrives(order.eta!),
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF06402B),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF06402B).withValues(alpha: 0.12),
                child: Text(
                  initials,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF06402B),
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
                        Icon(Icons.star_rounded, size: 15, color: AppColors.accentAmber),
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
                IconButton(
                  onPressed: () => _openWhatsApp(order.driverPhone!),
                  icon: Image.asset('assets/images/whatsapp_icon.png', width: 28, height: 28, errorBuilder: (c, e, s) => const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF25D366), size: 28)),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366).withValues(alpha: 0.1),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _makeCall(order.driverPhone!),
                  icon: const Icon(Icons.phone_rounded, color: Color(0xFF06402B), size: 22),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF06402B).withValues(alpha: 0.1),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ]
            ],
          ),
          if (hasVehicleInfo) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFE6E9E7)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.profileVehicle,
                        style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF717973)),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.directions_car_rounded, size: 14, color: Color(0xFF404943)),
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
                  Container(width: 1, height: 30, color: const Color(0xFFE6E9E7)),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.profileLicensePlate,
                            style: GoogleFonts.cairo(fontSize: 11, color: const Color(0xFF717973)),
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
