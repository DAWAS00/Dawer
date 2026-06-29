import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order/order.dart';
import '../../../../../data/services/proof_builder.dart';
import '../../../../../l10n/l10n.dart';

enum _ProofState { initial, hasWeight, hasPhoto, hasBoth, uploading, error, success }

class PickupProofView extends StatefulWidget {
  final Order order;
  /// Called with the finalized [OrderProof] once upload succeeds.
  /// Returns an error string on failure, or null on success.
  final Future<String?> Function(OrderProof proof) onConfirm;

  const PickupProofView({
    super.key,
    required this.order,
    required this.onConfirm,
  });

  @override
  State<PickupProofView> createState() => _PickupProofViewState();
}

class _PickupProofViewState extends State<PickupProofView>
    with SingleTickerProviderStateMixin {
  final _weightController = TextEditingController();
  XFile? _image;
  _ProofState _state = _ProofState.initial;
  String? _errorMessage;
  late AnimationController _successAnim;
  late Animation<double> _successScale;

  @override
  void initState() {
    super.initState();
    _successAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _successScale = CurvedAnimation(parent: _successAnim, curve: Curves.elasticOut);
    _weightController.addListener(_onInputChanged);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _successAnim.dispose();
    super.dispose();
  }

  void _onInputChanged() {
    final hasWeight = _parsedWeight != null;
    final hasPhoto = _image != null;
    setState(() {
      if (_state == _ProofState.uploading ||
          _state == _ProofState.success ||
          _state == _ProofState.error) { return; }
      if (hasWeight && hasPhoto) {
        _state = _ProofState.hasBoth;
      } else if (hasWeight) {
        _state = _ProofState.hasWeight;
      } else if (hasPhoto) {
        _state = _ProofState.hasPhoto;
      } else {
        _state = _ProofState.initial;
      }
    });
  }

  double? get _parsedWeight {
    final text = _weightController.text.trim();
    if (text.isEmpty) return null;
    final val = double.tryParse(text);
    if (val == null || val <= 0) return null;
    return val;
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (file == null) return;
    setState(() {
      _image = file;
      _onInputChanged();
    });
  }

  Future<void> _submit() async {
    final weight = _parsedWeight;
    final image = _image;
    if (weight == null || image == null) return;

    setState(() {
      _state = _ProofState.uploading;
      _errorMessage = null;
    });

    try {
      // Upload photo; get public URL.
      final url = await ProofBuilder.upload(
        imageFile: image,
        orderId: widget.order.id,
        proofType: 'pickup',
      );

      // Build proof with the remote URL as imagePath.
      final urlFile = XFile(url);
      final proof = await ProofBuilder.build(imageFile: urlFile, weightKg: weight);
      // Replace local path with the uploaded URL.
      final finalProof = OrderProof(
        imagePath: url,
        capturedAt: proof.capturedAt,
        lat: proof.lat,
        lng: proof.lng,
        checksum: proof.checksum,
        weightKg: proof.weightKg,
      );

      final error = await widget.onConfirm(finalProof);
      if (!mounted) return;

      if (error != null) {
        setState(() {
          _state = _ProofState.error;
          _errorMessage = error;
        });
        return;
      }

      // Success path: animate then pop.
      setState(() => _state = _ProofState.success);
      await _successAnim.forward();
      if (!mounted) return;
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _ProofState.error;
        _errorMessage = e.toString();
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_state == _ProofState.uploading) return false;
    if (_state == _ProofState.success) return true;
    final hasData = _image != null || _weightController.text.isNotEmpty;
    if (!hasData) return true;

    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.proofCancelTitle,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          l10n.proofCancelBody,
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.proofBack, style: GoogleFonts.cairo()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.cancel, style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final canLeave = await _onWillPop();
        if (canLeave && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          title: Text(
            context.l10n.proofTitle,
            style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: _state == _ProofState.success
              ? _buildSuccess()
              : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildWeightField(),
          const SizedBox(height: 24),
          _buildPhotoSection(),
          const SizedBox(height: 32),
          if (_state == _ProofState.error && _errorMessage != null)
            _buildErrorBanner(),
          if (_state == _ProofState.error && _errorMessage != null)
            const SizedBox(height: 16),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildWeightField() {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          l10n.proofShipmentWeight,
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 8),
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
              enabled: _state != _ProofState.uploading &&
                  _state != _ProofState.success,
              style: GoogleFonts.dmSans(fontSize: 16),
              decoration: InputDecoration(
                hintText: '0.0',
                hintStyle: GoogleFonts.dmSans(color: AppColors.mutedText),
                suffixText: l10n.unitKg,
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
      ],
    );
  }

  Widget _buildPhotoSection() {
    return GestureDetector(
      onTap: _state == _ProofState.uploading ? null : _pickPhoto,
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _image != null
                ? AppColors.primaryGreen
                : AppColors.mutedText.withValues(alpha: 0.4),
            width: _image != null ? 2 : 1.5,
          ),
        ),
        child: _image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      _image!.path.startsWith('http')
                          ? _image!.path
                          : Uri.file(_image!.path).toString(),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildPhotoPlaceholder(captured: true),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          context.l10n.proofChangePhoto,
                          style: GoogleFonts.cairo(
                              fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : _buildPhotoPlaceholder(),
      ),
    );
  }

  Widget _buildPhotoPlaceholder({bool captured = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          captured ? Icons.check_circle_outline : Icons.camera_alt_rounded,
          size: 48,
          color: captured ? AppColors.primaryGreen : AppColors.mutedText,
        ),
        const SizedBox(height: 12),
        Text(
          captured ? context.l10n.proofPhotoCaptured : context.l10n.proofCapturePhoto,
          style: GoogleFonts.cairo(
            fontSize: 15,
            color: captured ? AppColors.primaryGreen : AppColors.mutedText,
            fontWeight: captured ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: GoogleFonts.cairo(fontSize: 13, color: Colors.red.shade800),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit = _state == _ProofState.hasBoth ||
        (_state == _ProofState.error &&
            _parsedWeight != null &&
            _image != null);
    final isLoading = _state == _ProofState.uploading;
    final isError = _state == _ProofState.error;

    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: canSubmit ? _submit : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isError ? Colors.red : AppColors.primaryGreen,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.mutedText.withValues(alpha: 0.3),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                isError ? context.l10n.proofRetry : context.l10n.proofConfirmPickup,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: ScaleTransition(
        scale: _successScale,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 64,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.proofSuccessTitle,
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.proofSuccessBody,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: AppColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
