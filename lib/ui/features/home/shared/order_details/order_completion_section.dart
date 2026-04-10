import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../data/models/order.dart';

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
  final ImagePicker _picker = ImagePicker();

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
                  title: Text('التقاط صورة', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  onTap: () async {
                    Navigator.pop(context);
                    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                    if (picked != null) setState(() => _proofImage = picked);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF06402B)),
                  title: Text('اختيار من المعرض', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                  onTap: () async {
                    Navigator.pop(context);
                    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
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

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'إتمام الطلب',
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF002819),
          ),
        ),
        content: Text(
          'هل أنت متأكد من تسليم الطلب واستلام المبلغ؟\nعند إتمام الطلب، ستتمكن من استقبال طلبات جديدة.',
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
              'إلغاء',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF717973),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              final updatedOrder = Order(
                id: widget.order.id,
                type: widget.order.type,
                wasteTypes: widget.order.wasteTypes,
                pickupAddress: widget.order.pickupAddress,
                dropoffAddress: widget.order.dropoffAddress,
                status: OrderStatus.completed,
                reward: widget.order.reward,
                createdAt: widget.order.createdAt,
                acceptedAt: widget.order.acceptedAt,
                driverName: widget.order.driverName,
                driverPhone: widget.order.driverPhone,
                driverRating: widget.order.driverRating,
                driverVehicle: widget.order.driverVehicle,
                supplierName: widget.order.supplierName,
                weightKg: widget.order.weightKg,
                eta: widget.order.eta,
                distanceKm: widget.order.distanceKm,
                proofImagePath: _proofImage?.path,
                paidAmount: widget.order.reward,
              );
              widget.onComplete(updatedOrder);
            },
            child: Text(
              'تأكيد الإتمام',
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
            'إتمام الرحلة',
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
                          'التقط صورة إثبات الاستلام (اختياري)',
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
                'المبلغ المطلوب تحصيله:',
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
                    'د.أ',
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
          
          // Complete Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _showCompletionDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06402B),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                'إنهاء الطلب',
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
