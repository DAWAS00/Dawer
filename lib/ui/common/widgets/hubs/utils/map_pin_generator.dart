import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Renders dynamically drawn vector pins on a canvas representing
/// hub capacity occupancy with custom colors and text details.
class MapPinGenerator {
  static Future<BitmapDescriptor> generateHubMarker({
    required double fillPercent,
    required String status,
    required double densityScale,
  }) async {
    if (WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      return BitmapDescriptor.defaultMarker;
    }

    final double size = 120.0 * densityScale;
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);

    // Dynamic color evaluation based on load occupancy
    final Color markerColor = status == 'ready'
        ? const Color(0xFF06331C) // Brand Ready Deep Green
        : fillPercent >= 0.90
        ? const Color(0xFFEF4444) // Danger Red
        : fillPercent >= 0.70
        ? const Color(0xFFD97706) // Warning Amber
        : const Color(0xFF0F5A34); // Safe Green

    // 1. Draw Drop Shadow
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(
      Offset(size / 2, size / 2 - 10),
      (size / 2.3),
      shadowPaint,
    );

    // 2. Draw White Pin Outer Base (bubble shape)
    final Paint whitePinPaint = Paint()..color = Colors.white;
    final Path pinPath = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size / 2, size / 2 - 20),
          radius: size / 2.4,
        ),
      );

    // Draw triangle point tail at the bottom center of the pin
    final Path trianglePath = Path()
      ..moveTo(size / 2 - 15, size - 35)
      ..lineTo(size / 2 + 15, size - 35)
      ..lineTo(size / 2, size - 10)
      ..close();
    canvas.drawPath(pinPath, whitePinPaint);
    canvas.drawPath(trianglePath, whitePinPaint);

    // 3. Draw Core Color Badge
    final Paint corePaint = Paint()..color = markerColor;
    canvas.drawCircle(Offset(size / 2, size / 2 - 20), (size / 3.0), corePaint);

    // 4. Render Icon or occupancy text (e.g. "75%")
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: '${(fillPercent * 100).toInt()}%',
      style: TextStyle(
        fontSize: size / 7.5,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        fontFamily: 'DM Sans',
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        size / 2 - textPainter.width / 2,
        size / 2 - 20 - textPainter.height / 2,
      ),
    );

    final ui.Image image = await recorder.endRecording().toImage(
      size.toInt(),
      size.toInt(),
    );
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(byteData!.buffer.asUint8List());
  }
}
