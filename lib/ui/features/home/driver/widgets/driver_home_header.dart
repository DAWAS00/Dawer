import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:dwaar/core/constants/app_colors.dart';
import 'package:dwaar/core/layout/app_layout.dart';
import 'package:dwaar/l10n/l10n.dart';

class DriverHomeHeader extends StatelessWidget {
  const DriverHomeHeader({
    super.key,
    required this.userName,
    required this.isOnline,
    required this.onStatusToggle,
    required this.totalEarnings,
  });

  final String userName;
  final bool isOnline;
  final ValueChanged<bool> onStatusToggle;
  final double totalEarnings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.ctaGradientStart],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20,
        left: context.layout.hPad,
        right: context.layout.hPad,
        bottom: 24,
      ),
      child: Column(
        children: [
          // Top row: earnings chip | name+subtitle | avatar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _EarningsChip(
                totalEarnings: totalEarnings,
                label: l10n.driverEarningsLabel,
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'مرحباً، $userName',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: AppColors.surface.withValues(alpha: 0.75),
                    ),
                  ),
                  Text(
                    l10n.driverTitle,
                    style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.surface,
                    ),
                  ),
                ],
              ),

              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surface.withValues(alpha: 0.25),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  LucideIcons.user,
                  color: AppColors.surface,
                  size: 22,
                ),
              ),
            ],
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 20),

          // Availability row: status label + pulse dot | toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedToggleSwitch<bool>.size(
                current: isOnline,
                values: const [true, false],
                iconOpacity: 0.2,
                indicatorSize: const Size.fromWidth(110),
                customIconBuilder: (context, local, global) => Text(
                  local.value
                      ? l10n.driverToggleOnline
                      : l10n.driverToggleOffline,
                  style: GoogleFonts.cairo(
                    color: Color.lerp(
                      AppColors.mutedText,
                      AppColors.surface,
                      local.animationValue,
                    ),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                borderWidth: 2.0,
                iconAnimationType: AnimationType.onHover,
                style: ToggleStyle(
                  indicatorColor: isOnline
                      ? AppColors.shamrock500
                      : AppColors.statusCancelledText,
                  backgroundColor: AppColors.surface.withValues(alpha: 0.1),
                  borderColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                selectedIconScale: 1.0,
                onChanged: (b) => onStatusToggle(b),
              ).animate().slideY(
                begin: 0.2,
                end: 0,
                duration: 400.ms,
                curve: Curves.easeOutBack,
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isOnline
                        ? l10n.driverStatusOnline
                        : l10n.driverStatusOffline,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: AppColors.surface.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _PulseDot(isOnline: isOnline),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatelessWidget {
  const _PulseDot({required this.isOnline});
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? AppColors.shamrock400 : AppColors.mutedText;
    return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fade(duration: 900.ms, begin: 0.35, end: 1.0);
  }
}

class _EarningsChip extends StatelessWidget {
  const _EarningsChip({required this.totalEarnings, required this.label});
  final double totalEarnings;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accentAmber.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentAmber.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            LucideIcons.coins,
            size: 13,
            color: AppColors.amberContainer,
          ),
          const SizedBox(width: 5),
          Text(
            '${totalEarnings.toStringAsFixed(1)} د.أ',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.amberContainer,
            ),
          ),
        ],
      ),
    );
  }
}
