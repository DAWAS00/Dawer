import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/theme/app_tokens.dart';
import '../../../../../l10n/l10n.dart';

class ImagePickerGrid extends StatelessWidget {
  final List<String> imagePaths;
  final ValueChanged<String> onAdd;
  final ValueChanged<int> onRemove;
  final int maxImages;
  final int crossAxisCount;
  final double? tileHeight;
  final ValueChanged<String>? onAnalyze;

  const ImagePickerGrid({
    super.key,
    required this.imagePaths,
    required this.onAdd,
    required this.onRemove,
    this.maxImages = 5,
    this.crossAxisCount = 3,
    this.tileHeight,
    this.onAnalyze,
  });

  Future<void> _pickImage(BuildContext context) async {
    final dt = context.dt;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: dt.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final ctxDt = ctx.dt;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ctxDt.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  ctx.l10n.imagePickerSourceTitle,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ctxDt.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF06402B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Color(0xFF06402B),
                    ),
                  ),
                  title: Text(
                    ctx.l10n.imagePickerCamera,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      color: ctxDt.onSurface,
                    ),
                  ),
                  onTap: () => Navigator.pop(ctx, ImageSource.camera),
                ),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF06402B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: Color(0xFF06402B),
                    ),
                  ),
                  title: Text(
                    ctx.l10n.imagePickerGallery,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      color: ctxDt.onSurface,
                    ),
                  ),
                  onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 80);
    if (pickedFile != null) {
      onAdd(pickedFile.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showAddButton = imagePaths.length < maxImages;
    final itemCount = imagePaths.length + (showAddButton ? 1 : 0);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: tileHeight,
        childAspectRatio: tileHeight == null
            ? 1
            : (MediaQuery.of(context).size.width / crossAxisCount) /
                  tileHeight!,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == imagePaths.length && showAddButton) {
          return _AddTile(onTap: () => _pickImage(context));
        }
        return _ImageTile(
          path: imagePaths[index],
          onRemove: () => onRemove(index),
          onAnalyze: onAnalyze,
        );
      },
    );
  }
}

class _AddTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dt = context.dt;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: dt.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF06402B).withValues(alpha: 0.3),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_a_photo_rounded,
              color: Color(0xFF06402B),
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              context.l10n.imagePickerAddPhoto,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF06402B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final String path;
  final VoidCallback onRemove;
  final ValueChanged<String>? onAnalyze;

  const _ImageTile({
    required this.path,
    required this.onRemove,
    this.onAnalyze,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            File(path),
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          left: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
        if (onAnalyze != null)
          Positioned(
            bottom: 4,
            right: 4,
            child: GestureDetector(
              onTap: () => onAnalyze!(path),
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFF06402B),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
