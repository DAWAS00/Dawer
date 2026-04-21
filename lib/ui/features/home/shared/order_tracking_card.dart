import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/order.dart';
import '../../../../l10n/l10n.dart';

class OrderTrackingCard extends StatelessWidget {
  final Order order;

  const OrderTrackingCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06402B).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMapPlaceholder(context),
          _buildStatusRow(context),
          _buildDivider(),
          _buildDriverRow(context),
          _buildDivider(),
          _buildRouteRow(),
          _buildDivider(),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  // ── Map Placeholder ──────────────────────────────────────────────────────────

  Widget _buildMapPlaceholder(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: Container(
        height: 150,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFD0EAD6), Color(0xFFE1F2E5)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Stack(
          children: [
            // Grid lines (map texture)
            CustomPaint(
              size: const Size(double.infinity, 150),
              painter: _MapGridPainter(),
            ),
            // Route line
            CustomPaint(
              size: const Size(double.infinity, 150),
              painter: _RoutePainter(),
            ),
            // Pickup pin
            Positioned(
              right: 50,
              top: 40,
              child: _MapPin(
                color: const Color(0xFF06402B),
                icon: Icons.radio_button_checked,
              ),
            ),
            // Dropoff pin
            Positioned(
              left: 50,
              bottom: 40,
              child: _MapPin(
                color: Colors.red.shade500,
                icon: Icons.location_on_rounded,
              ),
            ),
            // Truck icon (in motion position)
            Positioned(
              right: 110,
              top: 55,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF06402B),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF06402B).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            // Map label overlay
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.map_outlined,
                          size: 12, color: Color(0xFF06402B)),
                      const SizedBox(width: 5),
                      Text(
                        context.l10n.mapsComingSoon,
                        style: GoogleFonts.cairo(
                          fontSize: 10,
                          color: const Color(0xFF06402B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Status Row ───────────────────────────────────────────────────────────────

  Widget _buildStatusRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        children: [
          // ETA chip
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF06402B).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 13, color: Color(0xFF06402B)),
                const SizedBox(width: 5),
                Text(
                  order.eta ?? '--',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF06402B),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Pulse dot + status text
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.orderDriverOnWay,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              _PulseDot(),
            ],
          ),
        ],
      ),
    );
  }

  // ── Driver Row ───────────────────────────────────────────────────────────────

  Widget _buildDriverRow(BuildContext context) {
    final l10n = context.l10n;
    final name = order.driverName ?? l10n.orderDriverSection;
    final initials = name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join();
    final rating = order.driverRating ?? 5.0;
    final vehicle = order.driverVehicle ?? l10n.profileVehicle;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          // Phone / order number
          Text(
            '#${order.id}',
            style: GoogleFonts.dmSans(
              fontSize: 11,
              color: const Color(0xFF717973),
            ),
          ),
          const Spacer(),
          // Vehicle badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.statusPendingBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_shipping_rounded,
                    size: 12, color: Color(0xFF717973)),
                const SizedBox(width: 4),
                Text(
                  vehicle,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: cs.onSurface.withValues(alpha: 0.78),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Rating
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(width: 3),
              Icon(Icons.star_rounded,
                  size: 14, color: AppColors.accentAmber),
            ],
          ),
          const SizedBox(width: 10),
          // Name
          Text(
            name,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(width: 10),
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF06402B).withValues(alpha: 0.12),
            child: Text(
              initials,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF06402B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Route Row ────────────────────────────────────────────────────────────────

  Widget _buildRouteRow(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.radio_button_checked,
                  size: 14, color: const Color(0xFF06402B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.pickupAddress,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: cs.onSurface.withValues(alpha: 0.78),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6, top: 2, bottom: 2),
            child: Container(width: 1, height: 12, color: cs.onSurface.withValues(alpha: 0.15)),
          ),
          Row(
            children: [
              Icon(Icons.location_on_rounded,
                  size: 14, color: Colors.red.shade400),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.dropoffAddress,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: cs.onSurface.withValues(alpha: 0.78),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Action Buttons ───────────────────────────────────────────────────────────

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          // Chat button
          Expanded(
            child: _ActionBtn(
              label: context.l10n.orderChatButton,
              icon: Icons.chat_bubble_outline_rounded,
              color: const Color(0xFF06402B),
              onTap: () => _openChat(context),
            ),
          ),
          const SizedBox(width: 12),
          // WhatsApp button
          Expanded(
            child: _ActionBtn(
              label: context.l10n.orderWhatsAppButton,
              icon: Icons.phone_rounded,
              color: const Color(0xFF25D366),
              onTap: () => _openWhatsApp(context),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  Widget _buildDivider(ColorScheme cs) => Container(
        height: 1,
        color: cs.onSurface.withValues(alpha: 0.08),
        margin: const EdgeInsets.symmetric(horizontal: 16),
      );

  void _openChat(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.orderChatComingSoon,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF06402B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final phone = order.driverPhone;
    if (phone == null) return;
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final intl = cleaned.startsWith('0') ? '962${cleaned.substring(1)}' : cleaned;
    final uri = Uri.parse('https://wa.me/$intl?text=${Uri.encodeComponent('مرحباً، أنا في انتظار استلامي.')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.orderWhatsAppFailed,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final Color color;
  final IconData icon;

  const _MapPin({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 13),
    );
  }
}

class _PulseDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.green.shade500,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────────

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF06402B).withValues(alpha: 0.06)
      ..strokeWidth = 1;

    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_MapGridPainter old) => false;
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF06402B).withValues(alpha: 0.5)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final dashPaint = Paint()
      ..color = const Color(0xFF06402B).withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width - 50, 52)
      ..cubicTo(
        size.width - 100, 52,
        size.width - 130, size.height - 52,
        50,
        size.height - 52,
      );

    // Draw dashed path
    final metrics = path.computeMetrics().first;
    const dashLen = 8.0;
    const gapLen = 5.0;
    double distance = 0;
    bool drawing = true;
    while (distance < metrics.length) {
      final len = drawing ? dashLen : gapLen;
      if (drawing) {
        canvas.drawPath(
          metrics.extractPath(distance, distance + len),
          paint,
        );
      }
      distance += len;
      drawing = !drawing;
    }

    // Shadow under path
    canvas.drawPath(
      Path()
        ..moveTo(size.width - 50, 52)
        ..cubicTo(
          size.width - 100, 52,
          size.width - 130, size.height - 52,
          50,
          size.height - 52,
        ),
      dashPaint,
    );
  }

  @override
  bool shouldRepaint(_RoutePainter old) => false;
}
