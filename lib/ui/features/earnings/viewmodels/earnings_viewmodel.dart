import 'package:flutter/material.dart';
import '../../../../core/state/view_state.dart';
import '../../../../domain/entities/earnings/earnings_summary.dart';
import '../../../../domain/services/earnings_service.dart';
import '../../../../domain/services/pdf_report_service.dart';

class EarningsViewModel extends ChangeNotifier {
  final EarningsService _earningsService;
  final PdfReportService _reportService;

  EarningsViewModel(this._earningsService, this._reportService);

  ViewState<EarningsSummary> _state = const Idle();
  ViewState<EarningsSummary> get state => _state;

  String _riderId = '';

  Future<void> init(String riderId) async {
    _riderId = riderId;
    await fetchEarnings();
  }

  Future<void> fetchEarnings() async {
    _state = const Loading();
    notifyListeners();

    final result = await _earningsService.getEarningsSummary(
      riderId: _riderId,
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now(),
    );

    _state = result.fold(onSuccess: Loaded.new, onFailure: Failed.new);
    notifyListeners();
  }

  Future<void> generateReport() async {
    final current = _state;
    if (current is Loaded<EarningsSummary>) {
      await _reportService.generateAndShareReport(current.data);
    }
  }
}
