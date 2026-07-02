import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../domain/entities/rider_proximity_state.dart';
import '../../../../../ui/features/chat/views/chat_view.dart';
import '../viewmodels/rider_proximity_viewmodel.dart';

// ── ProximityStatusBanner ─────────────────────────────────────────────────────
//
// Sticky banner displayed at the top of the active-order card/screen.
// Collapsed (hidden) when state is [ProximityIdle].
//
// Optimized with Signals: Only the timer component rebuilds on every tick.

class ProximityStatusBanner extends StatelessWidget {
  const ProximityStatusBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RiderProximityViewModel>();

    return Watch((context) {
      return switch (vm.proximityState) {
        ProximityIdle() => const SizedBox.shrink(),
        final NearPickup _ => _buildBanner(
          context: context,
          bg: AppColors.amberContainer,
          fg: AppColors.accentAmber,
          icon: Icons.location_pin,
          label: 'أنت قريب من نقطة الاستلام',
          orderId: vm.order.id,
          timerChip: _PickupTimerChip(vm: vm, fg: AppColors.accentAmber),
        ),
        NearDropoff() => _buildBanner(
          context: context,
          bg: AppColors.statusActiveBg,
          fg: AppColors.statusActiveText,
          icon: Icons.check_circle_outline_rounded,
          label: 'أنت قريب من الزبون',
          orderId: vm.order.id,
        ),
      };
    });
  }

  Widget _buildBanner({
    required BuildContext context,
    required Color bg,
    required Color fg,
    required IconData icon,
    required String label,
    required String orderId,
    Widget? timerChip,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: fg.withValues(alpha: 0.2))),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
          if (timerChip != null) ...[
            const SizedBox(width: 8),
            timerChip,
            const SizedBox(width: 8),
          ],
          _ChatButton(orderId: orderId, fg: fg, bg: bg),
        ],
      ),
    );
  }
}

// ── Timer chip ────────────────────────────────────────────────────────────────

class _PickupTimerChip extends StatelessWidget {
  final RiderProximityViewModel vm;
  final Color fg;
  const _PickupTimerChip({required this.vm, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Watch((context) {
      final state = vm.nearPickup.value;
      if (state == null) return const SizedBox.shrink();

      final expired = state.waitExpired;
      final remaining = state.remaining;
      final mm = remaining.inMinutes.toString().padLeft(2, '0');
      final ss = (remaining.inSeconds % 60).toString().padLeft(2, '0');
      final label = expired ? 'انتهى الوقت' : '$mm:$ss';
      final chipFg = expired ? AppColors.statusCancelledText : fg;
      final chipBg = expired
          ? AppColors.statusCancelledBg
          : Colors.white.withValues(alpha: 0.7);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: chipBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              expired
                  ? Icons.timer_off_rounded
                  : Icons.hourglass_bottom_rounded,
              size: 14,
              color: chipFg,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: chipFg,
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ── Chat button ───────────────────────────────────────────────────────────────

class _ChatButton extends StatelessWidget {
  final String orderId;
  final Color fg;
  final Color bg;
  const _ChatButton({
    required this.orderId,
    required this.fg,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => ChatView.push(context, orderId: orderId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: fg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_rounded, size: 14, color: bg),
            const SizedBox(width: 4),
            Text(
              'دردشة',
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: bg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
