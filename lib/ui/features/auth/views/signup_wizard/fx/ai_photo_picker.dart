import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AiPhotoPicker extends StatelessWidget {
  final File? image;
  final String label;
  final bool isVerified;
  final bool isBusiness;
  final Function(File) onPick;
  final VoidCallback onRemove;

  const AiPhotoPicker({
    super.key,
    required this.image,
    required this.label,
    required this.isVerified,
    required this.onPick,
    required this.onRemove,
    this.isBusiness = false,
  });

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: source, imageQuality: 80);
    if (xFile != null) {
      onPick(File(xFile.path));
    }
  }

  void _showSourceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: Text('الكاميرا', style: GoogleFonts.cairo()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: Text('معرض الصور', style: GoogleFonts.cairo()),
              onTap: () {
                Navigator.pop(context);
                _pickImage(context, ImageSource.gallery);
              },
            ),
            if (image != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                title: Text('إزالة الصورة', style: GoogleFonts.cairo(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  onRemove();
                },
              ),
          ],
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
            // Main Container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: isBusiness ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: isBusiness ? BorderRadius.circular(24) : null,
                color: const Color(0xFFF5F5F5),
                border: Border.all(
                  color: isVerified ? const Color(0xFF2E7D32) : const Color(0xFFE0E0E0),
                  width: 2,
                ),
                image: image != null
                    ? DecorationImage(image: FileImage(image!), fit: BoxFit.cover)
                    : null,
              ),
              child: image == null
                  ? Icon(isBusiness ? Icons.business_rounded : Icons.person_rounded,
                      size: 40, color: const Color(0xFFBDBDBD))
                  : null,
            ),
            
            // Camera Badge
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
              ),
            ),

            // AI Verified Badge
            if (image != null && isVerified)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 10, color: Color(0xFF4ADE80)),
                      const SizedBox(width: 4),
                      Text(
                        'AI LIVENESS',
                        style: GoogleFonts.dmSans(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                 .shimmer(duration: 2000.ms, color: Colors.white24)
                 .scale(duration: 1000.ms, begin: const Offset(1, 1), end: const Offset(1.05, 1.05)),
              ),
          ],
        ),
      ),
    );
  }
}
