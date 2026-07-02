import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../l10n/l10n.dart';
import 'photo_source_picker.dart';

class PhotoPickerCard extends StatelessWidget {
  final File? image;
  final String label;
  final bool isBusiness;
  final Future<void> Function(ImageSource) onPick;
  final VoidCallback onRemove;

  const PhotoPickerCard({
    super.key,
    required this.image,
    required this.label,
    required this.onPick,
    required this.onRemove,
    this.isBusiness = false,
  });

  Future<void> _showSourceSheet(BuildContext context) async {
    final l10n = context.l10n;
    final source = await showPhotoSourceSheet(
      context: context,
      cameraLabel: l10n.imagePickerCamera,
      galleryLabel: l10n.imagePickerGallery,
      removeLabel: image != null ? l10n.imagePickerRemoveImage : null,
      onRemove: image != null ? onRemove : null,
    );
    if (source != null) await onPick(source);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => _showSourceSheet(context),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: isBusiness ? 100 : 90,
              height: isBusiness ? 100 : 90,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                shape: isBusiness ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: isBusiness ? BorderRadius.circular(20) : null,
                color: const Color(0xFFE6E9E7),
                border: Border.all(
                  color: const Color(0xFF06402B).withValues(alpha: 0.15),
                  width: 2,
                ),
                image: image != null
                    ? DecorationImage(
                        image: FileImage(image!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: image == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isBusiness
                              ? Icons.business_rounded
                              : Icons.person_rounded,
                          size: 32,
                          color: const Color(0xFF717973),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            fontSize: 9,
                            color: const Color(0xFF717973),
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
            if (image != null)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06402B),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          size: 10, color: Color(0xFF4ADE80)),
                      const SizedBox(width: 4),
                      Text(
                        'AI SECURED',
                        style: GoogleFonts.dmSans(
                          fontSize: 7,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Positioned(
              bottom: -4,
              left: -4,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF06402B),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
