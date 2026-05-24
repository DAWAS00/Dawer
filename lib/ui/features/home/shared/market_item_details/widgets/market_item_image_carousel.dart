import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../data/models/order.dart';

class MarketItemImageCarousel extends StatefulWidget {
  final List<String> images;
  final List<WasteType> wasteTypes;

  const MarketItemImageCarousel({
    super.key,
    required this.images,
    required this.wasteTypes,
  });

  @override
  State<MarketItemImageCarousel> createState() => _MarketItemImageCarouselState();
}

class _MarketItemImageCarouselState extends State<MarketItemImageCarousel> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildImage(String path) {
    final isNetwork = path.startsWith('http://') || path.startsWith('https://');
    final placeholder = Container(
      color: const Color(0xFF14401F),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white54, strokeWidth: 2),
      ),
    );
    final errorWidget = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF14401F), Color(0xFF1E6B35)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
    );

    if (isNetwork) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : placeholder,
        errorBuilder: (_, __, ___) => errorWidget,
      );
    }

    final file = File(path);
    if (!file.existsSync()) return errorWidget;

    return Image.file(
      file,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => errorWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _controller,
          onPageChanged: (p) => setState(() => _currentPage = p),
          itemCount: widget.images.length,
          itemBuilder: (context, index) =>
              _buildImage(widget.images[index]),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withValues(alpha: 0.65), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 48,
          right: 16,
          child: Wrap(
            spacing: 6,
            children: widget.wasteTypes
                .map(
                  (t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: Text(
                      t.label,
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        if (widget.images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPage == i ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == i ? Colors.white : Colors.white.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          top: 60,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_currentPage + 1}/${widget.images.length}',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.photo_library_rounded, size: 13, color: Colors.white70),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class MarketItemGradientPlaceholder extends StatelessWidget {
  final WasteType wasteType;

  const MarketItemGradientPlaceholder({super.key, required this.wasteType});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF14401F), Color(0xFF1E6B35)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 40),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(_iconFor(wasteType), size: 36, color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text(
              wasteType.label,
              style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(WasteType type) => switch (type) {
        WasteType.paper => Icons.newspaper_rounded,
        WasteType.plastic => Icons.local_drink_rounded,
        WasteType.metal => Icons.hardware_rounded,
        WasteType.glass => Icons.wine_bar_rounded,
        WasteType.electronics => Icons.devices_rounded,
        WasteType.organic => Icons.eco_rounded,
        WasteType.textile => Icons.checkroom_rounded,
        WasteType.wood => Icons.park_rounded,
        WasteType.rubber => Icons.circle_rounded,
        WasteType.oil => Icons.water_drop_rounded,
        WasteType.chemicals => Icons.science_rounded,
        WasteType.batteries => Icons.battery_alert_rounded,
        WasteType.furniture => Icons.chair_rounded,
        WasteType.tires => Icons.tire_repair_rounded,
        WasteType.construction => Icons.construction_rounded,
        WasteType.copperAluminium => Icons.bolt_rounded,
      };
}
