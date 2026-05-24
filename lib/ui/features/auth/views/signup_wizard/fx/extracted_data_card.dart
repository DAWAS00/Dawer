import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExtractedDataCard extends StatelessWidget {
  final String title;
  final Map<String, String> fields;
  final double score;

  const ExtractedDataCard({
    super.key,
    required this.title,
    required this.fields,
    required this.score,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF06402B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.verified_user_rounded, color: Color(0xFF2E7D32), size: 20),
                ],
              ),
              const SizedBox(height: 16),
              ...fields.entries.map((e) => _buildRow(e.key, e.value)),
              const Divider(color: Colors.white24, height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TrustBadge(score: score),
                  Text(
                    'رؤية مستقبلية: الربط مع سند ✓',
                    style: GoogleFonts.cairo(
                      fontSize: 10,
                      color: const Color(0xFF059669),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            value,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: const Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrustBadge extends StatelessWidget {
  final double score;
  const _TrustBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF06402B).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF06402B).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(
            'نسبة المصداقية',
            style: GoogleFonts.cairo(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF06402B),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${(score * 100).toInt()}%',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF2E7D32),
            ),
          ),
        ],
      ),
    );
  }
}
