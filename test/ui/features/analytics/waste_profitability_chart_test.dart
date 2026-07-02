import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dwaar/data/models/order/order_enums.dart';
import 'package:dwaar/ui/features/analytics/analytics_viewmodel.dart';
import 'package:dwaar/ui/features/analytics/widgets/waste_profitability_chart.dart';

import '../../../helpers/test_app.dart';

void main() {
  testWidgets('WasteProfitabilityChart shows empty state when data empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithL10n(const WasteProfitabilityChart(data: [])),
    );
    expect(find.byType(LinearProgressIndicator), findsNothing);
  });

  testWidgets('WasteProfitabilityChart renders rows and top badge', (
    tester,
  ) async {
    final data = [
      const WasteProfitability(
        type: WasteType.plastic,
        rewardPerKg: 6.0,
        totalKg: 10,
        totalReward: 60,
        sampleCount: 1,
      ),
      const WasteProfitability(
        type: WasteType.paper,
        rewardPerKg: 2.0,
        totalKg: 10,
        totalReward: 20,
        sampleCount: 1,
      ),
    ];
    await tester.pumpWidget(wrapWithL10n(WasteProfitabilityChart(data: data)));
    expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
  });
}
