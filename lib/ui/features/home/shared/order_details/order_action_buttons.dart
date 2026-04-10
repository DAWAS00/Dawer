import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../data/models/order.dart';

class OrderActionButtons extends StatelessWidget {
  final Order order;

  const OrderActionButtons({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    if (order.driverName == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _ActionBtn(
              label: 'تواصل',
              icon: Icons.chat_bubble_outline_rounded,
              color: const Color(0xFF06402B),
              onTap: () => _openChat(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionBtn(
              label: 'واتساب',
              icon: Icons.phone_rounded,
              color: const Color(0xFF25D366),
              onTap: () => _openWhatsApp(context),
            ),
          ),
        ],
      ),
    );
  }

  void _openChat(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'المحادثة مع السائق قريباً',
          textAlign: TextAlign.right,
          style: GoogleFonts.cairo(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF06402B),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final phone = order.driverPhone;
    if (phone == null) return;
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final intl =
        cleaned.startsWith('0') ? '962${cleaned.substring(1)}' : cleaned;
    final uri = Uri.parse(
        'https://wa.me/$intl?text=${Uri.encodeComponent('مرحباً، أنا في انتظار استلامي.')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذّر فتح واتساب',
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(color: Colors.white),
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}

// ── Action Button ─────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
