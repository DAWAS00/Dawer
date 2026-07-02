import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MarketItemPhotoGallery extends StatelessWidget {
  final List<String> images;

  const MarketItemPhotoGallery({super.key, required this.images});

  Widget _buildImage(String path) {
    const errorWidget = SizedBox(
      width: 120,
      height: 96,
      child: ColoredBox(
        color: Color(0xFFE5E7EB),
        child: Icon(
          Icons.image_not_supported_rounded,
          color: Color(0xFFD1D5DB),
          size: 28,
        ),
      ),
    );

    final isNetwork = path.startsWith('http://') || path.startsWith('https://');

    if (isNetwork) {
      return Image.network(
        path,
        width: 120,
        height: 96,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) => progress == null
            ? child
            : const SizedBox(
                width: 120,
                height: 96,
                child: ColoredBox(
                  color: Color(0xFFE5E7EB),
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF06402B),
                    ),
                  ),
                ),
              ),
        errorBuilder: (_, __, ___) => errorWidget,
      );
    }

    final file = File(path);
    if (!file.existsSync()) return errorWidget;

    return Image.file(
      file,
      width: 120,
      height: 96,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => errorWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            'صور المنتج',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819),
            ),
          ),
        ),
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            reverse: true,
            itemCount: images.length,
            separatorBuilder: (_, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _buildImage(images[index]),
            ),
          ),
        ),
      ],
    );
  }
}
