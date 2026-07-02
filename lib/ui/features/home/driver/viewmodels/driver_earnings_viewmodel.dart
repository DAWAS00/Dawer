import 'package:flutter/foundation.dart';
import '../../../../../data/models/order/order.dart';

enum EarningsPeriod { day, week, month }

class EarningsFinancials {
  final double baseFee;
  final double distanceFee;
  final double materialFee;
  final double urgencyFee;

  const EarningsFinancials({
    required this.baseFee,
    required this.distanceFee,
    required this.materialFee,
    required this.urgencyFee,
  });

  double get total => baseFee + distanceFee + materialFee + urgencyFee;
}

class EarningsBucket {
  final DateTime time;
  final double netJd;

  const EarningsBucket({required this.time, required this.netJd});
}

class DriverEarningsSummary {
  final double totalEarnings;
  final int totalOrders;
  final double netGrowth;
  final List<EarningsBucket> trends;
  final Map<WasteType, double> jdByType;
  final Map<WasteType, int> tripsByType;
  final EarningsFinancials financials;

  const DriverEarningsSummary({
    required this.totalEarnings,
    required this.totalOrders,
    required this.netGrowth,
    required this.trends,
    required this.jdByType,
    required this.tripsByType,
    required this.financials,
  });
}

class DriverEarningsViewModel extends ChangeNotifier {
  // Placeholder implementation for UI stability

  DriverEarningsSummary get summary => DriverEarningsSummary(
    totalEarnings: 154.20,
    totalOrders: 42,
    netGrowth: 12.5,
    trends: List.generate(
      7,
      (i) => EarningsBucket(
        time: DateTime.now().subtract(Duration(days: 6 - i)),
        netJd: 10.0 + (i * 5.0),
      ),
    ),
    jdByType: {
      WasteType.plastic: 45.0,
      WasteType.metal: 32.0,
      WasteType.paper: 28.0,
    },
    tripsByType: {
      WasteType.plastic: 15,
      WasteType.metal: 10,
      WasteType.paper: 12,
    },
    financials: const EarningsFinancials(
      baseFee: 80.0,
      distanceFee: 45.2,
      materialFee: 20.0,
      urgencyFee: 9.0,
    ),
  );

  EarningsPeriod _period = EarningsPeriod.week;
  EarningsPeriod get period => _period;

  void setPeriod(EarningsPeriod p) {
    _period = p;
    notifyListeners();
  }
}
