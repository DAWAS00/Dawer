import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dwaar/data/models/order/order.dart';
import 'package:dwaar/l10n/l10n.dart';
import 'package:dwaar/core/constants/app_colors.dart';
import 'package:dwaar/ui/features/home/shared/order_details/order_details_app_bar.dart';
import 'package:dwaar/ui/features/home/shared/order_details/order_map_section.dart';
import 'package:dwaar/ui/features/home/shared/order_details/order_route_card.dart';
import 'package:dwaar/ui/features/home/shared/order_details/order_contents_section.dart';
import 'package:dwaar/ui/features/home/shared/order_details/order_earnings_section.dart';

class OrderPreviewView extends StatefulWidget {
  final Order order;
  final Future<String?> Function(Order) onAccept;

  const OrderPreviewView({
    super.key,
    required this.order,
    required this.onAccept,
  });

  @override
  State<OrderPreviewView> createState() => _OrderPreviewViewState();
}

class _OrderPreviewViewState extends State<OrderPreviewView> {
  bool _accepting = false;

  Future<void> _handleAccept() async {
    setState(() => _accepting = true);
    final error = await widget.onAccept(widget.order);
    if (!mounted) return;
    setState(() => _accepting = false);

    if (error != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            context.l10n.alert,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
          ),
          content: Text(
            error,
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                context.l10n.ok,
                style: GoogleFonts.cairo(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context); // Go back to driver home
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF06402B).withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _accepting ? null : _handleAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _accepting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      context.l10n.orderAcceptButton,
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          OrderDetailsAppBar(order: widget.order, hideStatus: true),
          SliverToBoxAdapter(
            child: OrderMapSection(order: widget.order, hasDriver: false),
          ),
          SliverToBoxAdapter(child: OrderRouteCard(order: widget.order)),
          SliverToBoxAdapter(child: OrderContentsSection(order: widget.order)),
          SliverToBoxAdapter(child: OrderEarningsSection(order: widget.order)),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
