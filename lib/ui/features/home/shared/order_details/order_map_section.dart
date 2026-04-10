import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OrderMapSection extends StatelessWidget {
  final bool hasDriver;

  const OrderMapSection({super.key, required this.hasDriver});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Container(
        height: 240,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFD0EAD6), Color(0xFFE1F2E5)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Stack(
          children: [
            CustomPaint(
              size: const Size(double.infinity, 240),
              painter: _MapGridPainter(),
            ),
            CustomPaint(
              size: const Size(double.infinity, 240),
              painter: _RoutePainter(),
            ),
            Positioned(
              right: 60,
              top: 55,
              child: _MapPin(
                color: const Color(0xFF06402B),
                icon: Icons.radio_button_checked,
                label: 'نقطة الاستلام',
              ),
            ),
            Positioned(
              left: 60,
              bottom: 55,
              child: _MapPin(
                color: Colors.red.shade500,
                icon: Icons.location_on_rounded,
                label: 'نقطة التسليم',
              ),
            ),
            if (hasDriver)
              Positioned(
                right: 130,
                top: 90,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF06402B),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF06402B).withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_shipping_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.map_outlined,
                          size: 14, color: Color(0xFF06402B)),
                      const SizedBox(width: 6),
                      Text(
                        'سيتم دمج الخريطة التفاعلية قريباً',
                        style: GoogleFonts.cairo(
                          fontSize: 11,
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
}

// ── Map Pin ───────────────────────────────────────────────────────────────────

class _MapPin extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;

  const _MapPin({
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF002819),
            ),
          ),
        ),
      ],
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
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width - 60, 71)
      ..cubicTo(
        size.width - 120, 71,
        size.width - 160, size.height - 71,
        60,
        size.height - 71,
      );

    final metrics = path.computeMetrics().first;
    const dashLen = 10.0;
    const gapLen = 6.0;
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
  }

  @override
  bool shouldRepaint(_RoutePainter old) => false;
}
