import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/theme/app_tokens.dart';
import '../../../../../data/services/eco_points_engine.dart';

/// Amman neighborhood leaderboard showing kg collected per district.
/// Taps through to a full leaderboard page.
class NeighborhoodLeaderboardPreview extends StatelessWidget {
  const NeighborhoodLeaderboardPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = EcoPointsEngine.neighborhoodLeaderboard().take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            TextButton(
              onPressed: () => _showFullLeaderboard(context),
              child: Text(
                'عرض الكل',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E5C35),
                ),
              ),
            ),
            const Spacer(),
            Text(
              'لوحة أحياء عمان ♻️',
              textAlign: TextAlign.right,
              style: GoogleFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...entries.asMap().entries.map(
          (e) => _LeaderboardTile(
            entry: e.value,
            rank: e.key + 1,
            maxKg: entries.first.kgCollected,
          ),
        ),
      ],
    );
  }

  void _showFullLeaderboard(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const NeighborhoodLeaderboardPage()),
    );
  }
}

/// Full scrollable leaderboard page.
class NeighborhoodLeaderboardPage extends StatelessWidget {
  const NeighborhoodLeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = EcoPointsEngine.neighborhoodLeaderboard();
    final maxKg = entries.first.kgCollected;

    return Scaffold(
      backgroundColor: context.dt.scaffold,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Colors.white,
        title: Text(
          'لوحة الأحياء — عمان ♻️',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).appBarTheme.backgroundColor ??
                      Theme.of(context).primaryColor,
                  const Color(0xFF1E6B35),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'إجمالي كغ مجمّعة حسب الحي',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.80),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${entries.fold(0, (s, e) => s + e.kgCollected)} كغ',
                  style: GoogleFonts.dmSans(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'من 10 أحياء في عمان',
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.70),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: entries.length,
              itemBuilder: (context, index) => _LeaderboardTile(
                entry: entries[index],
                rank: index + 1,
                maxKg: maxKg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final int maxKg;

  const _LeaderboardTile({
    required this.entry,
    required this.rank,
    required this.maxKg,
  });

  @override
  Widget build(BuildContext context) {
    final progress = entry.kgCollected / maxKg;
    final isTop3 = rank <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isTop3
            ? const Color(0xFF1E5C35).withValues(alpha: 0.06)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: isTop3
            ? Border.all(color: const Color(0xFF1E5C35).withValues(alpha: 0.20))
            : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                entry.kgCollected.toString(),
                style: GoogleFonts.dmSans(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E5C35),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'كغ',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: context.dt.onSurfaceMuted,
                ),
              ),
              const Spacer(),
              Text(
                entry.district,
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(width: 8),
              Text(entry.medal, style: const TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFF1E5C35).withValues(alpha: 0.10),
              valueColor: AlwaysStoppedAnimation<Color>(
                isTop3
                    ? const Color(0xFF1E5C35)
                    : const Color(0xFF1E5C35).withValues(alpha: 0.60),
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
