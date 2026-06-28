import 'package:flutter/material.dart';
import 'kpi_card.dart';

/// Responsive grid of [KpiCard]s. 2 columns on phones, 3–4 on wide screens.
/// Each card is sized via its own [AspectRatio], so this layout never
/// overflows regardless of count or label length.
class KpiGrid extends StatelessWidget {
  const KpiGrid({super.key, required this.children});

  final List<Widget> children;

  int _columnsFor(double width) {
    if (width >= 720) return 4;
    if (width >= 540) return 3;
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cols = _columnsFor(constraints.maxWidth);
        final rows = (children.length / cols).ceil();
        return Column(
          children: [
            for (int r = 0; r < rows; r++)
              Padding(
                padding: EdgeInsets.only(bottom: r == rows - 1 ? 0 : 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int c = 0; c < cols; c++)
                      if (r * cols + c < children.length) ...[
                        Expanded(child: children[r * cols + c]),
                        if (c < cols - 1) const SizedBox(width: 12),
                      ],
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
