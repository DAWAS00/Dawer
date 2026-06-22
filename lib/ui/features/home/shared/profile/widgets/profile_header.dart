import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../../core/constants/app_colors.dart';

/// Full-bleed gradient hero header shared by all role profile tabs.
///
/// Shows an avatar (icon or initial letter), the user's name, a role badge,
/// and optionally a rating and/or an ID code. A verification check overlaps
/// the avatar when [isVerified] is true.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.badgeLabel,
    this.avatarIcon = Icons.person_rounded,
    this.avatarInitial,
    this.isVerified = false,
    this.rating,
    this.idCode,
  });

  final String name;
  final String badgeLabel;
  final IconData avatarIcon;

  /// When set, the avatar shows this letter instead of [avatarIcon].
  final String? avatarInitial;
  final bool isVerified;

  /// Driver shows a star rating; others leave this null.
  final double? rating;

  /// Recycling company shows its license/registration code; others null.
  final String? idCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.ctaGradientEnd],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.of(context).padding.top + 28,
        24,
        32,
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 46,
                backgroundColor: Colors.white.withValues(alpha: 0.15),
                child: avatarInitial != null && avatarInitial!.isNotEmpty
                    ? Text(
                        avatarInitial!,
                        style: GoogleFonts.cairo(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : Icon(avatarIcon, size: 40, color: Colors.white),
              ),
              if (isVerified)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: AppColors.headerGradientEnd,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 6,
            children: [
              _Badge(label: badgeLabel),
              if (rating != null) _Rating(rating: rating!),
              if (idCode != null && idCode!.isNotEmpty)
                Text(
                  idCode!,
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    color: Colors.white70,
                    letterSpacing: 1.2,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: GoogleFonts.cairo(fontSize: 12, color: Colors.white),
      ),
    );
  }
}

class _Rating extends StatelessWidget {
  const _Rating({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, color: AppColors.accentAmber, size: 16),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
