import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

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

  void _showSourceSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(9999),
                ),
              ),
              const SizedBox(height: 16),
              _SheetTile(
                icon: Icons.camera_alt_rounded,
                label: 'الكاميرا',
                onTap: () {
                  Navigator.pop(context);
                  onPick(ImageSource.camera);
                },
              ),
              _SheetTile(
                icon: Icons.photo_library_rounded,
                label: 'معرض الصور',
                onTap: () {
                  Navigator.pop(context);
                  onPick(ImageSource.gallery);
                },
              ),
              if (image != null)
                _SheetTile(
                  icon: Icons.delete_outline_rounded,
                  label: 'حذف الصورة',
                  color: Colors.red.shade600,
                  onTap: () {
                    Navigator.pop(context);
                    onRemove();
                  },
                ),
            ],
          ),
        ),
      ),
    );
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

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF191C1B);
    return ListTile(
      leading: Icon(icon, color: c),
      title: Text(
        label,
        style: GoogleFonts.cairo(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: c,
        ),
      ),
      onTap: onTap,
    );
  }
}
