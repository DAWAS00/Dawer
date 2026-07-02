import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

/// A localized bottom sheet for picking an [ImageSource] (camera or gallery),
/// with an optional "remove photo" action.
///
/// Replaces the previously duplicated source sheets in `license_scan_section`,
/// `vehicle_registration_scan_section`, and `photo_picker_card`. All labels are
/// passed in already-localized by the caller — this widget stays free of any
/// hardcoded text.
Future<ImageSource?> showPhotoSourceSheet({
  required BuildContext context,
  required String cameraLabel,
  required String galleryLabel,
  String? removeLabel,
  VoidCallback? onRemove,
}) {
  return showModalBottomSheet<ImageSource>(
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
              label: cameraLabel,
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            _SheetTile(
              icon: Icons.photo_library_rounded,
              label: galleryLabel,
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            if (removeLabel != null && onRemove != null)
              _SheetTile(
                icon: Icons.delete_outline_rounded,
                label: removeLabel,
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
