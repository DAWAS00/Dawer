import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../l10n/l10n.dart';

class IdentityUploadCard extends StatelessWidget {
  final File? document;
  final String label;
  final String? error;
  final Future<void> Function(ImageSource) onPick;
  final VoidCallback onRemove;

  const IdentityUploadCard({
    super.key,
    required this.document,
    required this.label,
    required this.onPick,
    required this.onRemove,
    this.error,
  });

  void _showSourceSheet(BuildContext context) {
    final l10n = context.l10n;
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
                label: l10n.imagePickerCamera,
                onTap: () {
                  Navigator.pop(context);
                  onPick(ImageSource.camera);
                },
              ),
              _SheetTile(
                icon: Icons.photo_library_rounded,
                label: l10n.imagePickerGallery,
                onTap: () {
                  Navigator.pop(context);
                  onPick(ImageSource.gallery);
                },
              ),
              if (document != null)
                _SheetTile(
                  icon: Icons.delete_outline_rounded,
                  label: l10n.imagePickerRemoveImage,
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
    final hasError = error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF404943),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showSourceSheet(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: document != null ? 160 : 110,
            decoration: BoxDecoration(
              color: hasError
                  ? Colors.red.shade50
                  : const Color(0xFFF2F4F2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasError
                    ? Colors.red.shade400
                    : const Color(0xFF06402B).withValues(alpha: 0.25),
                width: 1.5,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            ),
            child: document == null
                ? _EmptyState(hasError: hasError)
                : _FilledState(document: document!, onRemove: onRemove),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            error!,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: Colors.red.shade600,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasError;
  const _EmptyState({required this.hasError});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF06402B).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.upload_file_rounded,
            size: 24,
            color: hasError ? Colors.red.shade400 : const Color(0xFF06402B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.signupUploadDocumentPrompt,
          style: GoogleFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: hasError ? Colors.red.shade600 : const Color(0xFF404943),
          ),
        ),
        Text(
          l10n.signupUploadDocumentSources,
          style: GoogleFonts.cairo(
            fontSize: 11,
            color: const Color(0xFF717973),
          ),
        ),
      ],
    );
  }
}

class _FilledState extends StatelessWidget {
  final File document;
  final VoidCallback onRemove;
  const _FilledState({required this.document, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            document,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF06402B).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    size: 12, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  l10n.signupDocumentUploaded,
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
