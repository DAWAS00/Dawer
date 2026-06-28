import 'package:flutter/material.dart';
import 'kpi_card.dart';

/// Compact horizontal-scrolling row of [KpiCard]s, used by per-role home
/// screens. Each card is fixed-width (148dp) and sized via its own
/// [AspectRatio], so this never overflows regardless of label length.
///
/// This replaces the legacy inline `_StatCard`-in-`Expanded` pattern that
/// caused `BOTTOM OVERFLOWED` on narrow screens.
class KpiStrip extends StatelessWidget {
  const KpiStrip({
    super.key,
    required this.items,
    this.itemWidth = 148,
  });

  final List<KpiItem> items;
  final double itemWidth;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final it = items[i];
          return SizedBox(
            width: itemWidth,
            child: KpiCard(
              value: it.value,
              label: it.label,
              icon: it.icon,
              color: it.color,
              delta: it.delta,
              deltaPositive: it.deltaPositive,
              onTap: it.onTap,
              aspectRatio: itemWidth / 104,
            ),
          );
        },
      ),
    );
  }
}

/// Data for one card in a [KpiStrip].
class KpiItem {
  const KpiItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.delta,
    this.deltaPositive,
    this.onTap,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final String? delta;
  final bool? deltaPositive;
  final VoidCallback? onTap;
}
