import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// DwaarDetailCard — Premium Reusable Card System
//
// A composable set of widgets for building beautiful, consistent detail screens.
// Use these primitives to construct any order/market-item detail section:
//
//   DwaarDetailCard       — base container with elevation variants
//   DwaarDetailHeader     — section title with icon + optional trailing
//   DwaarDetailRow        — labeled key→value row
//   DwaarDetailChip       — inline tag / badge
//   DwaarDetailDivider    — themed separator
//   DwaarDetailSection    — composite: header + divider + body
//   DwaarDetailGradientBar — gradient accent bar for emphasis
// ═══════════════════════════════════════════════════════════════════════════════

/// Elevation styles for [DwaarDetailCard].
enum DwaarCardElevation {
  /// No shadow, subtle border only.
  flat,

  /// Standard raised card with soft shadow.
  raised,

  /// Highlighted card with colored border accent.
  highlighted,

  /// Glassmorphic — frosted border + deeper shadow.
  glass,
}

// ── DwaarDetailCard ──────────────────────────────────────────────────────────

/// Premium base card. All order-detail sections are built from this.
///
/// ```dart
/// DwaarDetailCard(
///   elevation: DwaarCardElevation.raised,
///   child: Column(children: [...]),
/// )
/// ```
class DwaarDetailCard extends StatelessWidget {
  final Widget child;
  final DwaarCardElevation elevation;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final Color? accentColor;
  final VoidCallback? onTap;
  final bool animate;
  final int animationIndex;
  final BorderRadiusGeometry? borderRadius;

  const DwaarDetailCard({
    super.key,
    required this.child,
    this.elevation = DwaarCardElevation.raised,
    this.margin = const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
    this.padding = const EdgeInsets.all(16),
    this.accentColor,
    this.onTap,
    this.animate = true,
    this.animationIndex = 0,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(20);
    final accent = accentColor ?? AppColors.primaryGreen;

    final BoxDecoration decoration = switch (elevation) {
      DwaarCardElevation.flat => BoxDecoration(
          color: Colors.white,
          borderRadius: br,
          border: Border.all(color: AppColors.borderSubtle),
        ),
      DwaarCardElevation.raised => BoxDecoration(
          color: Colors.white,
          borderRadius: br,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      DwaarCardElevation.highlighted => BoxDecoration(
          color: Colors.white,
          borderRadius: br,
          border: Border.all(color: accent.withValues(alpha: 0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      DwaarCardElevation.glass => BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: br,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: accent.withValues(alpha: 0.04),
              blurRadius: 40,
              offset: const Offset(0, 2),
            ),
          ],
        ),
    };

    Widget card = Container(
      margin: margin,
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        borderRadius: br,
        child: InkWell(
          onTap: onTap,
          borderRadius:
              br is BorderRadius ? br : BorderRadius.circular(20),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    if (!animate) return card;

    return card
        .animate()
        .fadeIn(
          duration: 400.ms,
          delay: Duration(milliseconds: 60 * animationIndex),
        )
        .slideY(
          begin: 0.04,
          end: 0,
          duration: 400.ms,
          delay: Duration(milliseconds: 60 * animationIndex),
          curve: Curves.easeOutCubic,
        );
  }
}

// ── DwaarDetailHeader ────────────────────────────────────────────────────────

/// Section header: icon badge + title + optional trailing widget.
class DwaarDetailHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final Color? iconColor;
  final Color? iconBgColor;

  const DwaarDetailHeader({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.iconColor,
    this.iconBgColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? AppColors.primaryGreen;
    final bg = iconBgColor ?? color.withValues(alpha: 0.08);

    return Row(
      children: [
        if (trailing != null) ...[trailing!, const Spacer()],
        if (trailing == null) const Spacer(),
        Text(
          title,
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF002819),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ],
    );
  }
}

// ── DwaarDetailRow ───────────────────────────────────────────────────────────

/// A key→value row with optional icon prefix.
class DwaarDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final bool isBold;
  final bool isHighlighted;

  const DwaarDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.isBold = false,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final valueColor =
        isHighlighted ? AppColors.statusActiveText : const Color(0xFF404943);
    final labelColor =
        isBold ? const Color(0xFF374151) : const Color(0xFF6B7280);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Value on the left for RTL
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.start,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Label on the right for RTL
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: labelColor,
            ),
          ),
          if (icon != null) ...[
            const SizedBox(width: 8),
            Icon(icon, size: 14, color: iconColor ?? AppColors.mutedText),
          ],
        ],
      ),
    );
  }
}

// ── DwaarDetailChip ──────────────────────────────────────────────────────────

/// Inline tag/badge with icon + label.
class DwaarDetailChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final bool outlined;

  const DwaarDetailChip({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.primaryGreen,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: outlined ? 0.3 : 0.15),
          width: outlined ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── DwaarDetailDivider ───────────────────────────────────────────────────────

/// Themed section divider — softer than the default Material divider.
class DwaarDetailDivider extends StatelessWidget {
  final double verticalPadding;
  final Color? color;

  const DwaarDetailDivider({
    super.key,
    this.verticalPadding = 12,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              (color ?? const Color(0xFFEEF2EE)).withValues(alpha: 0),
              color ?? const Color(0xFFEEF2EE),
              (color ?? const Color(0xFFEEF2EE)).withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

// ── DwaarDetailSection ───────────────────────────────────────────────────────

/// Composite widget: header + divider + body content.
/// Wraps everything in a [DwaarDetailCard].
class DwaarDetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final Widget child;
  final DwaarCardElevation elevation;
  final Color? accentColor;
  final EdgeInsetsGeometry margin;
  final int animationIndex;
  final bool animate;

  const DwaarDetailSection({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.trailing,
    this.elevation = DwaarCardElevation.raised,
    this.accentColor,
    this.margin = const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
    this.animationIndex = 0,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    return DwaarDetailCard(
      elevation: elevation,
      accentColor: accentColor,
      margin: margin,
      animate: animate,
      animationIndex: animationIndex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DwaarDetailHeader(
            icon: icon,
            title: title,
            trailing: trailing,
            iconColor: accentColor,
          ),
          const DwaarDetailDivider(verticalPadding: 10),
          child,
        ],
      ),
    );
  }
}

// ── DwaarDetailGradientBar ───────────────────────────────────────────────────

/// A small gradient accent bar for emphasis — used at the top of earnings cards.
class DwaarDetailGradientBar extends StatelessWidget {
  final Color startColor;
  final Color endColor;
  final double height;

  const DwaarDetailGradientBar({
    super.key,
    this.startColor = AppColors.ctaGradientStart,
    this.endColor = AppColors.ctaGradientEnd,
    this.height = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [startColor, endColor]),
        borderRadius: BorderRadius.circular(height / 2),
      ),
    );
  }
}

// ── DwaarStatusBadge ─────────────────────────────────────────────────────────

/// A premium status badge with optional pulsing animation.
class DwaarStatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final bool pulsing;

  const DwaarStatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.pulsing = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: textColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pulsing) ...[
            _PulsingDot(color: textColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );

    return badge;
  }
}

/// Small pulsing dot indicator for active status.
class _PulsingDot extends StatelessWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
    )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scaleXY(end: 1.3, duration: 800.ms, curve: Curves.easeInOut)
        .then()
        .scaleXY(end: 1.0, duration: 800.ms, curve: Curves.easeInOut);
  }
}

// ── DwaarMetricTile ──────────────────────────────────────────────────────────

/// A small metric display (icon + value + label) used in footers and summaries.
class DwaarMetricTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool bold;

  const DwaarMetricTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.color = AppColors.mutedText,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.mutedText,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
