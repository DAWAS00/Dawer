import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/ui/features/analytics/widgets/streak_heatmap.dart';

import '../../../helpers/test_app.dart';

void main() {
  testWidgets('StreakHeatmap renders 35 cells', (tester) async {
    await tester.pumpWidget(
      wrapWithL10n(
        StreakHeatmap(
          counts: {DateTime(2026, 6, 28): 1},
          today: DateTime(2026, 6, 28),
        ),
      ),
    );
    expect(find.byType(AspectRatio), findsNWidgets(35));
  });

  testWidgets('StreakHeatmap shows empty state when no counts', (tester) async {
    await tester.pumpWidget(
      wrapWithL10n(
        StreakHeatmap(
          counts: const {},
          today: DateTime(2026, 6, 28),
        ),
      ),
    );
    expect(find.byType(AspectRatio), findsNothing);
  });
}
