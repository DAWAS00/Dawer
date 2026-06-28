import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../data/services/proof_builder.dart';
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
  bool _submitting = false;
  String? _uploadError;
  final ImagePicker _picker = ImagePicker();
  final _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _weightController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  double? get _parsedWeight {
    final text = _weightController.text.trim();
    if (text.isEmpty) return null;
    final val = double.tryParse(text);
    if (val == null || val <= 0) return null;
    return val;
  }

  bool get _canComplete =>
      _proofImage != null &&
      _parsedWeight != null &&
      (widget.order.status == OrderStatus.arrivedAtDropoff ||
          widget.order.arrivedAtDropoffAt != null);

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
                  leading: const Icon(Icons.camera_alt_rounded,
                      color: AppColors.primaryGreen),
                  title: Text(context.l10n.orderPhotoCamera,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  onTap: () async {
                    Navigator.pop(context);
                    final picked = await _picker.pickImage(
                        source: ImageSource.camera, imageQuality: 80);
                    if (picked != null) setState(() => _proofImage = picked);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded,
                      color: AppColors.primaryGreen),
                  title: Text(context.l10n.orderPhotoGallery,
                      style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  onTap: () async {
                    Navigator.pop(context);
                    final picked = await _picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 80);
                    if (picked != null) setState(() => _proofImage = picked);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    final image = _proofImage;
    final weight = _parsedWeight;
    if (image == null || weight == null || _submitting) return;

    setState(() {
      _submitting = true;
      _uploadError = null;
    });

    try {
      // Build local proof (GPS + SHA256).
      final localProof =
          await ProofBuilder.build(imageFile: image, weightKg: weight);

      // Upload photo to Supabase Storage; fall back to local path on error.
      String photoUrl;
      try {
        photoUrl = await ProofBuilder.upload(
          imageFile: image,
          orderId: widget.order.id,
          proofType: 'dropoff',
        );
      } catch (_) {
        photoUrl = localProof.imagePath;
      }

      final finalProof = localProof.copyWith(imagePath: photoUrl);

      if (!mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            context.l10n.orderCompleteDialogTitle,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          content: Text(
            context.l10n.orderCompleteDialogMsg,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: AppColors.mutedText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                context.l10n.cancel,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: AppColors.mutedText,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                context.l10n.orderConfirmComplete,
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ],
        ),
      );

      if (!mounted) return;
      if (confirmed != true) {
        setState(() => _submitting = false);
        return;
      }

      final updatedOrder = widget.order.copyWith(
        status: OrderStatus.completed,
        completedAt: DateTime.now(),
        proofImagePath: photoUrl,
        paidAmount: widget.order.reward,
        proof: finalProof,
      );
      widget.onComplete(updatedOrder);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _uploadError = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.orderCompletionTitle,
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 12),

          // Weight input (TD2 specs: LTR, numberWithOptions, minHeight 48)
          Text(
            'وزن الشحنة عند التسليم (كغ)',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textMain,
            ),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: TextField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                  signed: false,
                ),
                textAlign: TextAlign.left,
                enabled: !_submitting,
                style: GoogleFonts.dmSans(fontSize: 15),
                decoration: InputDecoration(
                  hintText: '0.0',
                  hintStyle: GoogleFonts.dmSans(color: AppColors.mutedText),
                  suffixText: 'كغ',
                  suffixStyle: GoogleFonts.cairo(color: AppColors.mutedText),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.primaryGreen,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Photo upload
          GestureDetector(
            onTap: _submitting ? null : _pickImage,
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _proofImage != null
                      ? AppColors.primaryGreen
                      : AppColors.primaryGreen.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: _proofImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            _proofImage!.path.startsWith('http')
                                ? _proofImage!.path
                                : Uri.file(_proofImage!.path).toString(),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildPhotoPlaceholder(),
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
                              child: const Icon(Icons.edit_rounded,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildPhotoPlaceholder(),
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
                  color: AppColors.mutedText,
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

          if (!_canComplete && _proofImage != null && _parsedWeight != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'يجب أن تصل إلى موقع التسليم أولاً (ضمن 200 م)',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: Colors.red.shade800,
                ),
              ),
            ),
          if (_uploadError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.red.shade700, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _uploadError!,
                        style: GoogleFonts.cairo(
                          fontSize: 12,
                          color: Colors.red.shade800,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Complete button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting
                  ? null
                  : (_canComplete ? _submit : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: _uploadError != null
                    ? Colors.red
                    : (_canComplete
                        ? AppColors.primaryGreen
                        : AppColors.mutedText.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                minimumSize: const Size(double.infinity, 56),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _uploadError != null
                          ? 'إعادة المحاولة'
                          : context.l10n.orderFinishButton,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
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

  Widget _buildPhotoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.camera_alt_rounded,
          color: AppColors.mutedText,
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.orderProofPhotoHint,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.mutedText,
          ),
        ),
      ],
    );
  }
}
