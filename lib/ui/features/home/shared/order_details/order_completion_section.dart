import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order.dart';
import '../../../../../data/services/location_service.dart';
import '../../../../../l10n/l10n.dart';

class OrderCompletionSection extends StatefulWidget {
  final Order order;
  final ValueChanged<Order> onComplete;

  const OrderCompletionSection({
    super.key,
    required this.order,
    required this.onComplete,
  });

  @override
  State<OrderCompletionSection> createState() => _OrderCompletionSectionState();
}

class _OrderCompletionSectionState extends State<OrderCompletionSection> {
  XFile? _proofImage;
  OrderProof? _proof;
  bool _capturingProof = false;
  final ImagePicker _picker = ImagePicker();
  final LocationService _locationService = LocationService();

  bool get _canComplete =>
      _proof != null &&
      (widget.order.status == OrderStatus.arrivedAtDropoff ||
          widget.order.arrivedAtDropoffAt != null);

  Future<void> _buildProof(XFile image) async {
    setState(() => _capturingProof = true);
    try {
      final pos = await _locationService.getCurrentLocation();
      final bytes = await File(image.path).readAsBytes();
      final checksum = sha256.convert(bytes).toString();
      setState(() {
        _proofImage = image;
        _proof = OrderProof(
          imagePath: image.path,
          capturedAt: DateTime.now(),
          lat: pos?.lat ?? 0.0,
          lng: pos?.lng ?? 0.0,
          checksum: checksum,
        );
      });
    } finally {
      setState(() => _capturingProof = false);
    }
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF06402B)),
                  title: Text(context.l10n.orderPhotoCamera, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  onTap: () async {
                    Navigator.pop(context);
                    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                    if (picked != null) await _buildProof(picked);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF06402B)),
                  title: Text(context.l10n.orderPhotoGallery, style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  onTap: () async {
                    Navigator.pop(context);
                    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                    if (picked != null) await _buildProof(picked);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          context.l10n.orderCompleteDialogTitle,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF002819),
          ),
        ),
        content: Text(
          context.l10n.orderCompleteDialogMsg,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(
            fontSize: 14,
            color: const Color(0xFF404943),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              context.l10n.cancel,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF717973),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final updatedOrder = widget.order.copyWith(
                status: OrderStatus.completed,
                completedAt: DateTime.now(),
                proofImagePath: _proof?.imagePath ?? _proofImage?.path,
                paidAmount: widget.order.reward,
                proof: _proof,
              );
              widget.onComplete(updatedOrder);
            },
            child: Text(
              context.l10n.orderConfirmComplete,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF06402B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF06402B).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.orderCompletionTitle,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF002819),
            ),
          ),
          const SizedBox(height: 12),
          
          // Image Upload
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _proofImage != null ? const Color(0xFF06402B) : const Color(0xFFD0EAD6),
                  width: 2,
                ),
              ),
              child: _proofImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            File(_proofImage!.path),
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit_rounded, color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.camera_alt_rounded,
                          color: Color(0xFF717973),
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.l10n.orderProofPhotoHint,
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF717973),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Cash details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.orderAmountLabel,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  color: const Color(0xFF404943),
                ),
              ),
              Row(
                children: [
                  Text(
                    widget.order.reward.toStringAsFixed(1),
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.statusActiveText,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.l10n.orderCurrencyJD,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.statusActiveText,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          if (!_canComplete && _proof != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'يجب أن تصل إلى موقع التسليم أولاً (ضمن 200 م)',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: const Color(0xFF991B1B),
                ),
              ),
            ),
          // Complete Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _capturingProof
                  ? null
                  : (_canComplete ? _showCompletionDialog : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: _canComplete
                    ? const Color(0xFF06402B)
                    : const Color(0xFFB0B8B4),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _capturingProof
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      context.l10n.orderFinishButton,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
